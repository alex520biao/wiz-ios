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
@synthesize accountUserId;
@synthesize accountPassword;
@synthesize connectionXmlrpc;
-(int) listCount
{
	return 30;
}

-(id) initWithAccount: (NSString*)userId password: (NSString*)password
{
	if (self = [super init])
	{
		self.accountUserId = userId;
		self.accountPassword = password;
		//
//#ifdef _DEBUG
//        NSURL* urlAccount = [[NSURL alloc] initWithString:@"http://192.168.0.119:8800/wiz/xmlrpc"];
//		
//#else
//        NSURL* urlAccount = [[NSURL alloc] initWithString:@"http://service.wiz.cn/wizkm/xmlrpc"];
//#endif
        NSURL* urlAccount = [[NSURL alloc] initWithString:@"http://192.168.79.1:8800/wiz/xmlrpc"];
		self.accountURL = urlAccount;
		[urlAccount release];
	}
	//
	return self;
}
-(void) dealloc
{
    [token release];
    [kbguid release];
    [accountURL release];
    [apiURL release];
    [accountUserId release];
    [accountPassword release];
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
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:self.accountUserId forKey:@"user_id"];
	[postParams setObject:self.accountPassword forKey:@"password"];
	[self addCommonParams:postParams];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
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

-(BOOL) callAllTags
{
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAllTags args:args];
}



-(BOOL) callPostTagList
{
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_PostTagList args:args];
    
}

-(BOOL) callDownloadDocumentList
{
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadDocumentList args:args];
}

//wiz-dzpqzb

-(BOOL) callDownloadAttachmentList
{
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_GetAttachmentList args:args];
}


-(BOOL) callDownloadDeletedList
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[self addCommonParams:postParams];
	[postParams setObject:[NSNumber numberWithInt:[self listCount] ] forKey:@"count"];
	[postParams setObject:[index deletedGUIDVersionString] forKey:@"version"];
	
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	//
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

//wiz-dqzpqzb  new api to download data
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
	//
	return [self executeXmlRpc:self.apiURL method:SyncMethod_DownloadMobileData args:args];
}

//wiz-dzpqzb
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_UploadDeletedList args:args];
	
}

- (BOOL) callChangePassword:(NSString*)password
{
    NSMutableDictionary* postParams = [NSMutableDictionary dictionary];
    [postParams setObject:self.accountUserId forKey:TypeOfChangePasswordAccountUserId];
    NSString* oldPassword = [WizSettings accountPasswordByUserId:self.accountUserId];
    [postParams setObject:oldPassword forKey:TypeOfChangePasswordOldPassword];
    [postParams setObject:password forKey:TypeOfChangePasswordNewPassword];
    [self addCommonParams:postParams];
    NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
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
	NSMutableDictionary *postParams = [NSMutableDictionary dictionary];
	[postParams setObject:self.accountUserId forKey:@"user_id"];
	[postParams setObject:self.accountPassword forKey:@"password"];
    [postParams setObject:@"wiz_iphone" forKey:@"product_name"];
    [postParams setObject:@"f6d9193f" forKey:@"invite_code"];
	[self addCommonParams:postParams];
	NSArray *args = [NSArray arrayWithObjects:postParams, nil ];
	return [self executeXmlRpc:self.accountURL method:SyncMethod_CreateAccount args:args];
}

-(BOOL) callDocumentPostSimpleData:(NSString *)documentGUID withZipMD5:(NSString *)zipMD5
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	WizDocument* doc = [index documentFromGUID:documentGUID];
	if (!doc)
		return NO;
	//
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
	return [self executeXmlRpc:self.apiURL method:SyncMethod_AttachmentPostSimpleData args:args];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSString* password=nil;
        for (UIView* each in [alertView subviews]) {
            if ([each isKindOfClass:[UITextField class]]) {
                UITextField* text = (UITextField*)each;
                password = text.text;
                [WizSettings addAccount:self.accountUserId password:password];
                [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
            }
        }
    }
    [self release];
}
-(void) onError: (id)retObject
{
	if ([retObject isKindOfClass:[NSError class]])
	{  
        NSError* error = (NSError*)retObject;
        NSLog(@"error is %@",error);
        if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain])
        {
            [WizNotificationCenter postMessageTokenUnactiveError];
        }
//        else if (error.code == 301 && [error.domain isEqualToString:@"error.wiz.cn"])
//        {
//            static UIAlertView* prompt = nil;
//            WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//            if ([index isOpened]) {
//                if (prompt == nil) {
//                    prompt = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid password!", nil)
//                                                                     message:@"\n\n" 
//                                                                    delegate:nil 
//                                                           cancelButtonTitle:WizStrCancel 
//                                                           otherButtonTitles:WizStrOK, nil];
//                    prompt.tag = 10001;
//                    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(27.0, 60.0, 230.0, 25.0)]; 
//                    textField.secureTextEntry = YES;
//                    [textField setBackgroundColor:[UIColor whiteColor]];
//                    [textField setPlaceholder:WizStrPassword];
//                    [prompt addSubview:textField];
//                    [textField release];
//                    [prompt setTransform:CGAffineTransformMakeTranslation(0.0, -100.0)];
//                    
//                }
//                prompt.delegate = self;
//                [self retain];
//                [prompt show];
//                return;
//            }
//            else {
//                [WizGlobals reportError:error];
//            }
//        }
        else if ([error.domain isEqualToString:WIZERRORDOMAIN] && [error.localizedDescription isEqualToString:WIZABORTNETERROR]) {
            return;
        }
        else if (error.code == -101)
        {
            return;
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
