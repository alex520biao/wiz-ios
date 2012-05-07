   //
//  WizSyncBase.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "WizApi.h"
#import "WizGlobalDictionaryKey.h"
#import "XMLRPCConnection.h"
#import "XMLRPCRequest.h"

#import "WizNotification.h"
#import "WizDocument.h"

#define SyncMethod_ClientLogin                  @"accounts.clientLogin"
#define SyncMethod_ClientLogout                 @"accounts.clientLogout"
#define SyncMethod_CreateAccount                @"accounts.createAccount"
#define SyncMethod_GetAllCategories             @"category.getAll"
#define SyncMethod_GetAllTags                   @"tag.getList"
#define SyncMethod_DownloadDocumentList         @"document.getSimpleList"
#define SyncMethod_DocumentsByCategory          @"document.getSimpleListByCategory"
#define SyncMethod_DocumentsByTag               @"document.getSimpleListByTag"
#define SyncMethod_DownloadMobileData           @"document.getMobileData"
#define SyncMethod_UploadMobileData             @"document.postSimpleData"
#define SyncMethod_DownloadDeletedList          @"deleted.getList"
#define SyncMethod_UploadDeletedList            @"deleted.postList"
#define SyncMethod_DocumentsByKey               @"document.getSimpleListByKey"
#define SyncMethod_ChangeAccountPassword        @"accounts.changePassword"
#define SyncMethod_DownloadObject               @"data.download"
#define SyncMethod_UploadObject                 @"data.upload"
#define SyncMethod_GetAttachmentList            @"attachment.getList"
#define SyncMethod_PostTagList                  @"tag.postList"
#define SyncMethod_DocumentPostSimpleData       @"document.postSimpleData"
#define SyncMethod_AttachmentPostSimpleData     @"attachment.postSimpleData"
#define SyncMethod_GetUserInfo                  @"wiz.getInfo"

@implementation WizApi
@synthesize token;
@synthesize kbguid;
@synthesize accountURL;
@synthesize apiURL;
@synthesize connectionXmlrpc;
@synthesize delegate;
-(int) listCount
{
	return 50;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}
-(void) dealloc
{
    [token release];
    [kbguid release];
    [accountURL release];
    [apiURL release];
	[super dealloc];
}

- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method
{
	if (succeeded && ![ret isKindOfClass:[NSError class]])
	{
		if ([method isEqualToString:SyncMethod_ClientLogin])
		{
			[delegate onClientLogin:ret];
		}
		else if ([method isEqualToString:SyncMethod_ClientLogout])
		{
			[delegate onClientLogout:ret];
		}
		else if ([method isEqualToString:SyncMethod_CreateAccount])
		{
			[delegate onCreateAccount:ret];
		}
        else if ([method isEqualToString:SyncMethod_ChangeAccountPassword])
        {
            [delegate onChangePassword:ret];
        }
		else if ([method isEqualToString:SyncMethod_GetAllCategories])
		{
			[delegate onAllCategories:ret];
		}
		else if ([method isEqualToString:SyncMethod_GetAllTags])
		{
			[delegate onAllTags:ret];
		}
		else if ([method isEqualToString:SyncMethod_DownloadDocumentList])
		{
			[delegate onDownloadDocumentList:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByCategory])
		{
			[delegate onDocumentsByCategory:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByTag])
		{
			[delegate onDocumentsByTag:ret];
		}
		else if ([method isEqualToString:SyncMethod_DownloadDeletedList])
		{
			[delegate onDownloadDeletedList:ret];
		}
		else if ([method isEqualToString:SyncMethod_UploadDeletedList])
		{
			[delegate onUploadDeletedGUIDs:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByKey])
		{
			[delegate onDocumentsByKey:ret];
		}
        else if([method isEqualToString:SyncMethod_DownloadObject])
        {
            [delegate onDownloadObject:ret];
            return;
        }
        else if([method isEqualToString:SyncMethod_UploadObject])
        {
            [delegate onUploadObjectData:ret];
            return;
        }
        else if([method isEqualToString:SyncMethod_GetAttachmentList])
        {
            [delegate onDownloadAttachmentList:ret];
        }
        else if([method isEqualToString:SyncMethod_PostTagList])
        {
            [delegate onPostTagList:ret];
        }
        else if([method isEqualToString:SyncMethod_DocumentPostSimpleData])
        {
            [delegate onDocumentPostSimpleData:ret];
        }
        else if([method isEqualToString:SyncMethod_AttachmentPostSimpleData])
        {
            [delegate onAttachmentPostSimpleData:ret];
        }
        else if([method isEqualToString:SyncMethod_GetUserInfo])
        {
            [delegate onCallGetUserInfo:ret];
        } 
        else
		{
			[WizGlobals reportErrorWithString:NSLocalizedString(@"Unknown xml-rpc method!", nil)];
		}
        
	}
	else 
	{
        [self onError:ret];
	}
	//
	/////////////////////////////
	//
	////send xml-rpc done notification
	//
    self.connectionXmlrpc = nil;
	NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:method, @"method", ret, @"ret", [NSNumber numberWithBool:succeeded], @"succeeded", nil];
	[userInfo release];
}

-(BOOL)executeXmlRpc: (NSURL*) url method: (NSString*)method args:(id)args
{
	XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:url];
	if (!request)
    {
		return NO;
    }
	//
	[request setMethod:method withObjects:args];
	//
	self.connectionXmlrpc = [XMLRPCConnection sendAsynchronousXMLRPCRequest:request delegate:self];
	//
	[request release];
	//
    if(nil != self.connectionXmlrpc)
        return YES;
    else
        return NO;
}

-(void) addCommonParams: (NSMutableDictionary*)postParams
{
	[postParams setObject:@"iphone" forKey:@"client_type"];
	[postParams setObject:@"normal" forKey:@"program_type"];
//	[postParams setObject:[NSNumber numberWithInt:3] forKey:@"api_version"];
    // new version 4
    [postParams setObject:[NSNumber numberWithInt:4] forKey:@"api_version"];
	//
	if (self.token != nil)
	{
		[postParams setObject:self.token forKey:@"token"];
	}
	if (self.kbguid != nil)
	{
		[postParams setObject:self.kbguid forKey:@"kb_guid"];
	}
}

-(BOOL) callClientLogin:(NSString*)accountUserId accountPassword:(NSString*)accountPassword
{
	if (accountUserId == nil || [accountUserId length] == 0)
		return NO;
	if (accountPassword == nil || [accountPassword length] == 0)
		return NO;
	//
	self.token = nil;
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:accountUserId forKey:@"user_id"];
	[postParams setObject:accountPassword forKey:@"password"];
	[self addCommonParams:postParams];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ClientLogin args:args];
}
-(BOOL) callClientLogout
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ClientLogout args:args];
}

-(BOOL) callGetUserInfo
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_GetUserInfo args:args];
}

-(BOOL) callAllCategories
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAllCategories args:args];
}

-(BOOL) callAllTags:(int64_t)version
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAllTags args:args];
}

-(BOOL) callPostTagList:(NSArray*)tagList
{
    NSMutableArray* tagTemp = [[NSMutableArray alloc] initWithCapacity:[tagList count]];
    for(WizTag* each in tagList)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        [dic setObject:each.guid forKey:@"tag_guid"];
        if(nil !=each.parentGUID)
            [dic setObject:each.parentGUID forKey:@"tag_group_guid"];
        [dic setObject:each.title forKey:@"tag_name"];
        [dic setObject:each.description forKey:@"tag_description"];
        [dic setObject:each.dateInfoModified forKey:@"dt_info_modified"];
        [tagTemp addObject:dic];
        [dic release];
        
    }
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObject:tagTemp forKey:@"tags"];
    [tagTemp release];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_PostTagList args:args];
    
}

-(BOOL) callDownloadDocumentList:(int64_t)version
{
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadDocumentList args:args];
}

-(BOOL) callDownloadAttachmentList:(int64_t)version
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
    [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAttachmentList args:args];
}

-(BOOL) callDownloadDeletedList:(int64_t)version
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
	[postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
    BOOL ret = [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadDeletedList args:args];
	return  ret;
}

-(BOOL) callDocumentsByCategory:(NSString*)location
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:location forKey:@"category"];
	[postParams setObject:[NSNumber numberWithInt:1000] forKey:@"count"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByCategory args:args];
}

-(BOOL) callDocumentsByTag:(NSString*)tagGUID
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:tagGUID forKey:@"tag_guid"];
	[postParams setObject:[NSNumber numberWithInt:1000] forKey:@"count"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByTag args:args];
}


-(BOOL) callDocumentsByKey:(NSString*)keywords attributes:(NSString*)attributes
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:keywords forKey:@"key"];
	[postParams setObject:[NSNumber numberWithInt:200] forKey:@"count"];
	[postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
	//[postParams setObject:attributes forKey:@"attributes"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByKey args:args];
}

-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType  partSize:(int)partSize{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
    [postParams setObject:objectGUID forKey:@"obj_guid"];
    [postParams setObject:objType forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:partSize] forKey:@"part_size"];
    NSArray* args = [NSArray arrayWithObjects:postParams, nil];
    return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadObject args:args];
}

-(BOOL) callDownloadMobileData:(NSString*)documentGUID
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:documentGUID forKey:@"document_guid"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadMobileData args:args];
}

-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams]; 
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
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadObject args:args];
}

-(BOOL) callUploadDeletedGUIDs:(NSArray*)deleteGuids
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:deleteGuids forKey:@"deleteds"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadDeletedList args:args];
}

- (BOOL) callChangePassword:(NSString*)accountUserId  oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:accountUserId forKey:TypeOfChangePasswordAccountUserId];
    [postParams setObject:oldPassword forKey:TypeOfChangePasswordOldPassword];
    [postParams setObject:newPassword forKey:TypeOfChangePasswordNewPassword];
    [self addCommonParams:postParams];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ChangeAccountPassword args:args];
}

-(BOOL) callCreateAccount:(NSString*)accountUserId  password:(NSString*)accountPassword
{
	if (accountUserId == nil || [accountUserId length] == 0)
		return NO;
	if (accountPassword == nil || [accountPassword length] == 0)
		return NO;
    self.token = nil;
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
	[postParams setObject:accountUserId forKey:@"user_id"];
	[postParams setObject:accountPassword forKey:@"password"];
    [postParams setObject:@"wiz_iphone" forKey:@"product_name"];
    [postParams setObject:@"f6d9193f" forKey:@"invite_code"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_CreateAccount args:args];
}

-(BOOL) callDocumentPostSimpleData:(WizDocument*)doc withZipMD5:(NSString *)zipMD5
{
	if (!doc)
		return NO;
	//
	//
	NSDate* dateCreated = doc.dateCreated;
	NSDate* dateModified = doc.dateModified;
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentPostSimpleData args:args];
}

-(BOOL) callAttachmentPostSimpleData:(WizAttachment*)attach  dataMd5:(NSString*)dataMD5     ziwMd5:(NSString*)ziwMD5
{
    if (dataMD5 == nil) {
        return NO;
    }
    //fill the post info
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObject:attach.guid             forKey:@"attachment_guid"];
    [postParams setObject:attach.documentGuid           forKey:@"attachment_document_guid"];
    [postParams setObject:[attach.title stringByReplacingOccurrencesOfString:@":" withString:@"-"]            forKey:@"attachment_name"];
    [postParams setObject:attach.dateModified                  forKey:@"dt_modified"];
    [postParams setObject:dataMD5                       forKey:@"data_md5"];
    [postParams setObject:ziwMD5                        forKey:@"attachment_zip_md5"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_AttachmentPostSimpleData args:args];
}
-(void) onError: (id)retObject
{
	if ([retObject isKindOfClass:[NSError class]])
	{
        [WizGlobals toLog:[NSString stringWithFormat:@"%@",retObject]];
        NSError* error = (NSError*)retObject;
        NSLog(@"error is %@",error);
        if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain])
        {
            [WizNotificationCenter postMessageTokenUnactiveError];
        }
        else {
            [WizGlobals reportError:retObject];
        }
	}
}
-(void) cancel
{
    if (self.connectionXmlrpc)
    {
        [self.connectionXmlrpc cancel];
    }
}
@end
