//
//  TagViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "TagViewController.h"

#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizDocumentsByTag.h"

@implementation TagViewController

@synthesize tag;

- (void) dealloc
{
	self.tag = nil;
	//
	[super dealloc];
}

- (NSArray*) reloadDocuments
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	return [index documentsByTag:self.tag.guid];
}

- (BOOL) isBusy
{
	WizDocumentsByTag* downloader = [[WizGlobalData sharedData] documentsByTagData:self.accountUserId];
	return downloader.busy;
}

- (NSString*) titleForView
{
    documents = [[self reloadDocuments] mutableCopy];
	return self.tag.name;
}

- (void) syncDocuments
{
	WizDocumentsByTag* downloader = [[WizGlobalData sharedData] documentsByTagData:self.accountUserId];
	downloader.tag_guid = self.tag.guid;
	[downloader downloadDocumentList];
}

- (NSString*) syncDocumentsXmlRpcMethod
{
	return SyncMethod_DocumentsByTag;
}
@end
