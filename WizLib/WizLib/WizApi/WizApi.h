//
//  WizSyncBase.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMLRPCConnection;
@class WizDocument;
@class WizDocumentAttach;
@interface WizApi : NSObject {
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
-(void) onDownloadObject:(id) retObject;


-(BOOL) callUploadMobileData:(NSString*)documentGUID;
-(void) onUploadMobileData: (id)retObject;

//wiz-dzpqzb
-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5 sumPartCount:(int)sumPartCount;
-(BOOL) onUploadObjectData:(id) retObject;
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
- (BOOL) callChangePassword:(NSString*)password;
- (void) onChangePassword:(id)retObject;
-(BOOL) callDocumentPostSimpleData:(NSString*) documentGUID withZipMD5:(NSString*) zipMD5;
-(void) onDocumentPostSimpleData:(id) retObject;
-(BOOL) callAttachmentPostSimpleData:(NSString*) attachmentGUID;
-(void) onAttachmentPostSimpleData:(id) retObject;
-(int) listCount;
-(void) cancel;
@end
