//
//  WizIphoneLoginViewController.m
//  Wiz
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizIphoneLoginViewController.h"
#import "WizCheckAccounsController.h"
#import "WizPhoneCreateAccountViewController.h"
#import "WizAddAcountViewController.h"
#import "WizNotification.h"
#import "WizSettings.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "PickViewController.h"
@interface WizIphoneLoginViewController ()
{
    BOOL firstLoad;
}
@end

@implementation WizIphoneLoginViewController
- (void) didSelectedAccount:(NSString*)accountUserId
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:WizStrFailedtoopenaccountdata];
            return;
        }
    }
    PickerViewController* pick =[[PickerViewController alloc] initWithUserID:accountUserId];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}

- (void) selecteDefaultAccount
{
    NSArray* accounts = [WizSettings accounts];
    if ([accounts count] > 0) {
        NSString* defaultUserId = [WizSettings defaultAccountUserId];
        if (defaultUserId == nil || [defaultUserId isEqualToString:@""]) {
            [WizSettings setDefalutAccount:[WizSettings accountUserIdAtIndex:accounts index:0]];
            defaultUserId = [WizSettings defaultAccountUserId];
        }
        [self didSelectedAccount:defaultUserId];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        firstLoad = YES;
    }
    return self;
}
- (IBAction)cheackExistAccount:(id)sender
{
    WizCheckAccounsController* checkAccounts = [[WizCheckAccounsController alloc] init];
    [self.navigationController pushViewController:checkAccounts animated:YES];
    [checkAccounts release];

}
- (IBAction)signInAccount:(id)sender
{
    WizAddAcountViewController* wizAddAccount = [[WizAddAcountViewController alloc] init];
    [self.navigationController pushViewController:wizAddAccount animated:YES];
    [wizAddAccount release];
}

- (IBAction)registerAccount:(id)sender
{
    WizPhoneCreateAccountViewController *createAccountView = [[WizPhoneCreateAccountViewController alloc] init];
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
