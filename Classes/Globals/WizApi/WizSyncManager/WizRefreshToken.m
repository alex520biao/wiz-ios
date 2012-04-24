//
//  WizRefreshToken.m
//  Wiz
//
//  Created by 朝 董 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizRefreshToken.h"
#import "WizNotification.h"
#import "WizGlobalData.h"
#import "WizSettings.h"
#import "WizAccountManager.h"

@implementation WizRefreshToken
- (void) dealloc
{
    [super dealloc];
}
- (void) onError:(id)retObject
{
    [super onError:retObject];
}
- (BOOL) refresh
{
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* password  = [[WizAccountManager defaultManager] accountPasswordByUserId:accountUserId];
    return [self callClientLogin:accountUserId accountPassword:password];
}
-(void) onClientLogin: (id)retObject
{
	if ([retObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* userInfo = retObject;
        NSNumber* userPoints = [userInfo objectForKey:@"user_points"];
        NSNumber* userLevel = [userInfo objectForKey:@"user_level"];
        NSString* userLevelName = [userInfo objectForKey:@"user_level_name"];
        NSString* userType = [userInfo objectForKey:@"user_type"];
        WizSettings* defalutSettings = [WizSettings defaultSettings];
        [defalutSettings setUserPoints:[userPoints longLongValue]];
        [defalutSettings setUserLevel:[userLevel longLongValue]];
        [defalutSettings setUserLevelName:userLevelName];
        [defalutSettings setUserType:userType];
        [WizNotificationCenter postMessageRefreshToken:retObject];
    }
}
@end
