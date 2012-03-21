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

-(void) onError: (id)retObject
{
	[super onError:retObject];
	
	busy = NO;
}


-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];

	[self callClientLogout];
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
	//
	busy = YES;
	
	return [self callClientLogin];
}

@end
