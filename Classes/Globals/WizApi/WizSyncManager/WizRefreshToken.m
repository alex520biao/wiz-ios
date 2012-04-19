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
#import "WizIndex.h"
@implementation WizRefreshToken
@synthesize accountUserId;
@synthesize accountPassword;
- (void) dealloc
{
    [accountPassword release];
    [accountUserId release];
    [super dealloc];
}
- (void) onError:(id)retObject
{
    [super onError:retObject];
}
- (BOOL) refresh
{
    return [self callClientLogin:self.accountUserId accountPassword:self.accountPassword];
}
-(void) onClientLogin: (id)retObject
{
	if ([retObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* userInfo = retObject;
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        NSNumber* userPoints = [userInfo objectForKey:@"user_points"];
        NSNumber* userLevel = [userInfo objectForKey:@"user_level"];
        NSString* userLevelName = [userInfo objectForKey:@"user_level_name"];
        NSString* userType = [userInfo objectForKey:@"user_type"];
        [index setUserLevel:[userLevel intValue]];
        [index setUserLevelName:userLevelName];
        [index setUserType:userType];
        [index setUserPoints:[userPoints longLongValue]];
        [WizNotificationCenter postMessageRefreshToken:retObject];
    }
}
@end
