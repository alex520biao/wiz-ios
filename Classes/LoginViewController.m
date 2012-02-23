//
//  LoginViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "WizSettings.h"
#import "CommonString.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizApi.h"
#import "WizVerifyAccount.h"
#import "UIView-TagExtensions.h"
#import "PickViewController.h"
#import "WizPhoneCreateAccountViewController.h"
#import "WizPhoneNotificationMessage.h"

#define PROTECTALERT 300
@implementation LoginViewController
@synthesize willChangedUser;
@synthesize contentTableView;
@synthesize userNameCell;
@synthesize userNameLabel;
@synthesize userNameTextField;
@synthesize userPasswordCell;
@synthesize userPasswordLabel;
@synthesize userPasswordTextField;
@synthesize loginButton;
@synthesize waitAlertView;
@synthesize accountsArray;
@synthesize addAccountCell;
@synthesize addAccountButton;
@synthesize createdAccountButton;
@synthesize checkOtherAccountButton;
@synthesize selecteAccountId;
@synthesize willAddUser;
- (void) dealloc
{
    self.selecteAccountId = nil;
    self.contentTableView = nil;
    self.userPasswordTextField = nil;
    self.userPasswordLabel = nil;
    self.userPasswordCell = nil;
    self.userNameTextField = nil;
    self.userNameLabel = nil;
    self.userNameCell = nil;
    self.loginButton = nil;
    self.waitAlertView = nil;
    self.accountsArray = nil;
    self.addAccountButton = nil;
    self.addAccountCell = nil;
    self.createdAccountButton = nil;
    self.checkOtherAccountButton = nil;
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void) loginViewMoveUp
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.contentTableView cache:YES];
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:CGRectMake(0.0 , -200, 320, 480)];
    [UIView commitAnimations];
}

- (void) hideKeyboard
{
    [self.userNameTextField resignFirstResponder];
    [self.userPasswordTextField resignFirstResponder];
}

- (void) loginViewMoveDown
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.contentTableView cache:YES];
    if ([WizGlobals WizDeviceVersion] >= 4.0) {
        [UIView setAnimationDelegate:self];
 
        [UIView setAnimationDidStopSelector:@selector(hideKeyboard)];
    }
    [UIView setAnimationDuration:0.3];
    [self.view setFrame:CGRectMake(0.0 , 0.0, 320, 480)];
    [UIView commitAnimations];
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self loginViewMoveUp];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (CGRect) getContentViewFrame
{
    if ([accountsArray count] && !willAddUser) {
        float contentviewY = self.view.frame.size.height*3/4;
        float height = self.view.frame.size.height/2;
        if (height >= [accountsArray count]*40 ) {
            height = height -20;
        } else
        {
            height = [accountsArray count]* 40 ;
        }
        contentviewY = contentviewY -height/2;
        NSLog(@"%f",height);
        return CGRectMake(10, contentviewY, 300, height);
    }
    else
    {
        return CGRectMake(10, 260, 300, 90);
    }
}
- (IBAction) checkOtherAccounts:(id)sender
{
    [self loginViewMoveDown];
    self.willAddUser = NO;
    self.accountsArray = [WizSettings accounts];
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [accountsArray count]; i++) {
        [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    self.loginButton.hidden = YES;
    self.checkOtherAccountButton.hidden = YES;
    self.createdAccountButton.hidden = NO;
    self.addAccountButton.hidden = YES;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentTableView cache:YES];
    [UIView setAnimationDuration:0.3];
    self.contentTableView.frame = [self getContentViewFrame];
    [self.contentTableView reloadData];
    [UIView commitAnimations];
}
- (void)addAccountEntry
{
    self.loginButton.hidden = NO;
    self.checkOtherAccountButton.hidden = NO;
    self.createdAccountButton.hidden = YES;
    self.addAccountButton.hidden = NO;
    self.willAddUser = YES;
    self.accountsArray = nil;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentTableView cache:YES];
    [UIView setAnimationDuration:0.3];
    self.contentTableView.frame = [self getContentViewFrame];
//    [self.contentTableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationTop];
    [self.contentTableView reloadData];
    [UIView commitAnimations];
}

- (void) getNewAccount:(id)sender
{
    WizPhoneCreateAccountViewController *createAccountView = [[WizPhoneCreateAccountViewController alloc] init];
    [self.navigationController pushViewController:createAccountView animated:YES];
    [createAccountView release];
}
- (void) didSelectedAccount:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* userID = [userInfo valueForKey:TypeOfPhoneAccountUserId];
    WizIndex* index = [[WizGlobalData sharedData] indexData:userID];
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
            return;
        }
    }
    PickerViewController* pick = [[WizGlobalData sharedData] wizPickerViewOfUser:userID];
    self.contentTableView.frame = CGRectMake(10, 260, 300, 80);
    self.loginButton.hidden = YES;
    [self.navigationController pushViewController:pick animated:YES];
}
- (void) selectDefaultAccount
{
    if (!self.willChangedUser) {
        self.willChangedUser = YES;
        NSString* defaultUserId = [WizSettings defaultAccountUserId];
        if (defaultUserId != nil && ![defaultUserId isEqualToString:@""]) {
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:defaultUserId  forKey:TypeOfPhoneAccountUserId];
            [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDidSelectedAccount object:nil userInfo:userInfo];
        }
        else
        {
            if ([[WizSettings  accounts] count]) {
                defaultUserId = [WizSettings accountUserIdAtIndex:[WizSettings accounts] index:0];
                [WizSettings setDefalutAccount:defaultUserId];
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:defaultUserId  forKey:TypeOfPhoneAccountUserId];
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDidSelectedAccount object:nil userInfo:userInfo];
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(10, 260, 300, 80) style:UITableViewStyleGrouped];
    self.contentTableView = table;
    [table release];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    [self.view addSubview:self.contentTableView];
    if ([[WizSettings accounts] count]) {
        willAddUser = NO;
    }
    else
    {
        willAddUser = YES;
    }
    self.userNameTextField.delegate = self;
    self.userPasswordTextField.delegate = self;
    
    self.userPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userPasswordTextField.secureTextEntry = YES;
    [self.view setFrame:CGRectMake(0.0 , 0.0, 320, 480)];
    self.userNameLabel.text = NSLocalizedString(@"User ID", nil);
    self.userPasswordLabel.text = NSLocalizedString(@"Password", @"密码");
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.loginButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    self.addAccountCell.selectionStyle=UITableViewCellSelectionStyleNone;
    self.userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.checkOtherAccountButton setTitle:NSLocalizedString(@"Switch accounts", nil) forState:UIControlStateNormal];
    self.willChangedUser = NO;
    [self.createdAccountButton setTitle:NSLocalizedString(@"Add New Account", nil) forState:UIControlStateNormal];
    [self.createdAccountButton addTarget:self action:@selector(addAccountEntry) forControlEvents:UIControlEventTouchUpInside];
    self.createdAccountButton.frame = CGRectMake(0.0, self.view.frame.size.height/2 -30, 320, 30);
    [self.addAccountButton setTitle:NSLocalizedString(@"Get Free WizNote Account", nil) forState:UIControlStateNormal];
    self.addAccountButton.hidden = NO;
    UIImageView* backGroud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBackgroud"]];
    [self.view insertSubview:backGroud atIndex:0];
    [backGroud release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectedAccount:) name:MessageOfPhoneDidSelectedAccount object:nil];
    [self selectDefaultAccount];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self loginViewMoveDown];
}

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
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: userNameTextField.text];
        [nc removeObserver:self name:[api notificationName:WizSyncXmlRpcDoneNotificationPrefix] object:nil];

		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:userNameTextField.text password:userPasswordTextField.text];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:userNameTextField.text  forKey:TypeOfPhoneAccountUserId];
            [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDidSelectedAccount object:nil userInfo:userInfo];
		}
		else {

		}
	}
}

- (IBAction)userLogin:(id)sender
{
    [self.userNameTextField resignFirstResponder];
    [self.userPasswordTextField resignFirstResponder];
    [self loginViewMoveDown];
    NSString* error = NSLocalizedString(@"Error", nil);
	if (self.userNameTextField.text == nil|| [userNameTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (userPasswordTextField.text == nil || [userPasswordTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (-1 != [WizSettings findAccount:userNameTextField.text])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), userNameTextField.text];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: userNameTextField.text];
	NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
	[nc addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrLogin message:NSLocalizedString(@"Please wait while logining!", nil) delegate:self retView:&alert];
	[alert show];
	self.waitAlertView = alert;
	[alert release];
	api.accountPassword = userPasswordTextField.text;
	[api verifyAccount];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 != [accountsArray count]) {
        if (indexPath.row == [accountsArray count]) {
            return;
        }
        NSString* userID = [WizSettings accountUserIdAtIndex:self.accountsArray index:indexPath.row];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:userID  forKey:TypeOfPhoneAccountUserId];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDidSelectedAccount object:nil userInfo:userInfo];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}
#pragma mark - View lifecycle
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == [accountsArray count]) {
        return 2;  
    }
    else
    {
        return [accountsArray count];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == [accountsArray count] || willAddUser) {
        
        static NSString *CellIdentifier = @"LoginCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            switch (indexPath.row) {
                case 0:
                    return self.userNameCell;
                case 1:
                    return self.userPasswordCell;
                default:
                    return nil;
            }
        }
        return cell;
    }
    
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString* userID = [WizSettings accountUserIdAtIndex:self.accountsArray index:indexPath.row];
    cell.textLabel.text = userID;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:@"userIcon"];
    return cell;
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.accountsArray = [WizSettings accounts];
    self.checkOtherAccountButton.hidden = YES;
    if (0 == [accountsArray count] ) {
        self.loginButton.hidden = NO;
        self.contentTableView.scrollEnabled = NO;
        self.addAccountButton.hidden = NO;
        self.createdAccountButton.hidden = YES;
        [self addAccountEntry];
    } 
    else
    {
        self.loginButton.hidden = YES;
        self.contentTableView.scrollEnabled = YES;
        self.addAccountButton.hidden = YES;
        self.createdAccountButton.hidden = NO;
        [self checkOtherAccounts:nil];
    }
    self.contentTableView.frame = [self getContentViewFrame];
}
@end
