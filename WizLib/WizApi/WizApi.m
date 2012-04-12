//
//  WizApi.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"
#import "XMLRPCRequest.h"
#import "XMLRPCConnection.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizDocument.h"
#import "WizAttachment.h"
#define DownloadPartSize 512*1024
//url
#define WizAccountUrl   [NSURL URLWithString:@"http://192.168.1.155:8800/wiz1/xmlrpc"]
//method
#define SyncMethod_ClientLogin                      @"accounts.clientLogin"
#define SyncMethod_DownloadDocumentList             @"document.getSimpleList"
#define SyncMethod_DownloadObject                   @"data.download"
#define SyncMethod_UploadObject                     @"data.upload"
#define SyncMethod_DocumentPostSimpleData           @"document.postSimpleData"
#define SyncMethod_DownloadAttachmentList           @"attachment.getList"
#define SyncMethod_AttachmentPostSimpleData         @"attachment.postSimpleData"
@implementation WizApi
@synthesize connectionXmlrpc;
@synthesize busy;
- (BOOL) startSync{
    return NO;
}
- (long long) listCount
{
    return 200;
}
- (void) solveTokenUnActiveError
{
    [WizNotificationCenter postTokenUnaciveWithErrorWizApi:self];
}
- (void) solveServerError
{
    [WizNotificationCenter postServerErrorMessageWithErrorApi:self];
}
-(void) onError: (id)retObject
{
    self.busy = NO;
    if ([retObject isKindOfClass:[NSError class]]) {
        NSError* error = (NSError*)retObject;
        if (error.code == ErrorCodeWizTokenUnActive) {
            [self solveTokenUnActiveError];
        }
        else if ([error.domain isEqualToString:WizErrorDomin])
        {
            [self solveServerError];
        }
        else {
            [WizGlobals reportError:retObject];
        }
    }
}

-(void) addCommonParams: (NSMutableDictionary*)postParams
{
    if (WizDeviceIsPad()) {
        [postParams setObject:@"ipad" forKey:@"client_type"];
    }
	else {
        [postParams setObject:@"iphone" forKey:@"client_type"];
    }
	[postParams setObject:@"normal" forKey:@"program_type"];
    [postParams setObject:[NSNumber numberWithInt:4] forKey:@"api_version"];
    
}
- (BOOL) addSyncKeys:(NSMutableDictionary*)postParams
{
    NSString* token = [[WizSyncManager shareManager] token];
    NSString* kbGUID = [[WizSyncManager shareManager] kbGuid];
    if ([token isEqualToString:@""] || [kbGUID isEqualToString:@""]) {
        [self onError:[WizGlobals tokenUnActiveError]];
        return NO;
    }
	[postParams setObject:token forKey:TypeOfCommonParamToken];
	[postParams setObject:kbGUID forKey:TypeOfCommonParamKbGUID];
    return YES;
}

-(BOOL) callClientLogin
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    NSString* activeAccount = [WizAccountManager activeAccountUserId];
	[postParams setObject:activeAccount forKey:@"user_id"];
    NSString* password = [WizAccountManager passwordForAccount:activeAccount];
    NSString* md5P = [WizGlobals md5:[password dataUsingEncoding:NSUTF8StringEncoding]];
    NSString* md = [NSString stringWithFormat:@"md5.%@",md5P];
	[postParams setObject:md forKey:@"password"];
	[self addCommonParams:postParams];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:WizAccountUrl method:SyncMethod_ClientLogin args:args];
}
-(BOOL) callDownloadDocumentList
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
    
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
    
    int64_t version = [[WizDbManager shareDbManager] documentVersion];
	if (version)
	{
		[postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
	}
    else
    {
        [postParams setObject:[NSNumber numberWithInt:0] forKey:@"version"];
    }
	//
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl]  method:SyncMethod_DownloadDocumentList args:args];
}
-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
    [postParams setObject:objectGUID forKey:@"obj_guid"];
    [postParams setObject:objType forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:DownloadPartSize] forKey:@"part_size"];
    NSArray* args = [NSArray arrayWithObjects:postParams, nil];
    return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl] method:SyncMethod_DownloadObject args:args];
}

-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
    [postParams setObject:[NSNumber numberWithLong:objectSize] forKey:@"obj_size"];
    [postParams setObject:objectGUID forKey:@"obj_guid"];
    [postParams setObject:objectType forKey:@"obj_type"];
    [postParams setObject:sumMD5 forKey:@"obj_md5"];
    [postParams setObject:[NSNumber numberWithInt:sumPartCount] forKey:@"part_count"];
    [postParams setObject:data forKey:@"data"];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"part_sn"];
    NSString* localMd5 = [WizGlobals md5:data];
    [postParams setObject:localMd5 forKey:@"part_md5"];
    NSUInteger partSize=[data length];
    [postParams setObject:[NSNumber numberWithUnsignedInteger:partSize]   forKey:@"part_size"];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl] method:SyncMethod_UploadObject args:args];
}
-(BOOL) callDocumentPostSimpleData:(NSString *)documentGUID withZipMD5:(NSString *)zipMD5
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
	WizDocument* doc = [[WizDbManager shareDbManager] documentFromGUID:documentGUID];
	if (!doc)
		return NO;
	//
	//
	NSDate* dateCreated = [WizGlobals sqlTimeStringToDate:doc.dateCreated];
	NSDate* dateModified = [WizGlobals sqlTimeStringToDate:doc.dateModified];
	[postParams setObject:doc.guid forKey:@"document_guid"];
	[postParams setObject:doc.title forKey:@"document_title"];
	[postParams setObject:doc.type forKey:@"document_type"];
	[postParams setObject:doc.fileType forKey:@"document_filetype"];
	[postParams setObject:dateModified forKey:@"dt_modified"];
	[postParams setObject:doc.location forKey:@"document_category"];
    [postParams setObject:[NSNumber numberWithInt:1] forKey:@"document_info"];
    [postParams setObject:zipMD5 forKey:@"document_zip_md5"];
    [postParams setObject:dateCreated forKey:@"dt_created"];
    [postParams setObject:[NSNumber numberWithInt:1] forKey:@"with_document_data"];
    [postParams setObject:[NSNumber numberWithInt:doc.attachmentCount] forKey:@"document_attachment_count"];
    NSString* tags = [NSString stringWithString:doc.tagGuids];
    NSString* ss = [tags stringByReplacingOccurrencesOfString:@"*" withString:@";"];
    if(tags != nil)
        [postParams setObject:ss forKey:@"document_tag_guids"];
    else
        [postParams setObject:tags forKey:@"document_tag_guids"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl] method:SyncMethod_DocumentPostSimpleData args:args];
}
-(BOOL) callAttachmentPostSimpleData:(NSString *)attachmentGUID  withZiwMd5:(NSString*)ziwmd5
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
    WizAttachment* attach = [[WizDbManager shareDbManager] attachmentFromGUID:attachmentGUID];
    [postParams setObject:attach.guid             forKey:@"attachment_guid"];
    [postParams setObject:attach.documentGuid           forKey:@"attachment_document_guid"];
    [postParams setObject:attach.title          forKey:@"attachment_name"];
    [postParams setObject:attach.dateModified                  forKey:@"dt_modified"];
    [postParams setObject:attach.dataMd5                       forKey:@"data_md5"];
    [postParams setObject:ziwmd5                        forKey:@"attachment_zip_md5"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl] method:SyncMethod_AttachmentPostSimpleData args:args];
}
//
-(BOOL) callDownloadAttachmentList
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    if (![self addSyncKeys:postParams]) {
        return NO;
    }
    [postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
    int64_t version = [[WizDbManager shareDbManager] attachmentVersion];
    if (version) {
        [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
    }
    else
    {
        [postParams setObject:[NSNumber numberWithInt:0] forKey:@"version"];
    }
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:[[WizSyncManager shareManager] apiUrl] method:SyncMethod_DownloadAttachmentList args:args];
}




- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method
{
    if (succeeded && ![ret isKindOfClass:[NSError class]]) {
        if ([method isEqualToString:SyncMethod_ClientLogin]) {
            [self onClientLogin:ret];
        }
        else if ([method isEqualToString:SyncMethod_DownloadDocumentList])
        {
            [self onDownloadDocumentList:ret];
        }
        else if ([method isEqualToString:SyncMethod_DownloadObject])
        {
            [self onDownloadObject:ret];
        }
        else if ([method isEqualToString:SyncMethod_UploadObject])
        {
            [self onUploadObject:ret];
        }
        else if ([method isEqualToString:SyncMethod_DocumentPostSimpleData])
        {
            [self onPostDocumentSimpleData:ret];
        }
        else if ([method isEqualToString:SyncMethod_AttachmentPostSimpleData])
        {
            [self onPostAttachmentSimpleData:ret];
        }
        else if ([method isEqualToString:SyncMethod_DownloadAttachmentList])
        {
            [self onDownloadAttachmentList:ret];
        }
    }
    else {
        [self onError:ret];
    }
}


-(BOOL)executeXmlRpc: (NSURL*) url method: (NSString*)method args:(id)args
{
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:url];
	if (!request)
    {
		return NO;
    }
	[request setMethod:method withObjects:args];
	self.connectionXmlrpc = [XMLRPCConnection sendAsynchronousXMLRPCRequest:request delegate:self];
	[request release];
    if(nil != self.connectionXmlrpc)
        return YES;
    else
        return NO;
}


@end
