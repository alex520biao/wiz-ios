//
//  WizDownloadRecentDocuments.m
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizDownloadRecentDocuments.h"


@implementation WizDownloadRecentDocuments

@synthesize busy;

-(void) onError: (id)retObject
{
	[super onError:retObject];
	
	busy = NO;
}

-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
	
	[self callDownloadDocumentList];
}

-(void) onDownloadDocumentList:(id)retObject
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
