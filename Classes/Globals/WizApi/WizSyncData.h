//
//  WizSyncData.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizUploadObjet.h"
#import "WizRefreshToken.h"
#import "WizDownloadObject.h"
#import "WizSyncInfo.h"

@class WizSyncSearch;

@interface NSMutableDictionary (WizSyncData)
- (WizUploadObjet*) shareUploader;
- (WizDownloadObject*) shareDownloader;
- (WizRefreshToken*) shareRefreshTokener;
- (WizSyncInfo*) shareSyncInfo;
- (WizSyncSearch*) shareSearch;
- (void) removeShareUploder;
- (void) removeShareDownload;
- (void) removeShareRefreshTokener;
- (void) removeShareSyncInfo;
@end
