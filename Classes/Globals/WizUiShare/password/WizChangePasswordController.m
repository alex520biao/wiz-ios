//
//  WizChangePasswordController.m
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizChangePasswordController.h"
#import "WizInputView.h"
#import "WizGlobalData.h"
#import "WizChangePassword.h"
#import "WizSettings.h"
#import "WizGlobals.h"
#import "WizPadNotificationMessage.h"
#import "WizPhoneNotificationMessage.h"

#define WaitAlertTag 1101
#define SucceedTag 1201
@implementation WizChangePasswordController
@synthesize oldPassword;
@synthesize passwordConfirmNew;
@synthesize passwordNew;
@synthesize accountUserId;
@synthesize waitAlert;
- (void) dealloc
{
    self.waitAlert = nil;
    self.accountUserId = nil;
    self.oldPassword = nil;
    self.passwordNew = nil;
    self.passwordConfirmNew = nil;
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
    WizInputView* input = [[WizInputView alloc] initWithFrame:CGRectMake(0.0, y, 320, 40)];
    [self.view addSubview:input];
    [input release];
    return input;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void) cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void) alertMessage:(NSString*)msg
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == SucceedTag) {
        [self cancel];
    }
}
- (void) xmlrpcDone: (NSNotification*)nc
{ 
	NSDictionary* userInfo = [nc userInfo];
    [self.waitAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.waitAlert = nil;
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:SyncMethod_ChangeAccountPassword])
	{
		BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
		if (succeeded)
		{
            [WizSettings changeAccountPassword:self.accountUserId password:self.passwordNew.textInputField.text];
            [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Succeed",nil) message:NSLocalizedString(@"You have successfully changed your password",nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = SucceedTag;
            [alert show];
            [alert release];
            
		}
	}
}

- (void) changePassword
{
    NSString* oldPwStr = self.oldPassword.textInputField.text;
    NSString* pwNewStr = self.passwordNew.textInputField.text;
    NSString* pwNewStrConfirm = self.passwordConfirmNew.textInputField.text;
    
    if (oldPwStr == nil || [oldPwStr isEqualToString:@""]) {
        [self alertMessage:NSLocalizedString(@"The old password is null", nil)];
        return;
    }
    
    if (pwNewStr == nil || [pwNewStr isEqualToString:@""]) {
        [self alertMessage:NSLocalizedString(@"The new Password is null", nil)];
        return;
    }
    
    if (pwNewStrConfirm == nil || [pwNewStrConfirm isEqualToString:@""]) {
        [self alertMessage:NSLocalizedString(@"The new password cofirmed is null", nil)];
        return;
    }
    
    if (![pwNewStr isEqualToString:pwNewStrConfirm]) {
        [self alertMessage:NSLocalizedString(@"The new password does not match the password confirmed", nil)];
        return;
    }
    
    if ([oldPwStr isEqualToString:pwNewStr]) {
        [self alertMessage:NSLocalizedString(@"The new password is equal to the old password", nil)];
        return;
    }
    WizChangePassword* changePw = [[WizGlobalData sharedData] dataOfChangePassword:self.accountUserId];
    [changePw changeAccountPassword:pwNewStr];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(xmlrpcDone:) name:[changePw notificationName:WizSyncXmlRpcDoneNotificationPrefix] object:nil];
    
    UIAlertView* waitAlert_ = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Change password", nil) message:NSLocalizedString(@"Please waiting ...", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    waitAlert_.tag = WaitAlertTag;
    self.waitAlert = waitAlert_;
    [waitAlert_ show];
    [waitAlert_ release];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [self.oldPassword.textInputField becomeFirstResponder];
    [super viewDidAppear:animated];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.oldPassword = [self addSubviewByPointY:20];
    self.oldPassword.textInputField.placeholder = NSLocalizedString(@"Old password",nil);
    self.oldPassword.nameLable.text = NSLocalizedString(@"Old password", nil);
    self.oldPassword.textInputField.keyboardType = UIKeyboardTypeEmailAddress;
    oldPassword.textInputField.secureTextEntry = YES;
    self.oldPassword.textInputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    self.passwordNew = [self addSubviewByPointY:70];
    self.passwordNew.textInputField.placeholder = NSLocalizedString(@"New password",nil);
    self.passwordNew.textInputField.secureTextEntry = YES;
    self.passwordNew.nameLable.text = NSLocalizedString(@"New password", nil);
    
    self.passwordConfirmNew = [self addSubviewByPointY:120];
    self.passwordConfirmNew.textInputField.placeholder = NSLocalizedString(@"New password",nil);
    self.passwordConfirmNew.textInputField.secureTextEntry = YES;
    self.passwordConfirmNew.nameLable.text = NSLocalizedString(@"Confirm", nil);
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self 
                                                                                  action:@selector(cancel)];
    UIBarButtonItem* changeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Change", nil) style:UIBarButtonItemStyleDone target:self action:@selector(changePassword)];
    self.navigationItem.rightBarButtonItem = changeButton;
	self.navigationItem.leftBarButtonItem = cancelButton;
    self.title = NSLocalizedString(@"Change account password", nil);
    self.view.backgroundColor = [UIColor lightTextColor];
    [cancelButton release];
    [changeButton release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
