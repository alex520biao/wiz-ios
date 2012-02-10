//
//  WelcomeViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WelcomeViewController.h"
#import "WizLogoView.h"
#import "Globals/WizSettings.h"
#import "AccountViewController.h"
#import "SetupAccountViewController.h"
#import "EditAccountViewController.h"
#import "CreateAccountViewController.h"
#import "AboutViewController.h"

#import "Globals/WizIndex.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizGlobals.h"
#import "CommonString.h"
#import "PickViewController.h"

static BOOL firstShowWelcomeViewController = YES;

@implementation WelcomeViewController

@synthesize imgAccount;
@synthesize imgAddAccount;
@synthesize imgCreateAccount;
@synthesize imgAboutSmall;

@synthesize currentAccountUserId;

- (void) viewDidLoad
{
	self.title = NSLocalizedString(@"Wiz", nil);
	//
	[self.tableView setSectionHeaderHeight:0.0f];
	//
	self.imgAccount = [UIImage imageNamed:@"account"];
	self.imgAddAccount = [UIImage imageNamed:@"add_account"];
	self.imgCreateAccount = [UIImage imageNamed:@"create_account"];
	self.imgAboutSmall = [UIImage imageNamed:@"about_small"];
	//
	[super viewDidLoad];
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAutoSelectAccount) name:@"autoSelectAccount" object:nil];
	
}

- (void) viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//
	self.imgAccount = nil;
	self.imgAddAccount = nil;
	self.imgCreateAccount = nil;
	self.imgAccount = nil;
	[super viewDidUnload];
}
- (void) dealloc
{
	[super dealloc];
}
- (void) viewWillAppear:(BOOL)animated
{
	BOOL hideBar = YES;
	if (WizDeviceIsPad() && !firstShowWelcomeViewController)
	{
		hideBar = NO;
		//
		UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleDone target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
		[cancelButton release];
	}
	//
	self.navigationController.navigationBarHidden = hideBar;
	//
	NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:tableSelection animated:NO];
	
	// reload the table data
	// may need to optimize this with a flag to indicate if reload is needed
	[self.tableView reloadData];
	//
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//
	if (firstShowWelcomeViewController)
	{
		firstShowWelcomeViewController = NO;
		//
		[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerAutoSelectAccount:) userInfo:nil repeats:NO];
	}
}

-(void) timerAutoSelectAccount:(NSTimer*)timer
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"autoSelectAccount" object: nil];
}


#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 3;
}

- (NSInteger) tableView: (UITableView *)tableView
numberOfRowsInSection: (NSInteger)section
{
	if (0 == section)
		return [[WizSettings accounts] count];
	else if (1 == section)
		return 2;
	else
		return 1;

}


- (UITableViewCell *) tableView: (UITableView *)tableView
cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	UITableViewCell* cell = nil;
	if (0 == indexPath.section)
	{
		NSArray* accounts = [WizSettings accounts];
		if (indexPath.row < [accounts count])
		{
			static NSString* CellId = @"ExistingAccount";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellId];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc]
						 initWithStyle:UITableViewCellStyleDefault
						 reuseIdentifier:CellId] autorelease];
			}
			cell.textLabel.text = [WizSettings accountUserIdAtIndex:accounts index:indexPath.row];
			cell.imageView.image = self.imgAccount;
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		}
	}
	else if (1 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			static NSString* CellId = @"SetupAccount";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellId];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc]
						 initWithStyle:UITableViewCellStyleDefault
						 reuseIdentifier:CellId] autorelease];
			}
			cell.textLabel.text = NSLocalizedString(@"Setup your account", nil);
			cell.imageView.image = imgAddAccount;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (1 == indexPath.row)
		{
			static NSString* CellId = @"CreateAccount";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellId];
			if (cell == nil)
			{
				cell = [[[UITableViewCell alloc]
						 initWithStyle:UITableViewCellStyleDefault
						 reuseIdentifier:CellId] autorelease];
			}
			cell.textLabel.text = NSLocalizedString(@"Create new account", nil);
			cell.imageView.image = imgCreateAccount;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else
	{
		static NSString* CellId = @"AboutCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellId];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier:CellId] autorelease];
		}
		cell.textLabel.text = NSLocalizedString(@"About Wiz", nil);
		cell.imageView.image = imgAboutSmall;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	//
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		NSArray* accounts = [WizSettings accounts];
		if (indexPath.row < [accounts count])
		{
			[self selectAccount:indexPath.row];
		}
	}
	else if (1 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			SetupAccountViewController *setupAccountView = [[SetupAccountViewController alloc] initWithNibName:@"SetupAccountViewController" bundle:nil];
			[self.navigationController pushViewController:setupAccountView animated:YES];
			[setupAccountView release];	
		}
		else if (1 == indexPath.row)
		{
			CreateAccountViewController *createAccountView = [[CreateAccountViewController alloc] initWithNibName:@"CreateAccountViewController" bundle:nil];
			[self.navigationController pushViewController:createAccountView animated:YES];
			[createAccountView release];	
		}
		
	}
	else if (2 == indexPath.section)
	{ 
		//CreateAccountViewController *createAccountView = [[CreateAccountViewController alloc] initWithNibName:@"CreateAccountViewController" bundle:nil];
		//[self.navigationController pushViewController:createAccountView animated:YES];
		//[createAccountView release];	

		AboutViewController* aboutView = [[AboutViewController alloc] init]; //initWithNibName:@"AboutViewController" bundle:nil];
		[self.navigationController pushViewController:aboutView animated:YES];
		[aboutView release];			
	}
}


- (void) tableView: (UITableView *)tableView
accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		NSArray* accounts = [WizSettings accounts];
		if (indexPath.row < [accounts count])
		{
			EditAccountViewController *editAccountView = [[EditAccountViewController alloc] initWithNibName:@"EditAccountViewController" bundle:nil];
			
			editAccountView.accountUserId = [WizSettings accountUserIdAtIndex:accounts index:indexPath.row];
			editAccountView.accountPassword = [WizSettings accountPasswordAtIndex:accounts index:indexPath.row];
			
			[self.navigationController pushViewController:editAccountView animated:YES];
			[editAccountView release];	
		}
		else 
		{
		}
		
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section 
{
	if(section == 0)
	{
		UIImage *image = [UIImage imageNamed:@"wizlogo.png"];
		//WizLogoView* img = [[[WizLogoView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)] autorelease];
		UIImageView* view = [[UIImageView alloc] initWithImage:image];
		if (WizDeviceIsPad())
		{
			view.contentMode = UIViewContentModeCenter;
		}
		else
		{
			view.contentMode = UIViewContentModeCenter;
		}

		return [view autorelease];
		//
		//return img;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section 
{
	if(section == 0)
		return 100.0f;
	return 0.0f;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (WizDeviceIsPad())
		return YES;
	return NO;
}



-(void) doSelectAccount:(NSString*)accountUserId
{
	//
	if (WizDeviceIsPad())
	{
		[self dismissModalViewControllerAnimated:YES];
		//
		NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:accountUserId, @"accountUserId", nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"didAccountSelect" object: nil userInfo: userInfo];
        [userInfo release];
	}
	else 
	{
        PickerViewController* pick = [[PickerViewController alloc] initWithUserID: accountUserId];
        [self.navigationController pushViewController:pick animated:YES];
        
        [pick release];
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 1) //OK
	{
		NSArray* views = [alertView subviews];
		if (views)
		{
			for (int i = 0; i < [views count]; i++)
			{
				id v = [views objectAtIndex:i];
				if (v != nil)
				{
					if ([v isKindOfClass:[UITextField class]])
					{
						UITextField* passwordTextField = (UITextField *)v;
						if (passwordTextField)
						{
							NSString* password = passwordTextField.text;
							NSString* passwordExists = [WizSettings accountPasswordByUserId:self.currentAccountUserId];
							//
							if ([passwordExists isEqualToString:password])
							{
								[self doSelectAccount:self.currentAccountUserId];
							}
							else 
							{
								UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Invalid Password", nil) 
																						 message:@""
																						delegate:self 
																			   cancelButtonTitle:WizStrCancel
																			   otherButtonTitles:nil ];
								[errorAlertView show];
								[errorAlertView release];
								
							}
							return;
						}
					}
				}
			}
		}
	}
}

-(void) selectAccount:(int)accountIndex
{
	NSArray* accounts = [WizSettings accounts];
	if (accountIndex >= 0 && accountIndex < [accounts count])
	{
		NSString* accountUserId = [WizSettings accountUserIdAtIndex:accounts index:accountIndex];
		//
		WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
		if (![index isOpened])
		{
			if (![index open])
			{
				[WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
				//
				return;
			}
		}
		//
		if ([index protect])
		{
			self.currentAccountUserId = accountUserId;
			//
			UIAlertView *passwordAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", nil) 
																  message:@"\n\n"
																 delegate:self 
														cancelButtonTitle:WizStrCancel 
														otherButtonTitles:WizStrOK, nil];
			//
			UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)];
			[passwordTextField setBackgroundColor:[UIColor whiteColor]];
			[passwordTextField setSecureTextEntry:YES];
			[passwordAlertView addSubview:passwordTextField];
			[passwordAlertView show];
			[passwordAlertView release];
            [passwordTextField release];
		}
		else 
		{
			[self doSelectAccount:accountUserId];
		}
	}	
}

-(void) onAutoSelectAccount
{
	NSArray* accounts = [WizSettings accounts];
	if ([accounts count] == 1)
	{
		[self selectAccount:0];
	}
}




- (IBAction) cancel: (id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}




@end
