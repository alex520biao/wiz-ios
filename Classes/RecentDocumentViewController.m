//
//  RecentDocumentViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "RecentDocumentViewController.h"

#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizDownloadRecentDocuments.h"
#import "EditAccountViewController.h"
#import "WizSettings.h"
@implementation RecentDocumentViewController


- (NSArray*) reloadDocuments
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	return [index recentDocuments];
}

- (BOOL) isBusy
{
	WizDownloadRecentDocuments* downloader = [[WizGlobalData sharedData] downloadRecentDocumentsData:self.accountUserId];
	return downloader.busy;
}

- (NSString*) titleForView
{
	return [NSString stringWithString:NSLocalizedString(@"Recent Notes", nil)];
}

- (void) syncDocuments
{
	WizDownloadRecentDocuments* downloader = [[WizGlobalData sharedData] downloadRecentDocumentsData:self.accountUserId];
	[downloader downloadDocumentList];
}

- (NSString*) syncDocumentsXmlRpcMethod
{
	return SyncMethod_DownloadDocumentList;
}

-(void) setupAccount
{
    NSArray* accounts = [WizSettings accounts];
    EditAccountViewController *editAccountView = [[EditAccountViewController alloc] initWithNibName:@"EditAccountViewController" bundle:nil];
    
    editAccountView.accountUserId = [WizSettings accountUserIdAtIndex:accounts index:0];
    editAccountView.accountPassword = [WizSettings accountPasswordAtIndex:accounts index:0];
    
    [self.navigationController pushViewController:editAccountView animated:YES];
    [editAccountView release];
}

- (void) viewDidLoad
{
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize 
                                                                                   target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = anotherButton;
    [anotherButton release];
    [super viewDidLoad];
}

@end
