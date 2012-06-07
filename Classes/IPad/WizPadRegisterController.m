//
//  WizPadRegisterController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizPadRegisterController.h"
#import "WizInputView.h"
#import "WizGlobalData.h"
#import "CommonString.h"
#import "WizCreateAccount.h"
#import "WizGlobals.h"

#import "WizNotification.h"
#import "WizAccountManager.h"
@implementation WizPadRegisterController
@synthesize accountEmail;
@synthesize accountPassword;
@synthesize accountPasswordConfirm;
@synthesize waitAlertView;
- (void) dealloc
{
    [accountPassword release];
    [accountPasswordConfirm release];
    [accountEmail release];
    [waitAlertView release];
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

- (WizInputView*) addSubviewByPointY:(float)y
{
    WizInputView* input = [[WizInputView alloc] initWithFrame:CGRectMake(100, y, 320, 40)];
    [self.view addSubview:input];
    [input release];
    return input;
}
- (void) cancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void) didCreateAccountSucceed
{
    NSString* emailString = self.accountEmail.textInputField.text;
    NSString* passwordString = self.accountPassword.textInputField.text;
    [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [[WizAccountManager defaultManager] updateAccount:emailString password:passwordString];
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [WizNotificationCenter postPadSelectedAccountMessge:emailString];
}
- (void) didCreateAccountFaild
{
    [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (IBAction) registerAccount: (id)sender
{
	NSString* error = WizStrError;
    NSString* emailString = self.accountEmail.textInputField.text;
    NSString* passwordString = self.accountPassword.textInputField.text;
    NSString* passwordConfirmString = self.accountPasswordConfirm.textInputField.text;
	if (emailString == nil|| [emailString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenteuserid delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (passwordString == nil || [passwordString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterpassword delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (passwordConfirmString == nil || [passwordConfirmString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrPleaseenterthepasswordagain delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (![passwordConfirmString isEqualToString:passwordString])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:WizStrThePasswordDontMatch  delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrCreateAccount message:WizStrPleasewaitwhilecreattingaccount delegate:self retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
    WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData];
    api.accountUserId = emailString;
    api.accountPassword = passwordString;
    api.createAccountDelegate = self;
	[api createAccount];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    self.accountEmail = [self addSubviewByPointY:40];
    self.accountEmail.textInputField.placeholder = @"example@email.com";
    self.accountEmail.nameLable.text = WizStrEmail;
    self.accountEmail.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    self.accountEmail.textInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.accountPassword = [self addSubviewByPointY:120];
    self.accountPassword.textInputField.placeholder = @"password";
    self.accountPassword.textInputField.secureTextEntry = YES;
    self.accountPassword.nameLable.text = WizStrPassword;
    
    self.accountPasswordConfirm = [self addSubviewByPointY:200];
    self.accountPasswordConfirm.textInputField.placeholder = @"password";
    self.accountPasswordConfirm.textInputField.secureTextEntry = YES;
    self.accountPasswordConfirm.nameLable.text = WizStrConfirm;
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self 
                                                                    action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(110, 280, 300, 40)];
    
    [registerButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [registerButton setTitle:WizStrRegister forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerAccount:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    [registerButton release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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
	return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.accountEmail.textInputField becomeFirstResponder];
}

@end
