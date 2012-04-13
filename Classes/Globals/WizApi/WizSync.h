//
//  WizSync.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"





@class XMLRPCConnection;

@interface WizSync : WizApi {
	BOOL busy;
	NSMutableArray* documentsForUpdated;
    //wiz-dzpqzb test
    NSMutableArray* download;
    NSMutableArray* attachmentsForUpdated;
    BOOL isStopByUser;
    
}

@property (assign) BOOL busy;
@property (nonatomic, retain) NSMutableArray* documentsForUpdated;
@property (nonatomic, retain) NSMutableArray* attachmentsForUpdated;
@property (assign) BOOL isStopByUser;
@property (nonatomic, retain) NSMutableArray* download;
- (void) stopSync;
- (BOOL) isSyncingg;
-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout: (id)retObject;
-(void) onAllCategories: (id)retObject;
-(void) onAllTags: (id)retObject;
-(void) onDownloadDocumentList: (id)retObject;
-(void) onDownloadDeletedList: (id)retObject;
-(void) onUploadDeletedGUIDs: (id)retObject;
-(BOOL) uploadAllAttachments;
-(void) onCallGetUserInfo:(id)retObject;
- (void) onPostTagList:(id)retObject;
-(void) onDownloadDeletedList: (id)retObject;
-(void) cancel;
//
//wiz-dzpqzb
-(BOOL) startSync;

//wiz-dzpqzb test
-(void) downAllDocument;
-(BOOL) uploadAllObject;
@end
