//
//  WizChangePassword.m
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizChangePassword.h"
#import "WizChangePasswordController.h"
@implementation WizChangePassword
-(void) onError: (id)retObject
{
	busy = NO;
    [self.changePasswordDelegate didChangedPasswordFaild];
	[super onError:retObject];
}
- (void) onChangePassword:(id)retObject
{
    [self.changePasswordDelegate didChangedPasswordSucceed];
    busy = NO;
}
- (BOOL) changeAccountPassword:(NSString *)accountUserId oldPassword:(NSString *)oldPassword newPassword:(NSString *)newPassword
{
    return [self callChangePassword:accountUserId oldPassword:oldPassword newPassword:newPassword];
}
@end
