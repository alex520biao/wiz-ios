//
//  WizVerifyAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizVerifyAccount.h"
@implementation WizVerifyAccount
@synthesize busy;
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
	[super onError:retObject];
	busy = NO;
    [self.verifyDelegate didVerifyAccountFaild];
}


-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
	[self callClientLogout];
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
	return [self callClientLogin:self.accountUserId accountPassword:self.accountPassword];
}

@end
