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
    NSFileHandle* fileHandle;
    BOOL busy;
}
@property (nonatomic, retain) NSFileHandle* fileHandle;
@property (nonatomic, retain) NSString* objType;
@property (nonatomic, retain) NSString* objGuid;
@property (assign) BOOL busy;
@property int currentPos;
-(void) onError: (id)retObject;
-(BOOL) downloadObject;
- (void) downloadOver:(BOOL)unzipIsSucceed;
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