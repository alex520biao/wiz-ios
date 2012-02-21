//
//  CreateAccountViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/10/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "CommonString.h"

#import "Globals/WizCreateAccount.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizSettings.h"
#import "Globals/WizGlobals.h"
#import "Globals/WizIndex.h"

#import "CommonString.h"

@implementation CreateAccountViewController

@synthesize tableView;
@synthesize userIdTableViewCell;
@synthesize passwordTableViewCell;
@synthesize password2TableViewCell;
@synthesize userIdTextField;
@synthesize passwordTextField;
@synthesize password2TextField;
@synthesize waitAlertView;

@synthesize downloadAllDocumentsViewCell;
@synthesize downloadDocumentDataViewCell;
@synthesize protectViewCell;
@synthesize downloadAllDocumentsSwitch;
@synthesize downloadDocumentDataSwitch;
@synthesize passwordProtectSwitch;


- (void) viewDidLoad
{
	self.title = NSLocalizedString(@"Create Account", nil);
	//
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	//
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Create Account", nil) style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	//
	//
	self.downloadAllDocumentsSwitch.on = NO;
	self.downloadDocumentDataSwitch.on = NO;
	self.passwordProtectSwitch.on = NO;
	//
	[super viewDidLoad];
}

- (void) viewDidUnload
{	
	[super viewDidUnload];
}

- (void) dealloc
{
	self.tableView = nil;
	self.userIdTableViewCell = nil;
	self.passwordTableViewCell = nil;
	self.password2TableViewCell = nil;
	self.downloadAllDocumentsViewCell = nil;
	self.downloadDocumentDataViewCell = nil;
	self.protectViewCell = nil;
	self.userIdTextField = nil;
	self.passwordTextField = nil;
	self.password2TextField = nil;
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
	NSString* error = NSLocalizedString(@"Error", nil);
	if (userIdTextField.text == nil|| [userIdTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (passwordTextField.text == nil || [passwordTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (password2TextField.text == nil || [password2TextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter confirm password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (![password2TextField.text isEqualToString:passwordTextField.text])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Passwords does not match!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (-1 != [WizSettings findAccount:userIdTextField.text])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), userIdTextField.text];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	//
	[nc removeObserver:self];
	//
	WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData: userIdTextField.text];
	//
	NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	//
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:NSLocalizedString(@"Create Account", nil) message:NSLocalizedString(@"Please wait while creatting account...!", nil) delegate:self retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
	//
	[alert release];
	//
	api.accountPassword = passwordTextField.text;
	[api createAccount];
}
- (IBAction) textFieldDone: (id)sender
{
	[sender resignFirstResponder];
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
		return 3;
	else
		return 3;
}

- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (indexPath.section == 0)
	{
		if (0 == indexPath.row)
		{
			return userIdTableViewCell;
		}
		else if (1 == indexPath.row)
		{
			return passwordTableViewCell;
		}
		else if (2 == indexPath.row)
		{
			return password2TableViewCell;
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
	if (method != nil && [method isEqualToString:@"accounts.createAccount"])
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
		}
		else {
			NSError* error = [userInfo valueForKey:@"ret"];
			//
			NSString* msg = nil;
			if (error != nil)
			{
				msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to create account!\n%@", nil), [error localizedDescription]];
			}
			else {
				msg = NSLocalizedString(@"Failed to create account!\nUnknown error!", nil);
			}
			
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
			
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
