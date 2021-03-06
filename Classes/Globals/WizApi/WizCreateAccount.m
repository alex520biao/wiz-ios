//
//  WizCreateAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizCreateAccount.h"
#import "WizSettings.h"


@implementation WizCreateAccount
@synthesize accountPassword;
@synthesize accountUserId;
@synthesize createAccountDelegate;
-(void) onError: (id)retObject
{
	[WizGlobals reportError:retObject];
	busy = NO;
    [self.createAccountDelegate didCreateAccountFaild];
}
-(void) onCreateAccount: (id)retObject
{
	busy = NO;
    [self.createAccountDelegate didCreateAccountSucceed];
}
- (BOOL) createAccount
{
	if (self.busy)
		return NO;
	busy = YES;
    self.accountURL = [[WizSettings defaultSettings] wizServerUrl];
	return [self callCreateAccount:self.accountUserId password:self.accountPassword];
}
@end
