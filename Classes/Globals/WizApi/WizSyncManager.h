//
//  WizSyncManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizSyncDescriptionDelegate.h"
#import "WizRefreshDelegate.h"
#import "WizSyncSearchDelegate.h"
#import "WizApiManagerDelegate.h"
@interface WizSyncManager : NSObject <WizRefreshDelegate,WizApiManagerDelegate>
{
    id <WizSyncDescriptionDelegate> displayDelegate;
}
@property (nonatomic, assign) id<WizSyncDescriptionDelegate> displayDelegate;
//upload
- (BOOL) isUploadingWizObject:(WizObject*)wizobject;
- (BOOL) uploadWizObject:(WizObject*)object;
//download
- (BOOL) isDownloadingWizobject:(WizObject*)object;
- (void) downloadWizObject:(WizObject*)object;
//
- (BOOL) startSyncInfo;
//
- (void) resignActive;
+ (id) shareManager;
//
- (void) automicSyncData;
- (BOOL) isSyncing;
- (void) stopSync;
//
- (void) searchKeywords:(NSString*)keywords  searchDelegate:(id<WizSyncSearchDelegate>)searchDelegate;
@end
