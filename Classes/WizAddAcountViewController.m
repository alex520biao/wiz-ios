//
//  WizAddAcountViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizAddAcountViewController.h"
#import "WizInputView.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "WizGlobalData.h"
#import "WizSettings.h"
#import "CommonString.h"
#import "WizVerifyAccount.h"
#import "WizIndex.h"
@implementation WizAddAcountViewController
@synthesize nameInput;
@synthesize passwordInput;
@synthesize waitAlertView;
- (void) dealloc
{
    self.nameInput = nil;
    self.waitAlertView = nil;
    self.passwordInput = nil;
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
	NSDictionary* userInfo = [nc userInfo];
	//
	NSString* accountIDString = nameInput.textInputField.text;
    NSString* accountPasswordString = passwordInput.textInputField.text;
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:@"accounts.clientLogin"])
	{
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:accountIDString password:accountPasswordString];
            WizIndex* index = [[WizGlobalData sharedData] indexData:accountIDString];
            
            if (![index isOpened])
            {
                if (![index open])
                {
                    [WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
                    //
                    return;
                }
            }
            [self.navigationController dismissModalViewControllerAnimated:YES];
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:accountIDString, @"accountUserId", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAccountSelect" object: nil userInfo: userInfo];
            [userInfo release];
		}
		else {
            //null
		}
	}
}


- (void) login
{
    [self.nameInput.textInputField resignFirstResponder];
    [self.passwordInput.textInputField resignFirstResponder];
    NSString* error = NSLocalizedString(@"Error", nil);
    NSString* accountIDString = nameInput.textInputField.text;
    NSString* accountPasswordString = passwordInput.textInputField.text;
    
	if (accountIDString == nil|| [accountIDString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (accountPasswordString == nil || [accountPasswordString length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (-1 != [WizSettings findAccount:accountIDString])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), accountIDString];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	//
	[nc removeObserver:self];
	//
	WizVerifyAccount* api = [[WizGlobalData sharedData] verifyAccountData: accountIDString];
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
	api.accountPassword = accountPasswordString;
	[api verifyAccount];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    WizInputView* nameInput_ = [[WizInputView alloc] initWithFrame:CGRectMake(100, 40, 320, 40)];
    [self.view addSubview:nameInput_];
    [nameInput_ release];
    self.nameInput = nameInput_;
   
    nameInput.nameLable.text = NSLocalizedString(@"ID", nil);
    nameInput.textInputField.placeholder = @"exmaple@email.com";
    nameInput.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    
    WizInputView* passwordInput_ = [[WizInputView alloc] initWithFrame:CGRectMake(100, 120, 320, 40)];
     [self.view addSubview:passwordInput_];
    [passwordInput_ release];
    self.passwordInput = passwordInput_;
    passwordInput.nameLable.text = NSLocalizedString(@"Password", nil);
    passwordInput.textInputField.placeholder = @"password";
    passwordInput.textInputField.secureTextEntry = YES;
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel",nil) 
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self 
                                                                    action:@selector(cancel)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    
    UIButton* loginButton_ = [[UIButton alloc] initWithFrame:CGRectMake(110, 200, 300, 40)];
    
    [loginButton_ setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [loginButton_ setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    [loginButton_ addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton_];
    [loginButton_ release];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
   
    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.nameInput.textInputField becomeFirstResponder];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

@end
