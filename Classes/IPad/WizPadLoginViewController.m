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
#import "WizNotification.h"

@implementation WizPadLoginViewController
@synthesize loginButton;
@synthesize backgroudView;
@synthesize registerButton;
@synthesize checkExistedAccountButton;
@synthesize CripytLabel;
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [WizNotificationCenter removeObserver:self];
    self.CripytLabel = nil;
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
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO]; 
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
- (void) selectAccount:(NSNotification*)nc
{
    [self.navigationController dismissModalViewControllerAnimated:NO];
    NSString* accountUserId = [WizNotificationCenter getDidSelectedAccountUserId:nc];
    [WizNotificationCenter postDidSelectedAccountMessage:accountUserId];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.loginButton setTitle:WizStrSignIn forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"loginButtonBackgroud"] forState:UIControlStateNormal];
    [self.registerButton setTitle:WizStrRegister forState:UIControlStateNormal];
    [self.checkExistedAccountButton setTitle:WizStrSwitchAccounts forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkOtherAccounts:) name:MessageOfPadLoginViewChangeUser object:nil];
    [WizNotificationCenter addObserverForPadSelectedAccount:self selector:@selector(selectAccount:)];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [WizNotificationCenter removeObserver:self];
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
