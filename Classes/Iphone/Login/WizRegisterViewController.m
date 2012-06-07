//
//  WizRegisterViewController.m
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizRegisterViewController.h"
#import "WizCreateAccount.h"
#import "WizGlobalData.h"
#import "WizInputView.h"
#import "WizNotification.h"
#import "WizAccountManager.h"

@interface WizRegisterViewController()
{
    WizInputView* idInputView;
    WizInputView* passwordInputView;
    WizInputView* confirmInputView;
    UIButton* registerButton;
    UIAlertView* waitAlertView;
}
@property (nonatomic, retain) WizInputView* idInputView;
@property (nonatomic, retain) WizInputView* passwordInputView;
@property (nonatomic, retain) WizInputView* confirmInputView;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain)    UIButton* registerButton;
@end

@implementation WizRegisterViewController

@synthesize idInputView;
@synthesize passwordInputView;
@synthesize confirmInputView;
@synthesize waitAlertView;
@synthesize registerButton;
- (void) dealloc
{
    [registerButton release];
    [idInputView release];
    [passwordInputView release];
    [confirmInputView release];
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
        [UIView setAnimationDuration:0.25];
        self.view.frame = CGRectMake(0.0, -60, 320, 480);
        [UIView commitAnimations];
        
    }
    else if ([self.confirmInputView.textInputField isFirstResponder])
    {
        [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
        [UIView setAnimationDuration:0.25];
        self.view.frame = CGRectMake(0.0, -120, 320, 480);
        [UIView commitAnimations];
    }
}
- (void) keybordHide
{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDuration:0.25];
    self.view.frame = CGRectMake(0.0, 0.0, 320, 480);
    [UIView commitAnimations];
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.idInputView.textInputField resignFirstResponder];
    [self.passwordInputView.textInputField resignFirstResponder];
    [self.confirmInputView.textInputField resignFirstResponder];
}

- (void) showErrorAlert:(NSString*)message 
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:message delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
    [alert show];
    [alert release];
}
- (void) showWaitAlert
{
    UIAlertView* alert = nil;
	[WizGlobals showAlertView:WizStrCreateAccount message:WizStrPleasewaitwhilecreattingaccount delegate:self retView:&alert];
    self.waitAlertView = alert;
	[alert show];
	[alert release];
}
- (void) createAccount
{
    NSString* name = self.idInputView.textInputField.text;
    NSString* password = self.passwordInputView.textInputField.text;
    NSString* confirm = self.confirmInputView.textInputField.text;
	if (name == nil|| [name length] == 0)
	{
		[self showErrorAlert:WizStrPleaseenteuserid];
		return;
	}
	if (password == nil || [password length] == 0)
	{
		[self showErrorAlert:WizStrPleaseenterpassword];
		return;
	}
	if (confirm == nil || [confirm length] == 0)
	{
		[self showErrorAlert:WizStrPleaseenterthepasswordagain];
		return;
	}
	if (![confirm isEqualToString:password])
	{
		[self showErrorAlert:WizStrThePasswordDontMatch];
		return;
	}
	if ([[WizAccountManager defaultManager] findAccount:name])
	{
		[self showErrorAlert:WizStrAccounthasalreadyexists];
		return;
	}
	WizCreateAccount* api = [[WizGlobalData sharedData] createAccountData];
    api.accountUserId = name;
    api.accountPassword = password;
    api.createAccountDelegate = self;
	[api createAccount];
    [self showWaitAlert];
}
- (WizInputView*) addInputView:(CGRect)rect      title:(NSString*) title     placeHoder:(NSString*)placeHoder
{
    WizInputView* name = [[WizInputView alloc] initWithFrame:rect title:title placeHoder:placeHoder];
    name.textInputField.delegate = self;
    name.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    [self.view addSubview:name];
    return [name autorelease];
}

- (void) initBackGroud
{
    self.view.backgroundColor = [UIColor colorWithRed:215.0/255.0 green:215.0/255.0 blue:215.0/255.0 alpha:1.0];
    UIView* b1 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 320, 320, 1)];
    b1.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    [self.view addSubview:b1];
    [b1 release];
    UIView* b2 = [[UIView alloc] initWithFrame:CGRectMake(0.0, 321, 320, 1)];
    b2.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [self.view addSubview:b2];
    [b2 release];
}
- (void) buildNavigationItem
{
    UIButton* logButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logButton.frame = CGRectMake(10, 260, 300, 40);
    [logButton setTitle:WizStrRegister forState:UIControlStateNormal];
    logButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:logButton];
    [logButton addTarget:self action:@selector(createAccount) forControlEvents:UIControlEventTouchUpInside];
    [logButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView* logi = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dialog_title1"]];
    logi.frame = CGRectMake(0.0, 20, 320, 40);
    [self.view addSubview:logi];
    [logi release];
    self.idInputView = [self addInputView:CGRectMake(0.0, 80, 320, 40) title:@"Email" placeHoder:@"email@example.com"];
    self.passwordInputView = [self addInputView:CGRectMake(0.0, 140, 320, 40) title:@"Password" placeHoder:@"Password"];
    self.confirmInputView = [self addInputView:CGRectMake(0.0, 200, 320, 40) title:@"Confirm" placeHoder:@"Password"];
    self.passwordInputView.textInputField.secureTextEntry = YES;
    self.confirmInputView.textInputField.secureTextEntry = YES;
    [self buildNavigationItem];
    [self initBackGroud];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordHide) name:UIKeyboardDidHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) dismissAlertView
{
    if (self.waitAlertView)
	{
		[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
		self.waitAlertView = nil;
	}
}
- (void) didCreateAccountSucceed
{
    [self dismissAlertView];
    NSString* name = self.idInputView.textInputField.text;
    NSString* password = self.passwordInputView.textInputField.text;
    [[WizAccountManager defaultManager]  updateAccount:name password:password];
    [self.navigationController dismissModalViewControllerAnimated:NO];
    [WizNotificationCenter postPadSelectedAccountMessge:name];

}
- (void) didCreateAccountFaild
{
    [self dismissAlertView];
}
@end
