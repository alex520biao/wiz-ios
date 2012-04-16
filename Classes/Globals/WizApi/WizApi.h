//
//  WizSyncBase.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString *WizSyncBeginNotificationPrefix;
extern NSString *WizSyncEndNotificationPrefix;
extern NSString *WizSyncXmlRpcErrorNotificationPrefix;
extern NSString* WizSyncXmlRpcDoneNotificationPrefix;
extern NSString* WizSyncXmlRpcDonlowadDoneNotificationPrefix;
extern NSString* WizSyncXmlRpcUploadDoneNotificationPrefix;
extern NSString* SyncMethod_ClientLogin;
extern NSString* SyncMethod_ClientLogout;
extern NSString* SyncMethod_CreateAccount;
extern NSString* SyncMethod_GetAllCategories;
extern NSString* SyncMethod_GetAllTags;
extern NSString* SyncMethod_DownloadDocumentList;
extern NSString* SyncMethod_DocumentsByCategory;
extern NSString* SyncMethod_DocumentsByTag;
extern NSString* SyncMethod_DownloadMobileData;
extern NSString* SyncMethod_UploadMobileData;
extern NSString* SyncMethod_DownloadDeletedList;
extern NSString* SyncMethod_UploadDeletedList;
extern NSString* SyncMethod_DocumentsByKey;
extern NSString* SyncMethod_DownloadObject;
extern NSString* SyncMethod_UploadObject;
extern NSString* SyncMethod_GetAttachmentList;
extern NSString* SyncMethod_PostTagList;
extern NSString* SyncMethod_DocumentPostSimpleData;
extern NSString* SyncMethod_AttachmentPostSimpleData;
extern NSString* WizGlobalSyncProcessInfo;
extern NSString* SyncMethod_GetUserInfo;
extern NSString* WizGlobalStopSync;
extern NSString* SyncMethod_ChangeAccountPassword;
@class XMLRPCConnection;
@class WizDocument;
@class WizDocumentAttach;



@interface WizApi : NSObject <UIAlertViewDelegate>{
	NSString* token;
	NSString* kbguid;
	NSURL* accountURL;
	NSURL* apiURL;
	//
	NSString* accountUserId;
	NSString* accountPassword;
	//
	NSString* currentUploadDocumentGUID;
	NSString* currentDownloadDocumentGUID;
    
    //wiz-dzpqzb
    NSString* currentDownloadObjectGUID;
    
    NSNumber* currentStarPos;
    NSString* currentObjType;
    NSString* currentUploadTempFilePath;
    NSString* cureentUploadObjectGUID;
    XMLRPCConnection* connectionXmlrpc;
}

@property (nonatomic, retain) NSString* currentUploadTempFilePath;
@property (nonatomic, retain) NSString* cureentUploadObjectGUID;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSURL* accountURL;
@property (nonatomic, retain) NSURL* apiURL;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
@property (nonatomic, retain) NSString* currentUploadDocumentGUID;
@property (nonatomic, retain) NSString* currentDownloadDocumentGUID;
@property (nonatomic, retain) NSString* currentObjType;
@property (nonatomic, retain) NSNumber* currentStarPos;
@property (nonatomic, retain) NSString* currentDownloadObjectGUID;
@property (retain) XMLRPCConnection* connectionXmlrpc;

-(id) initWithAccount: (NSString*)userId password: (NSString*)password;


-(BOOL)executeXmlRpc: (NSURL*) url method: (NSString*)method args:(id)args ;
-(void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method;

-(void) addCommonParams: (NSMutableDictionary*)postParams;
//
-(void) onError: (id)retObject;
//
-(BOOL) callClientLogin;
-(void) onClientLogin: (id)retObject;

-(BOOL) callGetUserInfo;
-(void) onCallGetUserInfo:(id)retObject;

-(BOOL) callClientLogout;
-(void) onClientLogout: (id)retObject;

-(BOOL) callAllCategories;
-(void) onAllCategories: (id)retObject;

-(BOOL) callAllTags;
-(void) onAllTags: (id)retObject;

-(BOOL) callDownloadDocumentList;
-(void) onDownloadDocumentList: (id)retObject;

-(BOOL) callCreateAccount;
-(void) onCreateAccount: (id)retObject;
//
-(BOOL) callDocumentsByCategory:(NSString*)location;
-(void) onDocumentsByCategory: (id)retObject;

-(BOOL) callDocumentsByTag:(NSString*)tagGUID;
-(void) onDocumentsByTag: (id)retObject;
//
-(BOOL) callDownloadMobileData:(NSString*)documentGUID;
-(void) onDownloadMobileData: (id)retObject;

//wiz-qzpqzb
-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType;
-(NSMutableDictionary*) onDownloadObject:(id) retObject;


-(BOOL) callUploadMobileData:(NSString*)documentGUID;
-(void) onUploadMobileData: (id)retObject;

//wiz-dzpqzb
-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5 sumPartCount:(int)sumPartCount;
-(void) onUploadObjectData:(id) retObject;
-(BOOL) callDownloadDeletedList;
-(void) onDownloadDeletedList: (id)retObject;

-(BOOL) callUploadDeletedGUIDs;
-(void) onUploadDeletedGUIDs: (id)retObject;
//
-(BOOL) callDocumentsByKey:(NSString*)keywords attributes:(NSString*)attributes;
-(void) onDocumentsByKey: (id)retObject;
//
-(BOOL) callDownloadAttachmentList;
-(void) onDownloadAttachmentList:(id)retObject;


// 
-(BOOL) callPostTagList;
-(void) onPostTagList:(id) retObject;
//
- (BOOL) callChangePassword:(NSString*)password;
- (void) onChangePassword:(id)retObject;
//
-(BOOL) callDocumentPostSimpleData:(NSString*) documentGUID withZipMD5:(NSString*) zipMD5;
-(void) onDocumentPostSimpleData:(id) retObject;
-(BOOL) callAttachmentPostSimpleData:(NSString*) attachmentGUID;
-(void) onAttachmentPostSimpleData:(id) retObject;

-(void) postSyncProcessInfoToDefaultCenter:(NSString*) methodName total:(NSNumber*) total current:(NSNumber*)current;
-(int) listCount;
- (void) postSyncUploadObject:(int) total current:(int)current objectGUID:(NSString*) objectGUID objectType:(NSString*) objectType;
- (void) postSyncDoloadObject:(int) total current:(int)current objectGUID:(NSString*) objectGUID objectType:(NSString*) objectType;

-(void) cancel;

-(NSString*) notificationName: (NSString *)prefix;
+(NSString*) notificationName: (NSString *)prefix accountUserId:(NSString*)accountUserId;
+(NSString*) md5:(NSData *)input;
+(NSString*)fileMD5:(NSString*)path ;
@end
