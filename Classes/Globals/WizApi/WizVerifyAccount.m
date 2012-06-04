//
//  WizVerifyAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizVerifyAccount.h"
#import "WizSettings.h"
@implementation WizVerifyAccount
@synthesize accountPassword;
@synthesize accountUserId;
@synthesize verifyDelegate;
- (void) dealloc
{
    [accountUserId release];
    [accountPassword release];
    [verifyDelegate release];
    [super dealloc];
}
-(void) onError: (id)retObject
{
    [self.verifyDelegate didVerifyAccountFaild];
	[WizGlobals reportError:retObject];
	busy = NO;
}
-(void) onClientLogin: (id)retObject
{   busy = NO;
    [self.verifyDelegate didVerifyAccountSucceed];
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
	busy = NO;
}


- (BOOL) verifyAccount
{
	if (self.busy)
		return NO;
	busy = YES;
    self.accountURL = [[WizSettings defaultSettings] wizServerUrl];
	return [self callClientLogin:self.accountUserId accountPassword:self.accountPassword];
}

@end
