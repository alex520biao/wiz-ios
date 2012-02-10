//
//  WizSyncBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"
@class WizUploadDocument;
@class WizUploadAttachment;
@class WizDownloadDocument;
@protocol WizSyncBaseMethod <NSObject>
@optional
-(void) prepareSyncArray;
-(BOOL) callSyncMethod;
@end

@interface WizSyncBase : WizApi <WizSyncBaseMethod>
{
    BOOL busy;
    NSMutableArray* downloadArray;
    NSMutableArray* uploadArray;
    NSMutableArray* uploadAttachArray;
    WizDownloadDocument* downloaderDoc;
    WizUploadAttachment* uploaderAttachment;
    WizUploadDocument* uploaderDocument;
    BOOL isStopByUser;
}

@property (readonly) BOOL busy;
@property (nonatomic, retain) NSMutableArray* downloadArray;
@property (nonatomic, retain) NSMutableArray* uploadArray;
@property (nonatomic, retain) NSMutableArray* uploadAttachArray;
@property (nonatomic, retain) WizDownloadDocument* downloaderDoc;
@property (nonatomic, retain) WizUploadAttachment* uploaderAttachment;
@property (nonatomic, retain) WizUploadDocument* uploaderDocument;
@property (assign)     BOOL isStopByUser;
-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout:(id)retObject;
-(BOOL) startSync;
-(BOOL) uploadAllObject;
@end