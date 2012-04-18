//
//  WizSyncBase.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizApiDelegate <NSObject>
@optional
-(void) onCallGetUserInfo:(id)retObject;
-(void) onAllCategories: (id)retObject;
-(void) onDownloadDocumentList: (id)retObject;
-(void) onAllTags: (id)retObject;
-(void) onDownloadAttachmentList:(id)retObject;
-(void) onDownloadDeletedList: (id)retObject;
-(void) onDocumentsByCategory: (id)retObject;
-(void) onDocumentsByTag: (id)retObject;
-(void) onDocumentsByKey: (id)retObject;
-(void) onUploadDeletedGUIDs: (id)retObjec;
//
- (void) onClientLogout:(id)retObject;
- (void) onCreateAccount:(id)retObject;
- (void) onChangePassword:(id)retObject;
//
- (void) onUploadObjectData:(id)retObject;
- (void) onPostTagList:(id)retObject;
- (void) onDocumentPostSimpleData:(id)retObject;
- (void) onAttachmentPostSimpleData:(id)retObject;
- (void) onDownloadObject:(id)retObject;
@end

@class XMLRPCConnection;
@interface WizApi : NSObject <UIAlertViewDelegate, WizApiDelegate>{
	NSString* token;
	NSString* kbguid;
	NSURL* accountURL;
	NSURL* apiURL;
	NSString* accountUserId;
	NSString* accountPassword;
    
    XMLRPCConnection* connectionXmlrpc;
}

@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSURL* accountURL;
@property (nonatomic, retain) NSURL* apiURL;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
@property (retain) XMLRPCConnection* connectionXmlrpc;

-(id) initWithAccount: (NSString*)userId password: (NSString*)password;

-(void) onError: (id)retObject;
//
-(BOOL) callClientLogin;

-(BOOL) callGetUserInfo;
   
-(BOOL) callClientLogout;

-(BOOL) callAllCategories;

-(BOOL) callAllTags;

-(BOOL) callDownloadDocumentList;

-(BOOL) callCreateAccount;
//
-(BOOL) callDocumentsByCategory:(NSString*)location;

-(BOOL) callDocumentsByTag:(NSString*)tagGUID;
//
-(BOOL) callDownloadMobileData:(NSString*)documentGUID;

//wiz-qzpqzb
-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType  partSize:(int)partSize;
//wiz-dzpqzb
-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5 sumPartCount:(int)sumPartCount;
-(BOOL) callDownloadDeletedList;

-(BOOL) callUploadDeletedGUIDs;
//
-(BOOL) callDocumentsByKey:(NSString*)keywords attributes:(NSString*)attributes;
//
-(BOOL) callDownloadAttachmentList;


// 
-(BOOL) callPostTagList;
//
- (BOOL) callChangePassword:(NSString*)password;
//
-(BOOL) callDocumentPostSimpleData:(NSString*) documentGUID withZipMD5:(NSString*) zipMD5;
-(BOOL) callAttachmentPostSimpleData:(NSString*) attachmentGUID;

-(void) cancel;

@end
