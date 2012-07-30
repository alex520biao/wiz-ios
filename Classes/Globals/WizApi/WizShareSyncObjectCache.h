//
//  WizShareSyncObjectCache.h
//  Wiz
//
//  Created by wiz on 12-7-25.
//
//

#import <Foundation/Foundation.h>
#import "WizSyncObjectSourceDelegate.h"
#import "WizUploadObjet.h"
#import "WizDownloadObject.h"
#import "WizRefreshToken.h"
#import "WizSyncSearch.h"
#import "WizSyncInfo.h"
@interface WizShareSyncObjectCache : NSObject <WizSyncObjectSourceDelegate>
+ (WizShareSyncObjectCache*) shareSyncObjectCache;
- (WizUploadObjet*) shareUploadTool;
- (WizDownloadObject*) shareDownloadTool;
- (WizRefreshToken*) shareRefreshTokener;
- (WizSyncSearch*) shareSearch;
- (WizSyncInfo*) shareSyncInfo;
- (BOOL) isDownloadingWizObject:(WizObject*)obj;
- (BOOL) isUploadingWizObject:(WizObject*)obj;
- (void) addShouldDownloadWizObject:(WizObject*)obj;
- (void) addShouldUploadWizObject:(WizObject*)obj;
- (NSArray*) allErrorWizApi;
- (NSArray*) allWorkWizApi;
- (void) addErrorWizApi:(WizApi*)errorApi;
- (void) addWorkWizApi:(WizApi*)workApi;
- (void) clearWorkWizApi:(WizApi*)workApi;
- (void) clearErrorWizApi:(WizApi*)errorApi;
- (void) clearAllErrorWizApi;
- (void) clearAllWorkWizApi;
- (void) stopAllWizApi;
- (void) removeSyncingWizObject:(WizObject*)obj;
@end
