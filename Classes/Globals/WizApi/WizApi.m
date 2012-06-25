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
#import "WizObject+WizSync.h"
#import "WizNotification.h"
#import "WizDocument.h"
#import "WizSyncManager.h"

#define SyncMethod_ClientLogin                  @"accounts.clientLogin"
#define SyncMethod_ClientLogout                 @"accounts.clientLogout"
#define SyncMethod_CreateAccount                @"accounts.createAccount"
#define SyncMethod_ChangeAccountPassword        @"accounts.changePassword"
#define SyncMethod_GetAllCategories             @"category.getAll"
#define SyncMethod_GetAllTags                   @"tag.getList"
#define SyncMethod_PostTagList                  @"tag.postList"
#define SyncMethod_DocumentsByKey               @"document.getSimpleListByKey"
#define SyncMethod_DownloadDocumentList         @"document.getSimpleList"
#define SyncMethod_DocumentsByCategory          @"document.getSimpleListByCategory"
#define SyncMethod_DocumentsByTag               @"document.getSimpleListByTag"
#define SyncMethod_DocumentPostSimpleData       @"document.postSimpleData"
#define SyncMethod_DownloadDeletedList          @"deleted.getList"
#define SyncMethod_UploadDeletedList            @"deleted.postList"
#define SyncMethod_DownloadObject               @"data.download"
#define SyncMethod_UploadObject                 @"data.upload"
#define SyncMethod_AttachmentPostSimpleData     @"attachment.postSimpleData"
#define SyncMethod_GetAttachmentList            @"attachment.getList"
#define SyncMethod_GetUserInfo                  @"wiz.getInfo"
#define SyncMethod_GetGropKbGuids               @"accounts.getGroupKbList"

@interface WizApi ()
{
    SEL xmlRpcDoneSelector;
}
@end

@implementation WizApi
@synthesize token;
@synthesize kbguid;
@synthesize accountURL;
@synthesize apiURL;
@synthesize connectionXmlrpc;
@synthesize delegate;
@synthesize busy;
@synthesize syncMessage;
@synthesize apiManagerDelegate;
@dynamic syncStatue;

- (void) setSyncStatue:(WizSyncStatueCode)syncStatue_
{
    syncStatue = syncStatue_;
}
- (WizSyncStatueCode) syncStatue
{
    return syncStatue;
}
-(int) listCount
{
	return 50;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.delegate = self;
        attempts = WizNetWorkMaxAttempts;
        [self addObserver:self forKeyPath:@"syncMessage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        self.apiManagerDelegate = [WizSyncManager shareManager];
    }
    return self;
}
- (BOOL) start
{
    return YES;
}
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"syncMessage"]) {
        NSString* newSyncDes = [change valueForKey:NSKeyValueChangeNewKey];
        [self.apiManagerDelegate didChangedSyncDescriptorMessage:newSyncDes];
    }
    
}
-(void) dealloc
{
    [token release];
    [kbguid release];
    [accountURL release];
    [apiURL release];
    [syncMessage release];
    delegate = nil;
    [self removeObserver:self forKeyPath:@"syncMessage"];
    apiManagerDelegate = nil;
	[super dealloc];
}
- (void)  delegatePerformSelector:(SEL)aSelector withObject:(id)ret
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [delegate performSelector:aSelector withObject:ret];
    [pool drain];
}
- (void) delegatePerformXmlRpcDoneSelectorWithObject:(id)ret
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [delegate performSelector:xmlRpcDoneSelector withObject:ret];
    [pool drain];
}
- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	if (succeeded && ![ret isKindOfClass:[NSError class]])
	{
        @synchronized(self)
        {
            if ([method isEqualToString:SyncMethod_ClientLogin])
            {
                xmlRpcDoneSelector = @selector(onClientLogin:);
    //			[delegate onClientLogin:ret];
            }
            else if ([method isEqualToString:SyncMethod_ClientLogout])
            {
                xmlRpcDoneSelector = @selector(onClientLogout:);
    //			[delegate onClientLogout:ret];
            }
            else if ([method isEqualToString:SyncMethod_CreateAccount])
            {
                xmlRpcDoneSelector = @selector(onCreateAccount:);
    //			[delegate onCreateAccount:ret];
            }
            else if ([method isEqualToString:SyncMethod_ChangeAccountPassword])
            {
                xmlRpcDoneSelector = @selector(onChangePassword:);
    //            [delegate onChangePassword:ret];
            }
            else if ([method isEqualToString:SyncMethod_GetAllCategories])
            {
                xmlRpcDoneSelector = @selector(onAllCategories:);
    //			[delegate onAllCategories:ret];
            }
            else if ([method isEqualToString:SyncMethod_GetAllTags])
            {
                xmlRpcDoneSelector = @selector(onAllTags:);
    //			[delegate onAllTags:ret];
            }
            else if ([method isEqualToString:SyncMethod_DownloadDocumentList])
            {
                xmlRpcDoneSelector = @selector(onDownloadDocumentList:);
    //			[self performSelectorInBackground:selector withObject:ret];
            }
            else if ([method isEqualToString:SyncMethod_DocumentsByCategory])
            {
                xmlRpcDoneSelector = @selector(onDocumentsByCategory:);
    //			[delegate onDocumentsByCategory:ret];
            }
            else if ([method isEqualToString:SyncMethod_DocumentsByTag])
            {
                xmlRpcDoneSelector = @selector(onDocumentsByTag:);
    //			[delegate onDocumentsByTag:ret];
            }
            else if ([method isEqualToString:SyncMethod_DownloadDeletedList])
            {
                xmlRpcDoneSelector = @selector(onDownloadDeletedList:);
    //			[delegate onDownloadDeletedList:ret];
            }
            else if ([method isEqualToString:SyncMethod_UploadDeletedList])
            {
    //            selector = @selector(onUploadDeletedGUIDs:);
                [delegate onUploadDeletedGUIDs:ret];
            }
            else if ([method isEqualToString:SyncMethod_DocumentsByKey])
            {
                xmlRpcDoneSelector = @selector(onDocumentsByKey:);
    //			[delegate onDocumentsByKey:ret];
            }
            else if([method isEqualToString:SyncMethod_DownloadObject])
            {
                xmlRpcDoneSelector = @selector(onDownloadObject:);
    //            [delegate onDownloadObject:ret];
    //            return;
            }
            else if([method isEqualToString:SyncMethod_UploadObject])
            {
                xmlRpcDoneSelector = @selector(onUploadObjectData:);
    //            [delegate onUploadObjectData:ret];
    //            return;
            }
            else if([method isEqualToString:SyncMethod_GetAttachmentList])
            {
                xmlRpcDoneSelector = @selector(onDownloadAttachmentList:);
    //            [delegate onDownloadAttachmentList:ret];
            }
            else if([method isEqualToString:SyncMethod_PostTagList])
            {
                xmlRpcDoneSelector = @selector(onPostTagList:);
    //            [delegate onPostTagList:ret];
            }
            else if([method isEqualToString:SyncMethod_DocumentPostSimpleData])
            {
                xmlRpcDoneSelector = @selector(onDocumentPostSimpleData:);
    //            [delegate onDocumentPostSimpleData:ret];
            }
            else if([method isEqualToString:SyncMethod_AttachmentPostSimpleData])
            {
                xmlRpcDoneSelector = @selector(onAttachmentPostSimpleData:);
    //            [delegate onAttachmentPostSimpleData:ret];
            }
            else if([method isEqualToString:SyncMethod_GetUserInfo])
            {
                xmlRpcDoneSelector = @selector(onCallGetUserInfo:);
    //            [delegate onCallGetUserInfo:ret];
            }
            else if ([method isEqualToString:SyncMethod_GetGropKbGuids])
            {
                xmlRpcDoneSelector = @selector(onCallGetGropList:);
    //            [delegate onCallGetGropList:ret];
            }
            else
            {
                [WizGlobals reportErrorWithString:NSLocalizedString(@"Unknown xml-rpc method!", nil)];
            }
            [self performSelectorInBackground:@selector(delegatePerformXmlRpcDoneSelectorWithObject:) withObject:ret];
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
}

- (BOOL) doExeCuteXml:(NSArray*)args
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    NSURL* url = [args objectAtIndex:0];
    NSString* method = [args objectAtIndex:1];
    id argsRe= [args objectAtIndex:2];
    
    XMLRPCRequest *request = [[XMLRPCRequest alloc] initWithHost:url];
	if (!request)
    {
		return NO;
    }
	//
	[request setMethod:method withObjects:argsRe];
	//
	self.connectionXmlrpc = [XMLRPCConnection sendAsynchronousXMLRPCRequest:request delegate:self];
	//
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	[request release];
	//
    if(nil != self.connectionXmlrpc)
        return YES;
    else
        return NO;
    [pool drain];
}

-(BOOL)executeXmlRpc: (NSURL*) url method: (NSString*)method args:(id)args
{
    [self performSelectorOnMainThread:@selector(doExeCuteXml:) withObject:[NSArray arrayWithObjects:url,method, args, nil] waitUntilDone:NO];
    return YES;
}
-(void) addCommonParams: (NSMutableDictionary*)postParams
{
    if ([WizGlobals WizDeviceIsPad]) {
        [postParams setObject:@"ipad" forKey:@"client_type"];
    }
	else
    {
        [postParams setObject:@"iphone" forKey:@"client_type"];
    }
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


-(BOOL) callDocumentsByKey:(NSString*)keywords 
{
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:keywords forKey:@"key"];
	[postParams setObject:[NSNumber numberWithInt:200] forKey:@"count"];
	[postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByKey args:args];
}

-(BOOL) callDownloadObject:(WizObject*)object startPos:(int)startPos  partSize:(int)partSize{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
    if (object.guid == nil) {
        NSDictionary* dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"download guid is nill",NSLocalizedDescriptionKey,nil];
        NSError* error = [NSError errorWithDomain:WizErrorDomain code:WizGuidIsNilErrorCode userInfo:dictionary];
        [self onError:error];
        [dictionary release];
        return NO;
    }
    [postParams setObject:object.guid forKey:@"obj_guid"];
    [postParams setObject:[object objectType] forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:partSize] forKey:@"part_size"];
    NSArray* args = [NSArray arrayWithObjects:postParams, nil];
    return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadObject args:args];
}


-(BOOL) callUploadObjectData:(WizObject*)object data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams]; 
    [postParams setObject:[NSNumber numberWithInt:objectSize] forKey:@"obj_size"];
    [postParams setObject:object.guid forKey:@"obj_guid"];
    [postParams setObject:[object objectType] forKey:@"obj_type"];
    [postParams setObject:sumMD5 forKey:@"obj_md5"];
    [postParams setObject:[NSNumber numberWithInt:sumPartCount] forKey:@"part_count"];
    [postParams setObject:data forKey:@"data"];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"part_sn"];
    NSString* localMd5 = [WizGlobals md5:data];
    [postParams setObject:localMd5 forKey:@"part_md5"];
    NSUInteger partSize=[data length];
    [postParams setObject:[NSNumber numberWithInt:partSize]   forKey:@"part_size"];
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

-(BOOL) callDocumentPostSimpleData:(WizDocument*)doc withZipMD5:(NSString *)zipMD5  isWithData:(BOOL)isWithData
{
	if (!doc)
		return NO;
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObjectNotNull:doc.guid forKey:@"document_guid"];
    [postParams setObjectNotNull:doc.title forKey:@"document_title"];
    [postParams setObjectNotNull:doc.type forKey:@"document_type"];
    [postParams setObjectNotNull:doc.fileType forKey:@"document_filetype"];
    [postParams setObjectNotNull:doc.dateModified forKey:@"dt_modified"];
    [postParams setObjectNotNull:doc.location forKey:@"document_category"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:1] forKey:@"document_info"];
    [postParams setObjectNotNull:zipMD5 forKey:@"document_zip_md5"];
    [postParams setObjectNotNull:doc.dateCreated forKey:@"dt_created"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:isWithData] forKey:@"with_document_data"];
    [postParams setObjectNotNull:[NSNumber numberWithInt:doc.attachmentCount] forKey:@"document_attachment_count"];
    [postParams setObjectNotNull:[NSNumber numberWithFloat:doc.gpsLatitude] forKey:@"gps_latitude"];
    [postParams setObjectNotNull:[NSNumber numberWithFloat:doc.gpsLongtitude] forKey:@"gps_longitude"];
    NSString* tags = [NSString stringWithString:doc.tagGuids];
    NSString* ss = [tags stringByReplacingOccurrencesOfString:@"*" withString:@";"];
    if(tags != nil)
        [postParams setObjectNotNull:ss forKey:@"document_tag_guids"];
    else
        [postParams setObjectNotNull:tags forKey:@"document_tag_guids"];
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

- (BOOL)callGetGroupKblist
{
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetGropKbGuids args:args];
}
-(void) onError: (id)retObject
{
	if ([retObject isKindOfClass:[NSError class]])
	{
        [WizGlobals toLog:[NSString stringWithFormat:@"%@",retObject]];
        NSError* error = (NSError*)retObject;
        if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain])
        {
            [self.apiManagerDelegate didApiSyncError:self error:error];
        }
        else if (error.code == NSInvaildUrlErrorCode && [error.domain isEqualToString:NSURLErrorDomain])
        {
            [self.apiManagerDelegate didApiSyncError:self error:[WizGlobalError tokenUnActiveError]];
        }
        else if (error.code == NSOvertimeErrorCode && [error.domain isEqualToString:NSURLErrorDomain])
        {
            [self start];
        }
        else if (error.code == NSURLErrorNetworkConnectionLost && [error.domain isEqualToString:NSURLErrorDomain])
        {
            [self cancel];
        }
        else if (error.code == NSUserCancelError && [error.domain isEqualToString:WizErrorDomain]) {
            NSLog(@"canced ---------------------");
            return;
        }
        else if (error.code == NSURLErrorNetworkConnectionLost && [error.domain isEqualToString:NSURLErrorDomain])
        {
            [self.apiManagerDelegate didChangedStatue:self statue:WizSyncStatueError];
        }
        else if (error.code == NSURLErrorNotConnectedToInternet && [error.domain isEqualToString:NSURLErrorDomain])
        {
            [self.apiManagerDelegate didChangedStatue:self statue:WizSyncStatueError];
        }
        else {
            [WizGlobals reportError:retObject];
        }
	}
}
-(void) cancel
{
    busy = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if (self.connectionXmlrpc)
    {
        [self.connectionXmlrpc cancel];
        self.connectionXmlrpc = nil;
    }
    else
    {
        if (self.connectionXmlrpc != nil) {
            [self.connectionXmlrpc cancel];
        }
        [self onError:[NSError errorWithDomain:WizErrorDomain code:NSUserCancelError userInfo:nil]];
    }
}
- (void) didChangeSyncStatue:(WizSyncStatueCode)statue
{
    [self.apiManagerDelegate didChangedStatue:self statue:statue];
}
@end
