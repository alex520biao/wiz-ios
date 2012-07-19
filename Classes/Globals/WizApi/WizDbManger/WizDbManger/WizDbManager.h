//
//  WizDbManager.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDbDelegate.h"
#import "WizAbstractDbDelegate.h"
#import "WizSettingsDbDelegate.h"
@interface WizDbManager : NSObject
+ (id) shareDbManager;
- (id<WizDbDelegate>) shareDataBase;
- (id<WizDbDelegate>) getWizDataBase:(NSString*)accountUserId  groupId:(NSString*)groupId;
- (id<WizAbstractDbDelegate>) getWizTempDataBase:(NSString*)accountUserId;
- (id<WizSettingsDbDelegate>) getWizSettingsDataBase;
- (void) removeUnactiveDatabase:(NSString*)userId;
@end