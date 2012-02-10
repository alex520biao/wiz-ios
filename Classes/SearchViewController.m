//
//  SearchViewController.m
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchResultViewController.h"
#import "DetailViewController.h"

#import "Globals/WizDocumentsByKey.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizGlobals.h"
#import "Globals/WizIndex.h"

#import "CommonString.h"


@implementation SearchViewController

@synthesize accountUserId;
@synthesize accountPassword;

@synthesize searchTextTableViewCell;
@synthesize searchLocalTableViewCell;
@synthesize searchNowTableViewCell;
@synthesize searchTextField;
@synthesize searchLocalSwitch;
@synthesize waitAlertView;
@synthesize detailViewController;
	
#pragma mark -
#pragma mark View lifecycle



- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = WizStrSearch;
	//
	//
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
	if (WizDeviceIsPad())
	{
		UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	}	
}


- (void)viewDidUnload {
    [super viewDidUnload];
	
	self.searchTextTableViewCell = nil;
	self.searchLocalTableViewCell = nil;
	self.searchNowTableViewCell = nil;
	self.searchTextField = nil;
	self.searchLocalSwitch = nil;
	self.waitAlertView = nil;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (0 == section)
		return 3;
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
			return self.searchTextTableViewCell;
		else if (1 == indexPath.row)
			return self.searchLocalTableViewCell;
		else if (2 == indexPath.row)
			return self.searchNowTableViewCell;
	}
    return nil;
}



#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}



- (void) showSearchResult
{
	NSString* keywords = self.searchTextField.text;
	if (keywords == nil || [keywords length] == 0)
		return;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	NSArray* arr = [index documentsByKey:keywords];
	//
	if (arr == nil || [arr count] == 0)
	{
		NSString* formatter = NSLocalizedString(@"Can not find %@", nil);
		NSString* msg = [NSString stringWithFormat:formatter, keywords];
		//
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	//
	if (WizDeviceIsPad()
		&& self.detailViewController)
	{
		[self.detailViewController listDocuments:self.accountUserId docType:documentsSearchResult typeData:keywords docs:arr];
		//
		[self dismissModalViewControllerAnimated:YES];
	}
	else 
	{
		SearchResultViewController* searchResultView = [[SearchResultViewController alloc] initWithStyle:UITableViewStylePlain];
		searchResultView.accountUserID = accountUserId;
		searchResultView.searchResult = arr;
		//
		[self.navigationController pushViewController:searchResultView animated:YES];
		//
		[searchResultView release];
	}
}


- (void) search:(id)sender
{
	NSString* keywords = self.searchTextField.text;
	if (keywords == nil || [keywords length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:NSLocalizedString(@"Please enter keywords!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (self.searchLocalSwitch.on)
	{
		[self showSearchResult];
	}
	else 
	{
		WizDocumentsByKey* api = [[WizGlobalData sharedData] documentsByKeyData:accountUserId];
		if (api.busy)
			return;
		//
		NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
		//
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		//
		[nc addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
		//
		UIAlertView* alert = nil;
		[WizGlobals showAlertView:WizStrSearch message:NSLocalizedString(@"Please wait while searching!", nil) delegate:self retView:&alert];
		[alert show];
		//
		self.waitAlertView = alert;
		//
		[alert release];
		//
		api.keywords = keywords;
		[api searchDocuments];
	}

}

#pragma mark -
- (void) xmlrpcDone: (NSNotification*)nc
{
	NSDictionary* userInfo = [nc userInfo];
	//
	BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
	//
	if (!succeeded)
	{
		if (self.waitAlertView)
		{
			[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
			self.waitAlertView = nil;
		}
		//
	}
	
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:SyncMethod_DocumentsByKey])
	{
		if (succeeded)
		{
			if (self.waitAlertView)
			{
				[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
				self.waitAlertView = nil;
			}
			//
			[self showSearchResult];
		}
		else 
		{
			NSError* error = [userInfo valueForKey:@"ret"];
			//
			NSString* msg = nil;
			if (error != nil)
			{
				msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login!\n%@", nil), [error localizedDescription]];
			}
			else 
			{
				msg = NSLocalizedString(@"Failed to login!\nUnknown error!", nil);
			}
			
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			
			[alert show];
			[alert release];
		}
	}
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (WizDeviceIsPad())
		return YES;
	return NO;
}


- (IBAction) cancel: (id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}



@end

