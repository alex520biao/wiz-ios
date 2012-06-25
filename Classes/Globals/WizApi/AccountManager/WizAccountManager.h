//
//  WizAccountManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSettingsDbDelegate.h"
@class WizAccount;
@class WizGroup;
@interface WizAccountManager : NSObject
+ (WizAccountManager *) defaultManager;

- (BOOL) updateAccount: (NSString*)userId password:(NSString*)password;
- (NSArray*) accounts;

- (BOOL) logoutAccount:(NSString*)userId;
- (BOOL) removeAccount:(NSString*)userId;
- (BOOL) registerActiveAccount:(NSString*)accountUserId;
- (NSString*) activeAccountUserId;
- (NSString*) activeAccountPassword;



- (NSArray*) activeAccountGroups;
- (NSString*) activeAccountGroupKbguid;
- (BOOL) registerActiveGroup:(NSString*)kbGuid;
- (NSString*)defualtAccountUserId;

- (BOOL) updateGroups:(NSArray*)groupArray;
- (BOOL) updatePrivateGroups:(NSString*)kbguid accountUserId:(NSString*)userId;
- (WizGroup*)activeAccountActiveGroup;
- (BOOL) isAccountExist:(NSString*)accountUserId;
@end
