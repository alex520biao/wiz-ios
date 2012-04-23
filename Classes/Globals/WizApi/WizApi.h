//
//  WizSyncBase.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizDocument;
@class WizAttachment;

@protocol WizApiDelegate <NSObject>
@optional
- (void) onCallGetUserInfo:(id)retObject;
- (void) onAllCategories: (id)retObject;
- (void) onDownloadDocumentList: (id)retObject;
- (void) onAllTags: (id)retObject;
- (void) onDownloadAttachmentList:(id)retObject;
- (void) onDownloadDeletedList: (id)retObject;
- (void) onDocumentsByCategory: (id)retObject;
- (void) onDocumentsByTag: (id)retObject;
- (void) onDocumentsByKey: (id)retObject;
- (void) onUploadDeletedGUIDs: (id)retObjec;
//
- (void) onClientLogin:(id)retObject;
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
@interface WizApi : NSObject <WizApiDelegate>
{
	NSString* token;
	NSString* kbguid;
	NSURL* accountURL;
	NSURL* apiURL;
   XMLRPCConnection* connectionXmlrpc;
    id<WizApiDelegate> delegate;
}
@property (nonatomic, retain) NSURL* accountURL;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* kbguid;
@property (nonatomic, retain) NSURL* apiURL;
@property (retain) XMLRPCConnection* connectionXmlrpc;
@property (nonatomic, retain) id<WizApiDelegate> delegate;
-(BOOL) callClientLogin:(NSString*)accountUserId accountPassword:(NSString*)accountPassword;
-(BOOL) callClientLogout;

-(BOOL) callGetUserInfo;

-(BOOL) callAllCategories;
-(BOOL) callAllTags:(int64_t)version;

-(BOOL) callPostTagList:(NSArray*)tagList;

-(BOOL) callDownloadDocumentList:(int64_t)version;

-(BOOL) callDownloadAttachmentList:(int64_t)version;

-(BOOL) callDownloadDeletedList:(int64_t)version;
-(BOOL) callDocumentsByCategory:(NSString*)location;

-(BOOL) callDocumentsByTag:(NSString*)tagGUID;

-(BOOL) callDocumentsByKey:(NSString*)keywords attributes:(NSString*)attributes;

-(BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType  partSize:(int)partSize;

-(BOOL) callDownloadMobileData:(NSString*)documentGUID;

-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount;

-(BOOL) callUploadDeletedGUIDs:(NSArray*)deleteGuids;

- (BOOL) callChangePassword:(NSString*)accountUserId  oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;

-(BOOL) callCreateAccount:(NSString*)accountUserId  password:(NSString*)accountPassword;
-(BOOL) callDocumentPostSimpleData:(WizDocument*)doc withZipMD5:(NSString *)zipMD5;
-(BOOL) callAttachmentPostSimpleData:(WizAttachment*)attach  dataMd5:(NSString*)dataMD5     ziwMd5:(NSString*)ziwMD5;
-(void) onError: (id)retObject;
-(void) cancel;

@end
