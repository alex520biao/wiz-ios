//
//  WizApi.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizApiDelegate
- (void) onClientLogin:(id)ret;
//
- (void) onDownloadDocumentList: (id)retObject;
//
- (void) onDowloadObject:(id)retObject;
//
- (void) onUploadObject:(id)retObject;
@end

@class XMLRPCConnection;
@interface WizApi : NSObject <WizApiDelegate>
{
    XMLRPCConnection* connectionXmlrpc;
    BOOL busy;
}
@property (retain) XMLRPCConnection* connectionXmlrpc;
@property BOOL busy;
- (BOOL)executeXmlRpc: (NSURL*) url method: (NSString*)method args:(id)args ;
- (void)xmlrpcDone: (XMLRPCConnection *)connection isSucceeded: (BOOL)succeeded retObject: (id)ret forMethod: (NSString *)method;
- (void) onError: (id)retObject;
- (BOOL) startSync;
//
- (BOOL) callClientLogin;
//
- (BOOL) callDownloadDocumentList;
//
- (BOOL) callDownloadObject:(NSString *)objectGUID startPos:(int)startPos objType:(NSString*) objType;
//
-(BOOL) callUploadObjectData:(NSString *)objectGUID objectType:(NSString *)objectType  data:(NSData*) data objectSize:(long)objectSize count:(int)count sumMD5:(NSString*) sumMD5  sumPartCount:(int)sumPartCount;
@end
