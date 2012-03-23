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
#import "WizSettings.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizMisc.h"
#import "WizSync.h"
#import "WizNotification.h"


#define SyncMethod_ClientLogin @"accounts.clientLogin"  
#define SyncMethod_ClientLogout @"accounts.clientLogout"  
#define SyncMethod_CreateAccount @"accounts.createAccount"  
#define SyncMethod_GetAllCategories @"category.getAll"  
#define SyncMethod_GetAllTags @"tag.getList"  
#define SyncMethod_DownloadDocumentList @"document.getSimpleList"  
#define SyncMethod_DocumentsByCategory @"document.getSimpleListByCategory"  
#define SyncMethod_DocumentsByTag @"document.getSimpleListByTag"  
#define SyncMethod_DownloadMobileData @"document.getMobileData"  
#define SyncMethod_UploadMobileData @"document.postSimpleData"  
#define SyncMethod_DownloadDeletedList @"deleted.getList"  
#define SyncMethod_UploadDeletedList @"deleted.postList"  
#define SyncMethod_DocumentsByKey @"document.getSimpleListByKey"  
#define SyncMethod_ChangeAccountPassword @"accounts.changePassword"  
#define SyncMethod_DownloadObject @"data.download"  
#define SyncMethod_UploadObject @"data.upload"  
#define SyncMethod_GetAttachmentList @"attachment.getList"  
#define SyncMethod_PostTagList @"tag.postList"  
#define SyncMethod_DocumentPostSimpleData @"document.postSimpleData"  
#define SyncMethod_AttachmentPostSimpleData @"attachment.postSimpleData"  
#define SyncMethod_GetUserInfo @"wiz.getInfo"
 
#define WizGlobalStopSync @"wiz_stop_sync"  
#define PARTSIZE 10*1024
#define MD5PART 10*1024
#define CONSTDEFAULTCOUNT 200

@implementation WizApi
@synthesize token;
@synthesize kbguid;
@synthesize accountURL;
@synthesize apiURL;
@synthesize accountUserId;
@synthesize accountPassword;
@synthesize currentUploadDocumentGUID;
@synthesize currentDownloadDocumentGUID;
@synthesize currentObjType;
@synthesize currentStarPos;
@synthesize currentDownloadObjectGUID;
@synthesize cureentUploadObjectGUID;
@synthesize currentUploadTempFilePath;
@synthesize connectionXmlrpc;
-(id) initWithAccount: (NSString*)userId password: (NSString*)password
{
	if (self = [super init])
	{
		self.accountUserId = userId;
		self.accountPassword = password;
		//
		NSURL* urlAccount = [[NSURL alloc] initWithString:@"http://service.wiz.cn/wizkm/xmlrpc"];
		self.accountURL = urlAccount;
		[urlAccount release];
	}
	//
	return self;
}
-(void) dealloc
{
	self.token = nil;
	self.kbguid = nil;
	self.accountURL = nil;
	self.apiURL = nil;
	//
	self.accountUserId = nil;
	self.accountPassword = nil;
	//
	self.currentUploadDocumentGUID = nil;
	//
    self.currentDownloadObjectGUID = nil;
    self.currentObjType = nil;
    self.currentStarPos = nil;
	[super dealloc];
}



- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method
{
	if (succeeded && ![ret isKindOfClass:[NSError class]])
	{
		if ([method isEqualToString:SyncMethod_ClientLogin])
		{
			[self onClientLogin:ret];
		}
		else if ([method isEqualToString:SyncMethod_ClientLogout])
		{
			[self onClientLogout:ret];
		}
		else if ([method isEqualToString:SyncMethod_CreateAccount])
		{
			[self onCreateAccount:ret];
		}
        else if ([method isEqualToString:SyncMethod_ChangeAccountPassword])
        {
            [self onChangePassword:ret];
        }
		else if ([method isEqualToString:SyncMethod_GetAllCategories])
		{
			[self onAllCategories:ret];
		}
		else if ([method isEqualToString:SyncMethod_GetAllTags])
		{
			[self onAllTags:ret];
		}
		else if ([method isEqualToString:SyncMethod_DownloadDocumentList])
		{
			[self onDownloadDocumentList:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByCategory])
		{
			[self onDocumentsByCategory:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByTag])
		{
			[self onDocumentsByTag:ret];
		}
		else if ([method isEqualToString:SyncMethod_DownloadMobileData])
		{
			[self onDownloadMobileData:ret];
		}
		else if ([method isEqualToString:SyncMethod_DownloadDeletedList])
		{
			[self onDownloadDeletedList:ret];
		}
		else if ([method isEqualToString:SyncMethod_UploadDeletedList])
		{
			[self onUploadDeletedGUIDs:ret];
		}
		else if ([method isEqualToString:SyncMethod_DocumentsByKey])
		{
			[self onDocumentsByKey:ret];
		}
        else if([method isEqualToString:SyncMethod_DownloadObject])
        {
            [self onDownloadObject:ret];
            return;
        }
        else if([method isEqualToString:SyncMethod_UploadObject])
        {
            [self onUploadObjectData:ret];
            return;
        }
        else if([method isEqualToString:SyncMethod_GetAttachmentList])
        {
            [self onDownloadAttachmentList:ret];
        }
        else if([method isEqualToString:SyncMethod_PostTagList])
        {
            [self onPostTagList:ret];
        }
        else if([method isEqualToString:SyncMethod_DocumentPostSimpleData])
        {
            [self onDocumentPostSimpleData:ret];
        }
        else if([method isEqualToString:SyncMethod_AttachmentPostSimpleData])
        {
            [self onAttachmentPostSimpleData:ret];
        }
        else if([method isEqualToString:SyncMethod_GetUserInfo])
        {
            [self onCallGetUserInfo:ret];
        } 
        else
		{
			[WizGlobals reportErrorWithString:NSLocalizedString(@"Unknown xml-rpc method!", nil)];
		}
        
	}
	else 
	{
		
        [self onError: ret];
	}
    self.connectionXmlrpc = nil;
	NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:method, @"method", ret, @"ret", [NSNumber numberWithBool:succeeded], @"succeeded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncXmlRpcDoneNotificationPrefix] object: nil userInfo: userInfo];
	[userInfo release];
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

-(BOOL) callClientLogin
{
	if (self.accountUserId == nil || [self.accountUserId length] == 0)
		return NO;
	//
	if (self.accountPassword == nil || [self.accountPassword length] == 0)
	{
		self.accountPassword = [WizSettings accountPasswordByUserId: accountUserId];
	}
	if (self.accountPassword == nil || [self.accountPassword length] == 0)
		return NO;
	//
	self.token = nil;
	
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:self.accountUserId forKey:@"user_id"];
	[postParams setObject:self.accountPassword forKey:@"password"];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncLoginBegin];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ClientLogin args:args];
}
-(void) onClientLogin: (id)retObject
{
	NSDictionary* userInfo = retObject;
	//
	// save values returned by getUserInfo into current blog
	self.token = [userInfo valueForKey:@"token"];
	//
	NSURL* urlAPI = [[NSURL alloc] initWithString:[userInfo valueForKey:@"kapi_url"]];
	self.apiURL = urlAPI;
	[urlAPI release];
	self.kbguid = [userInfo valueForKey:@"kb_guid"];
    
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSNumber* userPoints = [userInfo objectForKey:@"user_points"];
    NSNumber* userLevel = [userInfo objectForKey:@"user_level"];
    NSString* userLevelName = [userInfo objectForKey:@"user_level_name"];
    NSString* userType = [userInfo objectForKey:@"user_type"];
    
    [index setUserLevel:[userLevel intValue]];
    [index setUserLevelName:userLevelName];
    [index setUserType:userType];
    [index setUserPoints:[userPoints longLongValue]];
    

    [self postSyncLoginEnd];
}
-(BOOL) callClientLogout
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	[self postSyncLogoutBegin];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ClientLogout args:args];
}
-(void) onClientLogout: (id)retObject
{
    [self postSyncLogoutEnd];
}

-(BOOL) callGetUserInfo
{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_GetUserInfo args:args];
}
-(void) onCallGetUserInfo:(id)retObject
{
    NSDictionary* dic = retObject;
    NSNumber* trafficLimit = [dic objectForKey:@"traffic_limit"];
    NSNumber* trafficUsage = [dic objectForKey:@"traffic_usage"];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setUserTrafficLimit:[trafficLimit intValue]];
    [index setuserTrafficUsage:[trafficUsage intValue]];
    
}

-(BOOL) callAllCategories
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetAllCategoriesBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAllCategories args:args];
}

-(void) onAllCategories: (id)retObject
{
	NSDictionary* obj = retObject;
	//
	// save values returned by getUserInfo into current blog
	NSString* categories = [obj valueForKey:@"categories"];
	categories = [categories stringByAppendingString:@"*/My Mobiles/"];
	//
	NSArray* arrCategory = [categories componentsSeparatedByString:@"*"];
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index updateLocations: arrCategory];
    [self postSyncGetAllCategoriesEnd];
}
-(BOOL) callAllTags
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	//
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    int64_t version = [index tagVersion];
	if(version)
    {
        [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
    }
    else
    {
        [postParams setObject:@"0" forKey:@"version"];
    }
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetTagsListBegin:version requsetCount:[self listCount]];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAllTags args:args];
}

-(void) onAllTags: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    int64_t newVer = 0;
    for (NSDictionary* dict in obj)
    {
        NSString* verString = [dict valueForKey:@"version"];
        int64_t ver = [verString longLongValue];
        
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    //
    if(0 != newVer)
        [index setTageVersion:newVer + 1];
    [self postSyncGetTagsListEnd:1];
	[index updateTags:obj];
}


-(BOOL) callPostTagList
{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	//
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* tagList =  [index tagsWillPostList];
    NSMutableArray* tagTemp = [[NSMutableArray alloc] initWithCapacity:[tagList count]];
    for(WizTag* each in tagList)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary alloc] init];
        [dic setObject:each.guid forKey:@"tag_guid"];
        if(nil !=each.parentGUID)
            [dic setObject:each.parentGUID forKey:@"tag_group_guid"];
        [dic setObject:each.name forKey:@"tag_name"];
        [dic setObject:each.description forKey:@"tag_description"];
        [dic setObject:[WizGlobals sqlTimeStringToDate:each.dtInfoModified] forKey:@"dt_info_modified"];
        [tagTemp addObject:dic];
        [dic release];
        
    }
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObject:tagTemp forKey:@"tags"];
    [tagTemp release];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncUploadTagListBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_PostTagList args:args];
    
}

-(void) onPostTagList:(id)retObject
{
    [self postSyncUploadTagListEnd];
}

-(BOOL) callDownloadDocumentList
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
    
    int64_t version = [index documentVersion];
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
	//
    [self postSyncGetDocumentListBegin:version requsetCount:[self listCount]];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadDocumentList args:args];
}
-(void) onDownloadDocumentList: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	[index updateDocuments:obj];
	//
	if ([index downloadAllList])
	{
		int64_t newVer = 0;
		for (NSDictionary* dict in obj)
		{
			NSString* verString = [dict valueForKey:@"version"];
           
			int64_t ver = [verString longLongValue];
			if (ver > newVer)
			{
				newVer = ver;
			}
		}
		//
        if(0 != newVer)
        {
            [index setDocumentVersion:newVer + 1];
            
        }
        [self postSyncGetDocumentListEnd:newVer+1];
	}
}

//wiz-dzpqzb

-(BOOL) callDownloadAttachmentList
{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
    //
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [postParams setObject:[NSNumber numberWithInt:[self listCount]] forKey:@"count"];
    [postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
   
    
    int64_t version = [index attachmentVersion];
    if (version) {
        [postParams setObject:[NSNumber numberWithInt:version] forKey:@"version"];
    }
    
    else
    {
        [postParams setObject:[NSNumber numberWithInt:0] forKey:@"version"];
    }
    
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetAttachmentListBegin:version requsetCount:[self listCount]];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAttachmentList args:args];
}

-(void) onDownloadAttachmentList:(id)retObject {
    NSArray* dicArray = retObject;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSMutableArray* dicMutableArray = [dicArray mutableCopy];
    for(NSDictionary* each in dicMutableArray )
    {
        [each setValue:[NSNumber numberWithInt:1] forKey:@"sever_changed"];
    }
    
    [index updateAttachementList:dicArray];
    int64_t newVer = 0;
    for (NSDictionary* dict in dicArray)
    {
        NSString* verString = [dict valueForKey:@"version"];
        int64_t ver = [verString longLongValue];
        
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    //
    if(0 != newVer)
        [index setAttachmentVersion:newVer + 1];
    [dicMutableArray release];
    [self postSyncGetAttachmentListEnd:1];
}


-(int) listCount
{
	return 200;
}

-(BOOL) callDownloadDeletedList
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
	[postParams setObject:[index deletedGUIDVersionString] forKey:@"version"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    BOOL ret = [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadDeletedList args:args];
    
    [self postSyncDeletedListBegin];
	return  ret;
}
-(void) onDownloadDeletedList: (id)retObject
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	int64_t newVer = 0;
	NSArray* arr = retObject;
	for (NSDictionary* dict in arr)
	{
		NSString* verString = [dict valueForKey:@"version"];
		NSString* guid = [dict valueForKey:@"deleted_guid"];
		NSString* type = [dict valueForKey:@"guid_type"];
		//
		int64_t ver = [verString longLongValue];
		//
		if (ver > newVer)
			newVer = ver;
		//
		if ([type isEqualToString:@"document"])
		{
			[index deleteDocument:guid];
		}
		else if ([type isEqualToString:@"tag"])
		{
			[index deleteTag:guid];
		}
        if ([type isEqualToString:@"attachment"])
        {
            [index deleteAttachment:guid];
        }
	}
	
	//
    [self postSyncDeletedListEnd];
	[index setDeletedGUIDVersion:newVer + 1];
}

-(BOOL) callDocumentsByCategory:(NSString*)location
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:location forKey:@"category"];
	[postParams setObject:[NSNumber numberWithInt:1000] forKey:@"count"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetDocumentByCategoryBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByCategory args:args];
	
}
-(void) onDocumentsByCategory: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	[index updateDocuments:obj];
    [self postSyncGetDocumentByCategoryEnd];
}
-(BOOL) callDocumentsByTag:(NSString*)tagGUID
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:tagGUID forKey:@"tag_guid"];
	[postParams setObject:[NSNumber numberWithInt:1000] forKey:@"count"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetDocumentByTagBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByTag args:args];
}
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncGetDocumentByTagEnd];
	[index updateDocuments:obj];
}

-(BOOL) callDocumentsByKey:(NSString*)keywords attributes:(NSString*)attributes
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:keywords forKey:@"key"];
	[postParams setObject:[NSNumber numberWithInt:200] forKey:@"count"];
	[postParams setObject:[NSNumber numberWithInt:0] forKey:@"first"];
	//[postParams setObject:attributes forKey:@"attributes"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncGetDocumentByKeyBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentsByKey args:args];
}
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncGetDocumentByKeyEnd];
	[index updateDocuments:obj];
}


//wiz-dqzpqzb  new api to download data
-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
    self.currentDownloadObjectGUID = objectGUID;
    self.currentStarPos = [NSNumber numberWithInt:startPos];
    self.currentObjType = objType;
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams];
    [postParams setObject:objectGUID forKey:@"obj_guid"];
    [postParams setObject:objType forKey:@"obj_type"];
    [postParams setObject:[NSNumber numberWithInt:startPos] forKey:@"start_pos"];
    [postParams setObject:[NSNumber numberWithInt:PARTSIZE] forKey:@"part_size"];
    NSArray* args = [NSArray arrayWithObjects:postParams, nil];
    return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadObject args:args];
}

-(NSMutableDictionary*) onDownloadObject:(id)retObject {
    NSDictionary* obj = retObject;
    NSData* data = [obj valueForKey:@"data"];
    NSNumber* objSize = [obj valueForKey:@"obj_size"];
    NSNumber* eofPre = [obj valueForKey:@"eof"];
    BOOL eof = [eofPre intValue]? YES:NO;
    NSString* serverMd5 = [obj valueForKey:@"part_md5"];
    NSString* localMd5 = [WizApi md5:data];
    NSNumber* succeed = [NSNumber numberWithInt:[serverMd5 isEqualToString:localMd5]?1:0];
    
    if([succeed intValue])
    {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        
        NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:self.currentDownloadObjectGUID];
        //
        [WizGlobals ensurePathExists:objectPath];
        NSString* fileNamePath = [objectPath stringByAppendingPathComponent:@"temp.zip"];
        NSNumber* currentObjectSize = [index appendObjectDataByPath:fileNamePath data:data]; //返回当前文件大小
        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setObject:succeed forKey:TypeOfDownloadDocumentDicMsgIsSucceed];
        [result setObject:objSize forKey:TypeOfDownloadDocumentDicMsgObjSize];
        if(eof) {
            if ([index  updateObjectDataByPath:fileNamePath objectGuid:self.currentDownloadObjectGUID]) {
                [result setObject:[NSNumber numberWithInt:1] forKey:TypeOfDownloadDocumentDicMsgUnzipIsSucceed];
            }
            else {
                [result setObject:[NSNumber numberWithInt:0] forKey:TypeOfDownloadDocumentDicMsgUnzipIsSucceed];
            }
        }
        [result setObject:currentObjectSize forKey:TypeOfDownloadDocumentDicMsgCurrentSize];
        return [result autorelease];

    }
    else
    {

        NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
        [result setObject:succeed forKey:@"is_succeed"];
        [result setObject:objSize forKey:@"obj_size"];
        [result setObject:[NSNumber numberWithInt:0] forKey:@"current_size"];
        return [result autorelease];
    }
    
}



-(BOOL) callDownloadMobileData:(NSString*)documentGUID
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	self.currentDownloadDocumentGUID = documentGUID;
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:documentGUID forKey:@"document_guid"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadMobileData args:args];
}
-(void) onDownloadMobileData: (id)retObject
{
	NSDictionary* obj = retObject;
	//
	// save values returned by getUserInfo into current blog
	NSData* data = [obj valueForKey:@"document_zip_data"];
	NSString* documentGUID = [obj valueForKey:@"document_guid"];
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	[index updateDocumentData:data documentGUID:documentGUID];
}


//wiz-dzpqzb
-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount
{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
    [self addCommonParams:postParams]; 
    [postParams setObject:[NSNumber numberWithLong:objectSize] forKey:@"obj_size"];
    [postParams setObject:objectGUID forKey:@"obj_guid"];
    [postParams setObject:objectType forKey:@"obj_type"];
    [postParams setObject:sumMD5 forKey:@"obj_md5"];
    [postParams setObject:[NSNumber numberWithInt:sumPartCount] forKey:@"part_count"];
    [postParams setObject:data forKey:@"data"];
    [postParams setObject:[NSNumber numberWithInt:count] forKey:@"part_sn"];
    NSString* localMd5 = [WizApi md5:data];
    [postParams setObject:localMd5 forKey:@"part_md5"];
    NSUInteger partSize=[data length];
    [postParams setObject:[NSNumber numberWithUnsignedInteger:partSize]   forKey:@"part_size"];

    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadObject args:args];
}





-(BOOL) onUploadObjectData:(id) retObject {
    NSMutableDictionary* obj = (NSMutableDictionary*)retObject;
    BOOL succeed = ([[obj valueForKey:@"return_code"] isEqualToString:@"200"])? YES:NO;
    return succeed;
}


-(BOOL) callUploadMobileData:(NSString*)documentGUID
{
	if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	WizDocument* doc = [index documentFromGUID:documentGUID];
	if (!doc)
		return NO;
	//
	NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:documentGUID fileExt:doc.fileType];
	if (![WizGlobals pathFileExists:documentOrgFileName])
		return NO;
	//
	NSString* text = nil;
	NSData* data = nil;
	//
	if ([doc.fileType isEqualToString:@".txt"])
	{
		NSError* err = nil;
		text = [[NSString alloc ] initWithContentsOfFile:documentOrgFileName encoding:NSUnicodeStringEncoding error:&err];
		if (text == nil)
		{
			[WizGlobals reportError:err];
			TOLOG([[err localizedDescription] UTF8String]);
			return NO;
		}
	}
	else if ([doc.fileType isEqualToString:@".png"]
			 || [doc.fileType isEqualToString:@".jpg"]) 
	{
		NSString* documentMemoFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:documentGUID fileExt:@".txt"];
		if ([WizGlobals pathFileExists:documentMemoFileName])
		{
			NSError* err = nil;
			text = [[NSString alloc ] initWithContentsOfFile:documentMemoFileName encoding:NSUnicodeStringEncoding error:&err];
		}
		//
		data = [[NSData alloc] initWithContentsOfFile:documentOrgFileName];
	}
    
	//
	self.currentUploadDocumentGUID = documentGUID;
	//
	NSDate* dateCreated = [WizGlobals sqlTimeStringToDate:doc.dateCreated];
	NSDate* dateModified = [WizGlobals sqlTimeStringToDate:doc.dateModified];
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:doc.guid forKey:@"document_guid"];
	[postParams setObject:doc.title forKey:@"document_title"];
	[postParams setObject:doc.url forKey:@"document_url"];
	[postParams setObject:doc.type forKey:@"document_type"];
	[postParams setObject:doc.fileType forKey:@"document_filetype"];
	[postParams setObject:dateCreated forKey:@"dt_created"];
	[postParams setObject:dateModified forKey:@"dt_modified"];
	[postParams setObject:doc.location forKey:@"document_category"];
    NSString* string = [NSString stringWithString:doc.tagGuids];
    if(string != nil)
        [postParams setObject:[string stringByReplacingOccurrencesOfString:@"*" withString:@";"] forKey:@"document_tag_guids"];
    
   
    
	//
	if (text != nil)
	{
		[postParams setObject:text forKey:@"document_body"];
	}
	else 
	{
		[postParams setObject:@"" forKey:@"document_body"];
	}
	//
	if (data != nil)
	{
		[postParams setObject:data forKey:@"document_data"];
	}
	else 
	{
		[postParams setObject:@"" forKey:@"document_data"];
	}
	//
	[text release];
	[data release];
	//
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadMobileData args:args];
}
-(void) onUploadMobileData: (id)retObject
{
	if (self.currentUploadDocumentGUID != nil)
	{
		WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
		//
		[index setDocumentLocalChanged:self.currentUploadDocumentGUID changed:NO];
	}
}
-(BOOL) callUploadDeletedGUIDs
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	NSArray* arr = [index deletedGUIDsForUpload];
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:arr forKey:@"deleteds"];
	//
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
    [self postSyncUploadDeletedListBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadDeletedList args:args];
	
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncUploadDeletedListEnd];
	[index clearDeletedGUIDs];
}

- (BOOL) callChangePassword:(NSString*)password
{
    if (self.accountUserId == nil || [self.accountUserId length] == 0)
    {

		return NO;
    }
	self.token = nil;
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:self.accountUserId forKey:TypeOfChangePasswordAccountUserId];
    NSString* oldPassword = [WizSettings accountPasswordByUserId:self.accountUserId];
    [postParams setObject:oldPassword forKey:TypeOfChangePasswordOldPassword];
    [postParams setObject:password forKey:TypeOfChangePasswordNewPassword];
    [self addCommonParams:postParams];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.accountURL method:SyncMethod_ChangeAccountPassword args:args];
}

-(BOOL) callCreateAccount
{
	if (self.accountUserId == nil || [self.accountUserId length] == 0)
		return NO;
	//
	if (self.accountPassword == nil || [self.accountPassword length] == 0)
		return NO;
	//
	self.token = nil;
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:self.accountUserId forKey:@"user_id"];
	[postParams setObject:self.accountPassword forKey:@"password"];
    [postParams setObject:@"wiz_iphone" forKey:@"product_name"];
    [postParams setObject:@"f6d9193f" forKey:@"invite_code"];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.accountURL method:SyncMethod_CreateAccount args:args];
}
- (void) onChangePassword:(id)retObject
{
    
}
-(void) onCreateAccount: (id)retObject
{
}

-(BOOL) callDocumentPostSimpleData:(NSString *)documentGUID withZipMD5:(NSString *)zipMD5
{
    if (self.token == nil || [self.token length] == 0) {
		return NO;
	}
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	WizDocument* doc = [index documentFromGUID:documentGUID];
	if (!doc)
		return NO;
	//
	self.currentUploadDocumentGUID = documentGUID;
	//
	NSDate* dateCreated = [WizGlobals sqlTimeStringToDate:doc.dateCreated];
	NSDate* dateModified = [WizGlobals sqlTimeStringToDate:doc.dateModified];
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
    [postParams setObject:[NSNumber numberWithInt:doc.attachmentCount] forKey:@"attachment_count"];
	//
    NSString* tags = [NSString stringWithString:doc.tagGuids];
    NSString* ss = [tags stringByReplacingOccurrencesOfString:@"*" withString:@";"];
    if(tags != nil)
        [postParams setObject:ss forKey:@"document_tag_guids"];
    else
        [postParams setObject:tags forKey:@"document_tag_guids"];
	//
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DocumentPostSimpleData args:args];
}

-(void) onDocumentPostSimpleData:(id)retObject
{
}


-(BOOL) callAttachmentPostSimpleData:(NSString *)attachmentGUID
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    NSDictionary* md5s = [index attachmentFileMd5:attachmentGUID];
    NSString* dataMD5 = [md5s objectForKey:@"data_file_md5"];
    if (dataMD5 == nil) {
        return NO;
    }
    NSString* ziwMD5 = [md5s objectForKey:@"ziw_file_md5"];
    WizDocumentAttach* attach = [index attachmentFromGUID:attachmentGUID];
    NSDate* dateModified = [WizGlobals sqlTimeStringToDate:attach.attachmentModifiedDate];
    //fill the post info
    NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
    [postParams setObject:attach.attachmentGuid             forKey:@"attachment_guid"];
    [postParams setObject:attach.attachmentDocumentGuid           forKey:@"attachment_document_guid"];
    [postParams setObject:[attach.attachmentName stringByReplacingOccurrencesOfString:@":" withString:@"-"]            forKey:@"attachment_name"];
    [postParams setObject:dateModified                  forKey:@"dt_modified"];
    [postParams setObject:dataMD5                       forKey:@"data_md5"];
    [postParams setObject:ziwMD5                        forKey:@"attachment_zip_md5"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_info"];
    [postParams setObject:[NSNumber numberWithInt:1]    forKey:@"attachment_data"];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
    [self postSyncUploadAttachmentInfoBegin];
	return [self executeXmlRpc:self.apiURL method:SyncMethod_AttachmentPostSimpleData args:args];
}

- (void) onAttachmentPostSimpleData:(id)retObject
{
    [self postSyncUploadAttachmentInfoEnd];
}


-(void) onError: (id)retObject
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncXmlRpcErrorNotificationPrefix] object: nil];
	if ([retObject isKindOfClass:[NSError class]])
	{  
        NSError* error = (NSError*)retObject;
        if ([error.domain isEqualToString:@"come.effigent.iphone.parseerror"] && [error.localizedDescription isEqualToString:NSLocalizedString(@"Login time out or login in other places, please retry login!", nil)]) {
            return;
        }
        if ([error.domain isEqualToString:WIZERRORDOMAIN] && [error.localizedDescription isEqualToString:WIZABORTNETERROR]) {
            return;
        }
		[WizGlobals reportError:retObject];
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
