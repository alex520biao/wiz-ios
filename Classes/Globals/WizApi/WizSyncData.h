//
//  WizSyncData.h
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import <Foundation/Foundation.h>
#import "WizSyncInfo.h"
#import "WizDownloadObject.h"
#import "WizUploadObjet.h"
#import "WizRefreshToken.h"

@interface WizSyncData : NSObject
- (WizSyncInfo*) syncInfoData;
- (WizDownloadObject*) downloadData;
- (WizUploadObjet*) uploadData;
- (WizRefreshToken*) refreshData;
- (BOOL) isApiWorking:(WizApi*)api;
- (BOOL) isApiOnErroring:(WizApi*)api;
- (void) doWorkBegainApi:(WizApi*)api;
- (void) doWorkEndApi:(WizApi*)api;
- (void) doErrorBegainApi:(WizApi*)api;
- (void) doErrorEndApi:(WizApi*)api;
- (NSArray*) workArrayFroGuid:(NSString*)guid;
- (NSArray*) errorQueque;
+ (WizSyncData*) shareSyncData;
- (BOOL) isDownloadingObject:(WizObject*)object;
- (BOOL) isUploadingObject:(WizObject*)object;
@end
