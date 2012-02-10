//
//  FolderViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/13/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "FolderViewController.h"

#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizDocumentsByLocation.h"


@implementation FolderViewController

@synthesize location;

- (void) dealloc
{
	self.location = nil;
	//
	[super dealloc];
}

- (NSArray*) reloadDocuments
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	return [index documentsByLocation:self.location];
}

- (BOOL) isBusy
{
	WizDocumentsByLocation* downloader = [[WizGlobalData sharedData] documentsByLocationData:self.accountUserId];
	return downloader.busy;
}

- (NSString*) titleForView
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	documents =  [[index documentsByLocation:self.location] mutableCopy];
	return self.location;
}

- (void) syncDocuments
{
	WizDocumentsByLocation* downloader = [[WizGlobalData sharedData] documentsByLocationData:self.accountUserId];
	downloader.location = self.location;
	[downloader downloadDocumentList];
}
- (NSString*) syncDocumentsXmlRpcMethod
{
	return SyncMethod_DocumentsByCategory;
}


@end
