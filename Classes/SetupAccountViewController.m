//
//  SetupAccountViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/9/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "SetupAccountViewController.h"
#import "CommonString.h"

#import "Globals/WizVerifyAccount.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizSettings.h"
#import "Globals/WizGlobals.h"
#import "Globals/WizIndex.h"


@implementation SetupAccountViewController

@synthesize tableView;
@synthesize userIdTableViewCell;
@synthesize passwordTableViewCell;
@synthesize downloadAllDocumentsViewCell;
@synthesize downloadDocumentDataViewCell;
@synthesize protectViewCell;
@synthesize userIdTextField;
@synthesize passwordTextField;
@synthesize downloadAllDocumentsSwitch;
@synthesize downloadDocumentDataSwitch;
@synthesize passwordProtectSwitch;
@synthesize waitAlertView;
@synthesize moblieViewCell;
@synthesize mobileViewSwitch;

- (void) viewDidLoad
{
	self.title = NSLocalizedString(@"Setup Account", nil);
	//
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	//
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:WizStrOK style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	//
	self.downloadAllDocumentsSwitch.on = NO;
	self.downloadDocumentDataSwitch.on = NO;
	self.passwordProtectSwitch.on = NO;
	//
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	self.tableView = nil;
	self.userIdTableViewCell = nil;
	self.passwordTableViewCell = nil;
	self.downloadAllDocumentsViewCell = nil;
	self.downloadDocumentDataViewCell = nil;
	self.protectViewCell = nil;
	self.userIdTextField = nil;
	self.passwordTextField = nil;
	self.downloadAllDocumentsSwitch = nil;
	self.downloadDocumentDataSwitch = nil;
	self.passwordProtectSwitch = nil;
	self.waitAlertView = nil;
	self.mobileViewSwitch = nil;
    self.moblieViewCell = nil;
	[super viewDidUnload];
}

- (void) dealloc
{
	self.tableView = nil;
	self.userIdTableViewCell = nil;
	self.passwordTableViewCell = nil;
	self.downloadAllDocumentsViewCell = nil;
	self.downloadDocumentDataViewCell = nil;
	self.protectViewCell = nil;
	self.userIdTextField = nil;
	self.passwordTextField = nil;
	self.downloadAllDocumentsSwitch = nil;
	self.downloadDocumentDataSwitch = nil;
	self.passwordProtectSwitch = nil;
	self.waitAlertView = nil;
	
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = NO;
	[super viewWillAppear:animated];
}

#pragma mark -

- (IBAction) cancel: (id)sender
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction) save: (id)sender
{
	NSString* accountUserId = userIdTextField.text;
	NSString* accountPassword = passwordTextField.text;
	//
	if (accountUserId == nil|| [accountUserId length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (accountPassword == nil || [accountPassword length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	//
	[nc removeObserver:self];
	//
	WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: accountUserId];
	//
	NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	//
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrLogin message:NSLocalizedString(@"Please wait while logining!", nil) delegate:self retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
	//
	[alert release];
	//
	api.accountPassword = accountPassword;
	[api verifyAccount];
}



#pragma mark -
#pragma mark Table Data Source Methods


- (NSString*) tableView: (UITableView *)tableView
titleForHeaderInSection: (NSInteger)section
{
	if (0 == section)
		return NSLocalizedString(@"Account Information", nil);
	else if (1 == section)
		return NSLocalizedString(@"Account Settings", nil);
	else
		return nil;
}


- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 2;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	if (0 == section)
		return 2;
	else
		return 3;
}

- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			return userIdTableViewCell;
		}
		else if (1 == indexPath.row)
		{
			return passwordTableViewCell;
		}
	}
	else if (1 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			return downloadAllDocumentsViewCell;
		}
		else if (1 == indexPath.row)
		{
			return downloadDocumentDataViewCell;
		}
		else if (2 == indexPath.row)
		{
			return protectViewCell;
		}
	}
	//
	return nil;
}



#pragma mark -
#pragma mark Table View Delegate Methods
- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
}


- (UITableViewCell *) tableView: (UITableView *)tableView
	   willSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	return nil;
}

#pragma mark -

- (void) xmlrpcDone: (NSNotification*)nc
{
	if (self.waitAlertView)
	{
		[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
		self.waitAlertView = nil;
	}
	//
	NSDictionary* userInfo = [nc userInfo];
	//
	
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:@"accounts.clientLogin"])
	{
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:userIdTextField.text password:passwordTextField.text];
			//
			WizIndex* index = [[WizGlobalData sharedData] indexData:userIdTextField.text];
			if (index)
			{
				if (![index isOpened])
				{
					if (![index open])
					{
						[WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
					}
				}
				if ([index isOpened])
				{
					[index setDownloadAllList:self.downloadAllDocumentsSwitch.on];
					[index setDownloadDocumentData:self.downloadDocumentDataSwitch.on];
					[index setProtect:self.passwordProtectSwitch.on];
				}
			}
			//
			[self.navigationController popViewControllerAnimated:YES];
			//
		}
		else {
			NSError* error = [userInfo valueForKey:@"ret"];
			//
			NSString* msg = nil;
			if (error != nil)
			{
				msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login!\n%@", nil), [error localizedDescription]];
			}
			else {
				msg = NSLocalizedString(@"Failed to login!\nUnknown error!", nil);
			}

			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
			
			[alert show];
			[alert release];
		}
	}
}


- (IBAction) textFieldDoneEditing: (id)sender
{
	[sender resignFirstResponder];
}

@end
