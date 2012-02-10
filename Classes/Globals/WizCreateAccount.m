//
//  WizCreateAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizCreateAccount.h"


@implementation WizCreateAccount

@synthesize busy;

-(void) onError: (id)retObject
{
	[super onError:retObject];
	
	busy = NO;
}
-(void) onCreateAccount: (id)retObject
{
	busy = NO;
}

- (BOOL) createAccount
{
	if (self.busy)
		return NO;
	//
	busy = YES;
	//
	return [self callCreateAccount];
}

/*
 -(BOOL) clientLoginOnly
 {
 if (self.busy)
 return NO;
 //
 busy = YES;
 syncAll = NO;
 //
 return [self clientLogin];
 }
 -(BOOL) createAccountOnly
 {
 if (self.busy)
 return NO;
 //
 busy = YES;
 syncAll = NO;
 //
 return [self createAccount];
 }
 */


@end
