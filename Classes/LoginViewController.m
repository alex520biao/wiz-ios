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
#import "CreateNewAccountViewController.h"

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
        self.contentTableView = [[[UITableView alloc] initWithFrame:CGRectMake(10, 260, 300, 80) style:UITableViewStyleGrouped] autorelease];
        self.contentTableView.delegate = self;
        [self.contentTableView setScrollEnabled:NO];
        [self.contentTableView setDataSource:self];
        self.contentTableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        
        [self.view addSubview:self.contentTableView];
        self.userNameTextField.delegate = self;
        self.userPasswordTextField.delegate = self;
        self.userPasswordCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userNameCell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.userPasswordTextField.secureTextEntry = YES;
        [self.view setFrame:CGRectMake(0.0 , 0.0, 320, 480)];
        self.userNameLabel.text = NSLocalizedString(@"ID", @"用户名");
        self.userPasswordLabel.text = NSLocalizedString(@"Password", @"密码");
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
        [self.loginButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
        self.addAccountCell.selectionStyle=UITableViewCellSelectionStyleNone;
        self.userNameTextField.keyboardType = UIKeyboardTypeEmailAddress;
        [self.checkOtherAccountButton setTitle:NSLocalizedString(@"Check Other Accounts", nil) forState:UIControlStateNormal];
        self.willChangedUser = NO;
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

- (IBAction) checkOtherAccounts:(id)sender
{
    [self loginViewMoveDown];
    self.accountsArray = [WizSettings accounts];
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [accountsArray count]; i++) {
        [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    self.loginButton.hidden = YES;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentTableView cache:YES];
    [UIView setAnimationDuration:0.3];
    float height = self.view.frame.size.height/2;
    float contentviewY = self.view.frame.size.height*3/4;
    
    if (height >= [arr count]*40 + 40) {
        height = height -20;
    } else
    {
        height = [arr count]* 40 + 40;
    }
    
    contentviewY = contentviewY - height/2;
    self.contentTableView.frame = CGRectMake(10, contentviewY, 300, height);
    [self.contentTableView reloadData];

    [UIView commitAnimations];
}
- (void)addAccountEntry
{
    self.loginButton.hidden = NO;
    self.accountsArray = nil;
    [self.contentTableView reloadData];
    NSMutableArray* arr = [NSMutableArray array];
    for (int i = 0; i < [accountsArray count]; i++) {
        [arr addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.contentTableView cache:YES];
    [UIView setAnimationDuration:0.3];
    self.contentTableView.frame = CGRectMake(10, 260, 300, 80);
    [self.contentTableView reloadRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationTop];
    [UIView commitAnimations];
    
}

- (void) getNewAccount:(id)sender
{
    CreateNewAccountViewController *createAccountView = [[CreateNewAccountViewController alloc] initWithNibName:@"CreateNewAccountViewController" bundle:nil];
    createAccountView.owner = self;
    [self.navigationController pushViewController:createAccountView animated:YES];
    [createAccountView release];
    
}


#pragma mark - View lifecycle
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == [accountsArray count]) {
        [self.addAccountButton setTitle:NSLocalizedString(@"Get Free Account From Wiz", nil) forState:UIControlStateNormal];
        self.createdAccountButton.hidden = YES;
        self.addAccountButton.hidden = NO;
        return 2;  
    } 
    self.createdAccountButton.hidden = NO;
    self.addAccountButton.hidden = YES;
    [self.createdAccountButton setTitle:NSLocalizedString(@"Add New Account", nil) forState:UIControlStateNormal];
    [self.createdAccountButton addTarget:self action:@selector(addAccountEntry) forControlEvents:UIControlEventTouchUpInside];
    return [accountsArray count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.accountsArray count]!= 0) {
        NSArray* arr = self.accountsArray ;
        float height = self.view.frame.size.height/2;
        float contentviewY = self.view.frame.size.height*3/4;
        
        if (height >= [arr count]*40 + 40) {
            height = height -20;
        } else
        {
            height = [arr count]* 40 + 40;
        }
        
        contentviewY = contentviewY - height/2;
        self.contentTableView.frame = CGRectMake(10, contentviewY, 300, height);
        checkOtherAccountButton.hidden = YES;
        self.contentTableView.scrollEnabled = YES;
    }
    else 
    {
        self.loginButton.hidden = NO;
        self.contentTableView.scrollEnabled = NO;
        if ([[WizSettings accounts] count] != 0) {
            self.checkOtherAccountButton.hidden = NO;
        }
        else
        {
            self.checkOtherAccountButton.hidden = YES;
        }
        
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == [accountsArray count]) {
        
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
    
    if (indexPath.row == [accountsArray count]) {
        
        static NSString *CellIdentifier = @"AddAccountCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = self.addAccountCell;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* backGroud = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBackgroud"]];
    [self.view insertSubview:backGroud atIndex:0];
    [backGroud release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
        [nc removeObserver:self];
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:userNameTextField.text password:userPasswordTextField.text];
            WizIndex* index = [[WizGlobalData sharedData] indexData:userNameTextField.text];

            if (![index isOpened])
            {
                if (![index open])
                {
                    [WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
                    //
                    return;
                }
            }
            PickerViewController* pick = [[WizGlobalData sharedData] wizPickerViewOfUser:self.userNameTextField.text];
            self.loginButton.hidden = YES;
            CGContextRef context = UIGraphicsGetCurrentContext();
            [UIView beginAnimations:nil context:context];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
            [UIView setAnimationDuration:0.3];
            [self.navigationController pushViewController:pick animated:NO];
            [UIView commitAnimations];
		}
		else {
//			NSError* error = [userInfo valueForKey:@"ret"];
//			//
//			NSString* msg = nil;
//			if (error != nil)
//			{
//				msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login!\n%@", nil), [error localizedDescription]];
//			}
//			else {
//				msg = NSLocalizedString(@"Failed to login!\nUnknown error!", nil);
//			}
//            
//			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
//			
//			[alert show];
//			[alert release];
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
	//
	[nc removeObserver:self];
	//
	WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: userNameTextField.text];
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
	api.accountPassword = userPasswordTextField.text;
	[api verifyAccount];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (PROTECTALERT == alertView.tag) {
        for (UIView* each in alertView.subviews) {
            if ([each isKindOfClass:[UITextField class]]) {
                [each resignFirstResponder];
                UITextField* textField = (UITextField*)each;
                NSString* text = textField.text;
                if (nil != text && [text isEqualToString:[WizSettings accountProtectPassword]]) {
                    PickerViewController* pick = [[WizGlobalData sharedData] wizPickerViewOfUser:selecteAccountId];
                    CGContextRef context = UIGraphicsGetCurrentContext();
                    self.loginButton.hidden = YES;
                    [UIView beginAnimations:nil context:context];
                    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
                    [UIView setAnimationDuration:0.3];
                    self.contentTableView.frame = CGRectMake(10, 260, 300, 80);
                    [self.navigationController pushViewController:pick animated:NO];
//                    [self.navigationController pushViewController:pick animated:NO];
                    [UIView commitAnimations];
                }
                else
                {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                                    message:NSLocalizedString(@"Password is wrong", nil)
                                                                   delegate:self 
                                                          cancelButtonTitle:@"OK" 
                                                          otherButtonTitles:nil];
                    [alert show];
                    [alert release];
                }
            }
        }
    }
    
}

- (void) didSelectedAccount:(NSString*)userID
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:userID];
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
            return;
        }
    }
    NSString* userProtectPassword = [WizSettings accountProtectPassword];
    if (userProtectPassword != nil && ![userProtectPassword isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Password", nil)
                                                        message:NSLocalizedString(@"Device does not support a photo", nil)
                                                       delegate:self 
                                              cancelButtonTitle:NSLocalizedString(@"OK",nil) 
                                              otherButtonTitles:nil];
        UITextField* text = [[UITextField alloc] initWithFrame:CGRectMake(12, 45, 260, 25)];
        text.keyboardType = UIKeyboardTypeNumberPad;
        [text becomeFirstResponder];
        [text setBackgroundColor:[UIColor whiteColor]];
        [alert addSubview:text];
        text.placeholder = NSLocalizedString(@"password", nil);
        [alert show];
        alert.tag = PROTECTALERT;
        [alert release];

        [text release];
        self.selecteAccountId = userID;
        return;
    }
    PickerViewController* pick = [[WizGlobalData sharedData] wizPickerViewOfUser:userID];
    self.contentTableView.frame = CGRectMake(10, 260, 300, 80);
    self.loginButton.hidden = YES;
    [self.navigationController pushViewController:pick animated:YES];
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

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    self.accountsArray = [WizSettings accounts];
    if (0 == [accountsArray count]) {
        self.loginButton.hidden = NO;
        self.contentTableView.scrollEnabled = NO;
    } 
    else
    {
        float height = self.view.frame.size.height/2;
        float contentviewY = self.view.frame.size.height*3/4;
        
        if (height >= [accountsArray count]*40 + 40) {
            height = height -20;
        } else
        {
            height = [accountsArray count]* 40 + 40;
        }
        contentviewY = contentviewY - height/2;
        self.contentTableView.frame = CGRectMake(10, contentviewY, 300, height);
        self.loginButton.hidden = YES;
        self.contentTableView.scrollEnabled = YES;
    }
    self.contentTableView.hidden = NO;
    if (!self.willChangedUser) {
        NSString* defaultUserId = [WizSettings defaultAccountUserId];
        if (defaultUserId != nil && ![defaultUserId isEqualToString:@""]) {
            [self didSelectedAccount:defaultUserId];
        }
        else
        {
            if ([[WizSettings  accounts] count]) {
                defaultUserId = [WizSettings accountUserIdAtIndex:self.accountsArray index:0];
                [WizSettings setDefalutAccount:defaultUserId];
                [self didSelectedAccount:defaultUserId];
            }
        }
    }
   
}
@end
