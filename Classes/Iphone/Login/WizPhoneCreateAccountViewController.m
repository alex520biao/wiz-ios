//
//  WizPhoneCreateAccountViewController.m
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPhoneCreateAccountViewController.h"
#import "WizSettings.h"
#import "WizCreateAccount.h"
#import "CommonString.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "PickViewController.h"
#import "LoginViewController.h"
#import "WizPhoneNotificationMessage.h"
#import "WizInputView.h"
@implementation WizPhoneCreateAccountViewController

@synthesize idInputView;
@synthesize passwordInputView;
@synthesize confirmInputView;
@synthesize waitAlertView;
@synthesize registerButton;
- (void) dealloc
{
    self.registerButton = nil;
    self.idInputView = nil;
    self.passwordInputView = nil;
    self.confirmInputView = nil;
    self.waitAlertView = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.passwordInputView.textInputField isFirstResponder]) {
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
        [UIView setAnimationDuration:0.5];
        self.view.frame = CGRectMake(0.0, -60, 320, 480);
        [UIView commitAnimations];
        
    }
    else if ([self.confirmInputView.textInputField isFirstResponder])
    {
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
        [UIView setAnimationDuration:0.5];
        self.view.frame = CGRectMake(0.0, -120, 320, 480);
        [UIView commitAnimations];
    }
}
- (void) keybordHide
{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDuration:0.5];
    self.view.frame = CGRectMake(0.0, 0.0, 320, 480);
    [UIView commitAnimations];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.idInputView.textInputField resignFirstResponder];
    [self.passwordInputView.textInputField resignFirstResponder];
    [self.confirmInputView.textInputField resignFirstResponder];
}
- (void) createAccount
{
	NSString* error = NSLocalizedString(@"Error", nil);
    NSString* name = self.idInputView.textInputField.text;
    NSString* password = self.passwordInputView.textInputField.text;
    NSString* confirm = self.confirmInputView.textInputField.text;
	if (name == nil|| [name length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (password == nil || [password length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (confirm == nil || [confirm length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter the password again!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (![confirm isEqualToString:password])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Passwords does not match!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (-1 != [WizSettings findAccount:name])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), name];
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
	WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData: name];
	//
	NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	//
    api.accountPassword = password;
	[api createAccount];
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:NSLocalizedString(@"Create account", nil) message:NSLocalizedString(@"Please wait while creatting account...!", nil) delegate:self retView:&alert];
    self.waitAlertView = alert;
	[alert show];
	[alert release];
	//
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView* logi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_title"]];
    logi.frame = CGRectMake(0.0, 20, 320, 40);
    [self.view addSubview:logi];
    WizInputView* name = [[WizInputView alloc] initWithFrame:CGRectMake(0.0, 80, 320, 40) title:@"Email" placeHoder:@"email@example.com"];
    name.textInputField.delegate = self;
    name.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    self.idInputView = name;
    [name release];
    
    WizInputView* password = [[WizInputView alloc] initWithFrame:CGRectMake(0.0, 140, 320, 40) title:@"Password" placeHoder:@"Password"];
    self.passwordInputView = password;
    password.textInputField.secureTextEntry = YES;
    password.textInputField.delegate = self;
    [password release];
    
    WizInputView* confirm = [[WizInputView alloc] initWithFrame:CGRectMake(0.0, 200, 320, 40) title:@"Confirm" placeHoder:@"Password"];
    self.confirmInputView = confirm;
    confirm.textInputField.secureTextEntry = YES;
    confirm.textInputField.delegate = self;
    [confirm release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordHide) name:UIKeyboardDidHideNotification object:nil];
    [self.view addSubview:self.idInputView];
    [self.view addSubview:self.passwordInputView];
    [self.view addSubview:self.confirmInputView];
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    
    UIButton* logButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logButton.frame = CGRectMake(10, 260, 300, 40);
    [logButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    logButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:logButton];
    [logButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    [logButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud1"] forState:UIControlStateNormal];
    UIView* b1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320, 320, 1)];
    b1.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [self.view addSubview:b1];
    [b1 release];
    UIView* b2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 321, 320, 1)];
    b2.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [self.view addSubview:b2];
    [b2 release];
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	if (method != nil && [method isEqualToString:@"accounts.createAccount"])
	{
        NSString* name = self.idInputView.textInputField.text;
        NSString* password = self.passwordInputView.textInputField.text;
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:name password:password];
            [self.navigationController popViewControllerAnimated:NO];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:name  forKey:TypeOfPhoneAccountUserId];
            [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDidSelectedAccount object:nil userInfo:userInfo];
            
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

@end
