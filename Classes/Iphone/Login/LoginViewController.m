//
//  LoginViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
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

#import "WizNotification.h"
#define ColorValue(x) x/255.0
#define PROTECTALERT 300
@implementation LoginViewController
@synthesize firstLoad;
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
        self.firstLoad = YES;
    }
    return self;
}
- (void) didSelectedAccount:(NSString*)accountUserId
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:WizStrFailedtoopenaccountdata];
            return;
        }
    }
    PickerViewController* pick =[[PickerViewController alloc] initWithUserID:accountUserId];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}

- (void) selecteDefaultAccount
{
    NSArray* accounts = [WizSettings accounts];
    if ([accounts count] > 0) {
        NSString* defaultUserId = [WizSettings defaultAccountUserId];
        if (defaultUserId == nil || [defaultUserId isEqualToString:@""]) {
            [WizSettings setDefalutAccount:[WizSettings accountUserIdAtIndex:accounts index:0]];
            defaultUserId = [WizSettings defaultAccountUserId];
        }
        [self didSelectedAccount:defaultUserId];
    }
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
    if ([[WizSettings accounts] count] > 0) {
        self.checkOtherAccountButton.hidden = NO;
    }
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

- (CAGradientLayer*) buttonBackgroud
{

    CAGradientLayer* gLayer = [CAGradientLayer layer];
    NSArray* array = [NSArray arrayWithObjects:
                      (id)[[[[UIColor alloc] initWithRed:ColorValue(0x41) green:ColorValue(0x93) blue:ColorValue(0xc1) alpha:1.0] autorelease] CGColor] ,
                      (id)[[[[UIColor alloc] initWithRed:ColorValue(0x40) green:ColorValue(0x70) blue:ColorValue(0xff) alpha:1.0]  autorelease] CGColor] ,
                      nil];
    gLayer.colors = array;
    gLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],
                        [NSNumber numberWithFloat:0.5],
                        nil];
    gLayer.startPoint = CGPointMake(0.5, 0.0);
    gLayer.endPoint = CGPointMake(0.5, 1.0);
    gLayer.bounds = self.addAccountButton.frame;
    gLayer.position = CGPointMake([self.addAccountButton bounds].size.width/2, [self.addAccountButton bounds].size.height/2);
    return gLayer;
}
- (void) initButtons
{
    UITableView* table = [[UITableView alloc] initWithFrame:CGRectMake(10, 260, 300, 80) style:UITableViewStyleGrouped];
    self.contentTableView = table;
    [table release];
    self.contentTableView.delegate = self;
    self.contentTableView.dataSource = self;
    self.contentTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    [self.view addSubview:self.contentTableView];
    self.userNameTextField.delegate = self;
    self.userPasswordTextField.delegate = self;
    self.userPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userPasswordTextField.secureTextEntry = YES;
    [self.view setFrame:CGRectMake(0.0 , 0.0, 320, 480)];
    self.userNameLabel.text = WizStrUserId;
    self.userPasswordLabel.text = WizStrPassword;
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.loginButton setTitle:WizStrSignIn forState:UIControlStateNormal];
    self.addAccountCell.selectionStyle=UITableViewCellSelectionStyleNone;
    self.userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.checkOtherAccountButton setTitle:WizStrSwitchAccounts forState:UIControlStateNormal];
    [self.createdAccountButton setTitle:NSLocalizedString(@"Add New Account", nil) forState:UIControlStateNormal];
    [self.createdAccountButton addTarget:self action:@selector(addAccountEntry) forControlEvents:UIControlEventTouchUpInside];
    self.createdAccountButton.frame = CGRectMake(0.0, self.view.frame.size.height/2 -30, 320, 30);
    [self.addAccountButton setTitle:NSLocalizedString(@"Create an Account", nil) forState:UIControlStateNormal];
    [self.addAccountButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    self.addAccountButton.hidden = NO;
    UIImageView* backGroud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBackgroud"]];
    [self.view insertSubview:backGroud atIndex:0];
    [backGroud release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initButtons];
    if ([[WizSettings accounts] count]) {
        willAddUser = NO;
    }
    else
    {
        willAddUser = YES;
    }
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
            [self didSelectedAccount:userNameTextField.text];
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
    NSString* error = WizStrError;
	if (self.userNameTextField.text == nil|| [userNameTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenteuserid delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (userPasswordTextField.text == nil || [userPasswordTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterpassword delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (-1 != [WizSettings findAccount:userNameTextField.text])
	{
		NSString* msg = [NSString stringWithFormat:WizStrAccounthasalreadyexists, userNameTextField.text];
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
	[WizGlobals showAlertView:WizStrSignIn message:WizStrPleasewaitwhileloggingin delegate:self retView:&alert];
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
        [self didSelectedAccount:userID];
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
    WizLog(@"viewWillAppear");
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.accountsArray = [WizSettings accounts];
    self.checkOtherAccountButton.hidden = YES;
    if (0 == [accountsArray count] ) {
        WizLog(@"account == 0");

        self.loginButton.hidden = NO;
        self.contentTableView.scrollEnabled = NO;
        self.addAccountButton.hidden = NO;
        self.createdAccountButton.hidden = YES;
        [self addAccountEntry];
    } 
    else
    {
        WizLog(@"account != 0");
        self.loginButton.hidden = YES;
        self.contentTableView.scrollEnabled = YES;
        self.addAccountButton.hidden = YES;
        self.createdAccountButton.hidden = NO;
        [self checkOtherAccounts:nil];
        if (self.firstLoad) {
            WizLog(@"first load");
            [self selecteDefaultAccount];
            self.firstLoad = NO;
        }
    }
    WizLog(@"init frame");
    self.contentTableView.frame = [self getContentViewFrame];

    
}
@end
