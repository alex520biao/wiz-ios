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
#import "WizSync.h"
@interface WizSyncManager : NSObject <WizRefreshDelegate,WizApiManagerDelegate>
{
    id <WizSyncDescriptionDelegate> displayDelegate;
}
@property (nonatomic, assign) id<WizSyncDescriptionDelegate> displayDelegate;
//
- (void) resignActive;
+ (id) shareManager;
- (void) refreshToken;
//
- (WizSync*) syncDataForGroup:(NSString*)kbguid;
- (void) registerAciveGroup:(NSString*)kbguid;
- (WizSync*) activeGroupSync;
- (void) refreshGroupsData;
@end
