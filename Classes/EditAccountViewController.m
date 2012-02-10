//
//  EditAccountViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/10/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "EditAccountViewController.h"
#import "CommonString.h"

#import "Globals/WizVerifyAccount.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizSettings.h"
#import "Globals/WizGlobals.h"
#import "Globals/WizIndex.h"
#import "LoginViewController.h"
#import "PickViewController.h"
@implementation EditAccountViewController

@synthesize tableView;
@synthesize userIdTableViewCell;
@synthesize passwordTableViewCell;
@synthesize downloadAllDocumentsViewCell;
@synthesize downloadDocumentDataViewCell;
@synthesize removeAccountTableViewCell;
@synthesize protectViewCell;
@synthesize userIDLabel;
@synthesize passwordTextField;
@synthesize downloadAllDocumentsSwitch;
@synthesize downloadDocumentDataSwitch;
@synthesize accountUserId;
@synthesize accountPassword;
@synthesize passwordProtectSwitch;
@synthesize waitAlertView;
@synthesize mobileViewSwitch;
@synthesize mobileViewCell;
@synthesize userTrafficProcessCell;
@synthesize userTrafficUsedProgress;
- (void) viewDidLoad
{
	self.title = NSLocalizedString(@"Edit Account", nil);
	//
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	//
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:WizStrOK style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	if (index)
	{
		self.downloadAllDocumentsSwitch.on = [index downloadAllList];
		self.downloadDocumentDataSwitch.on = [index downloadDocumentData];
		self.passwordProtectSwitch.on = [index protect];
        self.mobileViewSwitch.on = [index isMoblieView];
	}
	//
	
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
	self.userIDLabel = nil;
	self.passwordTextField = nil;
	self.downloadAllDocumentsSwitch = nil;
	self.downloadDocumentDataSwitch = nil;
	self.passwordProtectSwitch = nil;
	self.waitAlertView = nil;
	self.mobileViewCell = nil;
    self.mobileViewSwitch = nil;
    self.userTrafficProcessCell = nil;
    self.userTrafficUsedProgress = nil;
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
	self.userIDLabel = nil;
	self.passwordTextField = nil;
	self.downloadAllDocumentsSwitch = nil;
	self.downloadDocumentDataSwitch = nil;
	self.passwordProtectSwitch = nil;
	self.waitAlertView = nil;
	///
	self.accountUserId = nil;
	//
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
	userIDLabel.text = accountUserId;
	passwordTextField.text = accountPassword;
	//
	self.navigationController.navigationBarHidden = NO;
	[super viewWillAppear:animated];
}

#pragma mark -

- (IBAction) cancel: (id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) save: (id)sender
{
	accountPassword = passwordTextField.text;
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

- (IBAction) textFieldDone: (id)sender
{
	[sender resignFirstResponder];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 ) //NO
	{
		[WizSettings removeAccount:accountUserId];
        PickerViewController* mypicker = [[WizGlobalData sharedData] wizPickerViewOfUser:self.accountUserId];
        LoginViewController* mainView = [[WizGlobalData sharedData] wizMainLoginView:DataMainOfWiz];
        mainView.contentTableView.hidden = NO;
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:mypicker.view cache:YES];
        [UIView setAnimationDuration:1.0];
        [[mypicker view] removeFromSuperview];
        mainView.accountsArray = [WizSettings accounts];
        [mainView.contentTableView reloadData];
        [UIView commitAnimations];
        mainView.loginButton.hidden = NO;
        mainView.contentTableView.hidden = NO;
        
	}
}



- (IBAction)removeAccount:(id)sender 
{
	NSString *title = nil;
	if(accountUserId != nil && [accountUserId length] > 0 )
		title = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to delete %@ ?", nil), accountUserId];
	else
		title = [NSString stringWithString:NSLocalizedString(@"Are you sure you want to delete this account?", nil)];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:NSLocalizedString(@"The account information and local drafts will be deleted permanently from your device.", nil) 
												   delegate:self 
										  cancelButtonTitle:nil 
										  otherButtonTitles:WizStrRemove, WizStrCancel, nil];
	
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Table Data Source Methods


- (NSString*) tableView: (UITableView *)tableView
titleForHeaderInSection: (NSInteger)section
{
	if (0 == section)
		return [NSString stringWithString: NSLocalizedString(@"Account Info", nil)];
	else if (1 == section)
		return [NSString stringWithString: NSLocalizedString(@"Account Settings", nil)];
	else if (2 == section)
		return [NSString stringWithString: NSLocalizedString(@"Remove Account", nil)];
	else if (3 == section)
        return [NSString stringWithString:NSLocalizedString(@"User Traffic Used", nil)];
    else
		return nil;
}


- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 4;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	if (0 == section)
	{
		return 2;
	}
	else if (1 == section)
	{
		return 4;
	}
	else if ( 2 == section)
	{
		return 1;
	}
    else if ( 3 == section)
    {
        return 1;
    }
    else
        return 0;
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
        else if(3 == indexPath.row)
        {
            return mobileViewCell;
        }
	}
	else if (2 == indexPath.section)
	{
		return removeAccountTableViewCell;
	}
    else if (3 == indexPath.section)
    {
        return self.userTrafficProcessCell;
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
			[WizSettings addAccount:accountUserId password:accountPassword];
			//
			WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
			if (index)
			{
				[index setDownloadAllList:self.downloadAllDocumentsSwitch.on];
				[index setDownloadDocumentData:self.downloadDocumentDataSwitch.on];
				[index setProtect:self.passwordProtectSwitch.on];
                [index setDocumentMoblleView:self.mobileViewSwitch.on];
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
