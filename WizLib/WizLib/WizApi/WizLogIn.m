//
//  WizLogIn.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizLogIn.h"
#import "WizActiveUserManager.h"
@implementation WizLogIn
- (void) logIn:(NSString*)userId  passWord:(NSString*)password
{
    self.accountUserId = userId;
    self.accountPassword = password;
    [self callClientLogin];
}
- (void) onClientLogin:(id)retObject
{
    [WizActiveUserManager setActiveApiInfo:self.kbguid token:self.token apiUrl:self.apiURL];
}
@end
