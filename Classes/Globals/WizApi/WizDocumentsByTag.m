//
//  WizDocumentsByTag.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizDocumentsByTag.h"


@implementation WizDocumentsByTag

@synthesize busy;
@synthesize tag_guid;

-(void) dealloc
{
	[tag_guid release];
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
	
	[self callDocumentsByTag:self.tag_guid];
}

-(void) onDocumentsByTag:(id)retObject
{
	[super onDocumentsByTag:retObject];
	//
	[self callClientLogout];
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
	
	busy = NO;
}


- (BOOL) downloadDocumentList
{
	if (self.busy)
		return NO;
	//
	busy = YES;
	
	return [self callClientLogin];
}

@end
