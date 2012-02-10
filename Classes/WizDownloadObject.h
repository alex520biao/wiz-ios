//
//  WizDownloadObject.h
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

extern NSString* SyncMethod_DownloadProcessPartBeginWithGuid ;
extern NSString* SyncMethod_DownloadProcessPartEndWithGuid   ;

@interface WizDownloadObject : WizApi {
    NSString* objType;
    NSString* objGuid;
    int currentPos;
    BOOL busy;
    BOOL isLogin;
    id owner;
}
@property (nonatomic, retain) NSString* objType;
@property (nonatomic, retain) NSString* objGuid;
@property (nonatomic, retain) id owner;
@property (assign) BOOL busy;
@property (assign) BOOL isLogin;
@property int currentPos;
-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(NSMutableDictionary*) onDownloadObject:(id)retObject;
-(BOOL) downloadObject;
- (void) downloadOver;
@end

@interface WizDownloadDocument : WizDownloadObject {
}
- (BOOL) downloadDocument:(NSString*)documentGUID;
- (BOOL) downloadWithoutLogin:(NSURL*)apiUrl kbguid:(NSString*)kbGuid token:(NSString*)token_ documentGUID:(NSString*)documentGUID;
@end

@interface WizDownloadAttachment : WizDownloadObject {
}
- (BOOL) downloadAttachment:(NSString*)attachmentGUID;
- (BOOL) downloadWithoutLogin:(NSURL*)apiUrl kbguid:(NSString*)kbGuid token:(NSString*)token_ downloadAttachment:(NSString*)attachmentGUID;
@end