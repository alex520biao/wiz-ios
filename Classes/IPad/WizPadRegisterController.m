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
#import "WizSettings.h"
#import "WizGlobals.h"
#import "WizIndex.h"
@implementation WizPadRegisterController
@synthesize accountEmail;
@synthesize accountPassword;
@synthesize accountPasswordConfirm;
@synthesize waitAlertView;
- (void) dealloc
{
    self.accountPassword = nil;
    self.accountPasswordConfirm = nil;
    self.accountEmail = nil;
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
- (void) xmlrpcDone: (NSNotification*)nc
{
	if (self.waitAlertView)
	{
		[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
		self.waitAlertView = nil;
	}
	//
    NSString* emailString = self.accountEmail.textInputField.text;
    NSString* passwordString = self.accountPassword.textInputField.text;
	NSDictionary* userInfo = [nc userInfo];
	//
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:@"accounts.createAccount"])
	{
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:emailString password:passwordString];
			//
			WizIndex* index = [[WizGlobalData sharedData] indexData:emailString];
			if (index)
			{
				if (![index isOpened])
				{
					if (![index open])
					{
						[WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
					}
				}
			}
			//
            [self.navigationController dismissModalViewControllerAnimated:YES];
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:emailString, @"accountUserId", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAccountSelect" object: nil userInfo: userInfo];
            [userInfo release];
		}
		else {
            // null
		}
	}
}

- (IBAction) registerAccount: (id)sender
{
	NSString* error = WizStrError;
    NSString* emailString = self.accountEmail.textInputField.text;
    NSString* passwordString = self.accountPassword.textInputField.text;
    NSString* passwordConfirmString = self.accountPasswordConfirm.textInputField.text;
	if (emailString == nil|| [emailString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (passwordString == nil || [passwordString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (passwordConfirmString == nil || [passwordConfirmString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter the password again!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (![passwordConfirmString isEqualToString:passwordString])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Passwords does not match!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (-1 != [WizSettings findAccount:emailString])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), emailString];
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
	WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData: emailString];
	//
	NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
	//
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
	//
	UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrCreateAccount message:NSLocalizedString(@"Please wait while creatting account...!", nil) delegate:self retView:&alert];
	[alert show];
	//
	self.waitAlertView = alert;
	//
	[alert release];
	//
	api.accountPassword = passwordString;
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
