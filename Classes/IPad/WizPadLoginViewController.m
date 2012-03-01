//
//  WizPagLoginViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizPadLoginViewController.h"
#import "WizAddAcountViewController.h"
#import "LoginViewController.h"
#import "WizPadRegisterController.h"
#import "WizCheckAccounsController.h"
#import "WizSettings.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizPadNotificationMessage.h"


@implementation WizPadLoginViewController
@synthesize loginButton;
@synthesize backgroudView;
@synthesize registerButton;
@synthesize checkExistedAccountButton;
@synthesize willFirstAppear;
@synthesize CripytLabel;
- (void) dealloc
{
    self.CripytLabel = nil;
    self.willFirstAppear = NO;
    self.loginButton = nil;
    self.backgroudView = nil;
    self.registerButton = nil;
    self.checkExistedAccountButton = nil;
    [super dealloc];
}
- (void) setFrames:(UIInterfaceOrientation)interface
{
    if (UIInterfaceOrientationIsLandscape(interface)) {
        self.backgroudView.frame = CGRectMake(0.0, 0.0, 1024, 768);
        self.backgroudView.image = [UIImage imageNamed:@"Default-Landscape~ipad"];
        self.loginButton.frame = CGRectMake(292, 660, 220, 40);
        self.registerButton.frame = CGRectMake(522, 660, 220, 40);
        self.checkExistedAccountButton.frame = CGRectMake(402, 530, 220, 40);
        self.CripytLabel.frame = CGRectMake(445, 724, 135, 21);
    }
    else
    {
        self.backgroudView.frame = CGRectMake(0.0, 0.0, 768, 1024);
        self.backgroudView.image = [UIImage imageNamed:@"Default-Portrait~ipad"];
        self.loginButton.frame = CGRectMake(160, 875, 220, 40);
        self.registerButton.frame = CGRectMake(390, 875, 220, 40);
        self.checkExistedAccountButton.frame = CGRectMake(274, 630, 220, 40);
        self.CripytLabel.frame = CGRectMake(318, 972, 132, 21);
    }
}
- (void) selectDefaultAccount
{
    NSString* defaultUserId = [WizSettings defaultAccountUserId];
    
    if (defaultUserId != nil && ![defaultUserId isEqualToString:@""]) {
        NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:defaultUserId, @"accountUserId", nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didAccountSelect" object: nil userInfo: userInfo];
        [userInfo release];
    }
    else
    {
        if ([[WizSettings  accounts] count]) {
            NSArray* accountsArray =[WizSettings accounts];
            defaultUserId = [WizSettings accountUserIdAtIndex:accountsArray index:0];
            NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:defaultUserId, @"accountUserId", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"didAccountSelect" object: nil userInfo: userInfo];
            [userInfo release];
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES]; 
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setFrames:self.interfaceOrientation];
    if ([[WizSettings accounts] count]) {
        self.checkExistedAccountButton.hidden = NO;
    }
    else
    {
        self.checkExistedAccountButton.hidden = YES;
    }
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
  
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //load the default account
    if (willFirstAppear) {
        [self selectDefaultAccount];
        self.willFirstAppear = NO;
    }
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (IBAction)checkOtherAccounts:(id)sender
{
    if ([[WizSettings accounts] count]) {
        WizCheckAccounsController* checkAccounts = [[WizCheckAccounsController alloc] init];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:checkAccounts];
        controller.modalPresentationStyle = UIModalPresentationFormSheet;
        [self.navigationController presentModalViewController:controller animated:YES];
        [checkAccounts release];
        [controller release];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.willFirstAppear = YES;
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.loginButton setTitle:WizStrSignIn forState:UIControlStateNormal];
    
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.registerButton setTitle:NSLocalizedString(@"Register", nil) forState:UIControlStateNormal];
    [self.checkExistedAccountButton setTitle:NSLocalizedString(@"Switch accounts", nil) forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOtherAccounts:) name:MessageOfPadLoginViewChangeUser object:nil];

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
	return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setFrames:toInterfaceOrientation];
}

- (IBAction)loginViewAppear:(id)sender
{
    WizAddAcountViewController* wizAddAccount = [[WizAddAcountViewController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:wizAddAccount];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:controller animated:YES];
    [wizAddAccount release];
    [controller release];
}
- (IBAction)registerViewApper:(id)sender
{
    WizPadRegisterController* wizAddAccount = [[WizPadRegisterController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:wizAddAccount];
    controller.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentModalViewController:controller animated:YES];
    [wizAddAccount release];
    [controller release];
}

@end
