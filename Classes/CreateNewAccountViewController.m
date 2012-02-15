//
//  CreateNewAccountViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CreateNewAccountViewController.h"
#import "WizSettings.h"
#import "WizCreateAccount.h"
#import "CommonString.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "PickViewController.h"
#import "LoginViewController.h"
#import "WizPhoneNotificationMessage.h"
@implementation CreateNewAccountViewController
@synthesize userIdLabel;
@synthesize userIdTextFiled;
@synthesize userPasswordLabel;
@synthesize userPasswordTextFiled;
@synthesize userPasswordAssertLabel;
@synthesize userPasswordAsserTextField;
@synthesize registerButton;
@synthesize backgroudVIew;

@synthesize frameRect;
@synthesize userIdRect;
@synthesize passwordRect;
@synthesize assertPasswordRect;
@synthesize waitAlertView;
@synthesize owner;
- (void) dealloc
{
    self.userIdLabel = nil;
    self.userIdTextFiled = nil;
    self.userPasswordAsserTextField = nil;
    self.userPasswordAssertLabel = nil;
    self.userPasswordLabel = nil;
    self.userPasswordTextFiled = nil;
    self.registerButton = nil;
    self.backgroudVIew = nil;
    self.waitAlertView = nil;
    self.owner = nil;
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

#pragma mark - View lifecycle

- (void) changeViewFrame:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDuration:0.35];
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.userIdTextFiled) {
        [self changeViewFrame:self.userIdRect];
    } 
    else if (textField == self.userPasswordTextFiled)
    {
        [self changeViewFrame:self.passwordRect];
    }
    else if (textField == self.userPasswordAsserTextField)
    {
        [self changeViewFrame:self.assertPasswordRect];
    }
}

- (void) cancel
{
    [self.parentViewController.view removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.backgroudVIew.image = [UIImage imageNamed:@"registerBackgroud"];
    
    [self.registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    self.userIdLabel.text = NSLocalizedString(@"Email", nil);
    self.userPasswordLabel.text = NSLocalizedString(@"Password", nil);
    self.userPasswordAssertLabel.text = NSLocalizedString(@"Confirm", nil);
    
    self.userIdTextFiled.delegate = self;
    self.userPasswordAsserTextField.delegate = self;
    self.userPasswordTextFiled.delegate = self; 
    self.frameRect = self.view.frame;
    self.userIdRect = CGRectMake(0.0, self.view.frame.origin.y - 80, self.view.frame.size.width, self.view.frame.size.height);
    self.passwordRect = CGRectMake(0.0, self.view.frame.origin.y - 110, self.view.frame.size.width, self.view.frame.size.height);
    
    self.assertPasswordRect = CGRectMake(0.0, self.view.frame.origin.y - 160, self.view.frame.size.width, self.view.frame.size.height);
    

    // Do any additional setup after loading the view from its nib.
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self changeViewFrame:self.frameRect];
    [self.userIdTextFiled resignFirstResponder];
    [self.userPasswordTextFiled resignFirstResponder];
    [self.userPasswordAsserTextField resignFirstResponder];
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

- (IBAction) save: (id)sender
{
	NSString* error = NSLocalizedString(@"Error", nil);
	if (self.userIdTextFiled.text == nil|| [self.userIdTextFiled.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter user id!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (self.userPasswordTextFiled.text == nil || [self.userPasswordTextFiled.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (self.userPasswordAsserTextField.text == nil || [self.userPasswordAsserTextField.text length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Please enter confirm password!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if (![self.userPasswordAsserTextField.text isEqualToString:self.userPasswordTextFiled.text])
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:error message:NSLocalizedString(@"Passwords does not match!", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (-1 != [WizSettings findAccount:self.userIdTextFiled.text])
	{
		NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Account %@ has already exists!", nil), self.userIdTextFiled.text];
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
	WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData: self.userIdTextFiled.text];
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
	api.accountPassword = self.userPasswordTextFiled.text;
	[api createAccount];
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
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
			[WizSettings addAccount:self.userIdTextFiled.text password:userPasswordTextFiled.text];
			//
//			WizIndex* index = [[WizGlobalData sharedData] indexData:userIdTextFiled.text];
//			if (index)
//			{
//				if (![index isOpened])
//				{
//					if (![index open])
//					{
//						[WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
//					}
//				}
//			}
//			//
//            LoginViewController* login = (LoginViewController*) self.owner;
//            
//            
//            PickerViewController* pick = [[WizGlobalData sharedData] wizPickerViewOfUser:self.userIdTextFiled.text];
//            login.loginButton.hidden = YES;
//            CGContextRef context = UIGraphicsGetCurrentContext();
//            [UIView beginAnimations:nil context:context];
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
//            [UIView setAnimationDuration:0.5];
//            [self.navigationController popViewControllerAnimated:NO];
//            [login.navigationController pushViewController:pick animated:YES];
//            [UIView commitAnimations];
            [self.navigationController popViewControllerAnimated:NO];
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:userIdTextFiled.text  forKey:TypeOfPhoneAccountUserId];
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
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
@end
