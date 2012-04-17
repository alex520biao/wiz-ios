//
//  WizDocumentsByKey.m
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizDocumentsByKey.h"


@implementation WizDocumentsByKey

@synthesize busy;
@synthesize keywords;

-(void) dealloc
{
    [keywords release];
	[super dealloc];
}

-(void) onError: (id)retObject
{
	[super onError:retObject];
	
	busy = NO;
}

-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
	
	[self callDocumentsByKey:self.keywords attributes:@""];
}

-(void) onDocumentsByKey:(id)retObject
{
	[super onDocumentsByKey:retObject];
	//
	[self callClientLogout];
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
	
	busy = NO;
}


- (BOOL) searchDocuments
{
	if (self.busy)
		return NO;
	//
	if (self.keywords == nil || [self.keywords length] == 0)
		return NO;
	//
	busy = YES;
	
	return [self callClientLogin];
}

@end
