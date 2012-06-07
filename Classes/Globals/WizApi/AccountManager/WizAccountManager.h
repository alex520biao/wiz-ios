//
//  WizAccountManager.h
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizAccount;
@class WizAccountDataBase;
@interface WizAccountManager : NSObject
{
    WizAccountDataBase<WizSettingsDbDelegate>* accountSettingsDataBase;
}
@property (readonly, atomic) WizAccountDataBase<WizSettingsDbDelegate>* accountSettingsDataBase;
+ (WizAccountManager *) defaultManager;
- (WizAccount*) activeAccount;
-(void) updateAccount: (NSString*)userId password:(NSString*)password;
- (NSArray*) accounts;
- (void) registerActiveAccount:(NSString*)accountUserId;
- (void) updateGroup:(NSDictionary*)dic;
- (NSString*) activeAccountUserId;
- (NSString*) activeAccountPassword;
- (NSArray*) activeAccountGroups;
- (NSString*) activeAccountGroupKbguid;
- (void) registerActiveGroup:(WizGroup*)group;
- (WizGroup*) activeAccountActiveGroup;
@end
