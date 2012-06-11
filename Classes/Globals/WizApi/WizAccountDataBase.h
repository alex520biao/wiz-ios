//
//  WizAccountDataBase.h
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizSettingsDbDelegate.h"

#define WizEntityAccount    @"WizAccount"
#define WizEntityGroup      @"WizGroup"
#define WizEntitySetting    @"WizSetting"


@interface WizAccountDataBase : NSObject <WizSettingsDbDelegate>
- (WizAccount*) accountFromDataBase:(NSString*)userId;
- (BOOL) updateAccount:(WizAccount*)account;
- (BOOL) updateAccount:(NSString*)userId    password:(NSString*)password;
- (NSArray*) allAccounts;
//
- (BOOL) updateGroup:(NSDictionary*)dic  userId:(NSString*)userId;
- (NSArray*) allGroupByAccount:(NSString*)userId;
//
- (NSString*) defaultAccountUserId;
- (BOOL) setWizDefaultAccountUserId:(NSString*)userId;
- (void) deleteAllGroups:(NSString*)userId;
@end
