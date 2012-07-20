//
//  WizIphoneLoginViewController.m
//  Wiz
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizIphoneLoginViewController.h"
#import "WizRegisterViewController.h"
#import "WizAddAcountViewController.h"
#import "WizNotification.h"

#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "PickViewController.h"
#import "WizAccountManager.h"
@interface WizIphoneLoginViewController ()
{
    BOOL firstLoad;
}
@end

@implementation WizIphoneLoginViewController
- (void) didSelectedAccount:(NSString*)accountUserId
{
    [[WizAccountManager defaultManager] registerActiveAccount:accountUserId];
    PickerViewController* pick =[[PickerViewController alloc] init];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}

- (void) selecteDefaultAccount
{
    NSString* defaultUserId = [[WizAccountManager defaultManager]activeAccountUserId];
    if (defaultUserId == nil || [defaultUserId isEqualToString:@""])
    {
        return;
    }
    [self didSelectedAccount:defaultUserId];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstLoad = YES;
    }
    return self;
}
- (IBAction)signInAccount:(id)sender
{
    WizAddAcountViewController* wizAddAccount = [[WizAddAcountViewController alloc] init];
    [self.navigationController pushViewController:wizAddAccount animated:YES];
    [wizAddAccount release];
}

- (IBAction)registerAccount:(id)sender
{
    WizRegisterViewController *createAccountView = [[WizRegisterViewController alloc] init];
    [self.navigationController pushViewController:createAccountView animated:YES];
    [createAccountView release];
}
- (void) selectAccount:(NSNotification*)nc
{
    NSString* accountUserId = [WizNotificationCenter getDidSelectedAccountUserId:nc];
    [self didSelectedAccount:accountUserId];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [WizNotificationCenter addObserverForPadSelectedAccount:self selector:@selector(selectAccount:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [WizNotificationCenter removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    if (firstLoad) {
        [self selecteDefaultAccount];
        firstLoad = NO;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
@end
