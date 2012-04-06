//
//  WizAccountManager.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAccountManager : NSObject
+ (NSString*)activeAccountUserId;
+ (NSString*) passwordForAccount:(NSString*)accountUserId;
+ (BOOL) addAccount:(NSString*)userId   password:(NSString*)password;
+ (void) registerActiveAccount:(NSString*)userId;
@end
