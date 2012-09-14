//
//  PhRecentViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhRecentViewController.h"
#import "WizDbManager.h"
#import "WizSyncManager.h"

@interface PhRecentViewController ()
{
    BOOL isFirstLogin;
}
@end

@implementation PhRecentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        isFirstLogin = YES;
    }
    return self;
}
- (NSArray*) reloadAllDocument
{
    return [WizDocument recentDocuments];
}

-(void) setupAccount
{
    [WizNotificationCenter postIphoneSetupAccount];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    {
        
    }
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = item;
    self.title = WizStrRecentNotes;
    [item release];
}

- (void) viewWillAppear:(BOOL)animated
{
    if (isFirstLogin) {
        [[WizSyncManager shareManager] automicSyncData];
        isFirstLogin = NO;
    }
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.tableView.backgroundView = nil;
}
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

- (BOOL) isInsertDocumentValid:(WizDocument *)document
{
    return YES;
}
@end
