//
//  RecentDcoumentListView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "RecentDcoumentListView.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "EditAccountViewController.h"
#import "WizSettings.h"
#import "UserSttingsViewController.h"
#import "NSDate-Utilities.h"
@implementation RecentDcoumentListView

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (void) reloadDocuments
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    NSMutableArray* arr = [[index recentDocuments] mutableCopy];
    if (arr != nil)
    {
        self.sourceArray = arr;
    }
    else
    {
        self.sourceArray = [NSMutableArray array];
    }
    [arr release];
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



- (NSString*) titleForView
{
	return [NSString stringWithString:NSLocalizedString(@"Recent Notes", nil)];
}


-(void) setupAccount
{
    NSArray* accounts = [WizSettings accounts];
    UserSttingsViewController* editAccountView = [[UserSttingsViewController alloc] initWithNibName:@"UserSttingsViewController" bundle:nil ];
    for (int i = 0; i < [accounts count]; i++) {
        if ([self.accountUserID isEqualToString:[WizSettings accountUserIdAtIndex:accounts index:i]]) {
            editAccountView.accountUserId = [WizSettings accountUserIdAtIndex:accounts index:i];
        }
    }
   
    editAccountView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editAccountView animated:YES];
    [editAccountView release];
}

- (void) viewDidLoad
{
    self.title = [self titleForView];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Settings",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];

    self.navigationItem.leftBarButtonItem = item;
    [item release];
    [super viewDidLoad];

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.tableArray == nil) {
        self.tableArray = [NSMutableArray array];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    int count = 0;
    for(NSArray* each in self.tableArray)
    {
        count += [each count];
    }
    
    if (0 == count) {
        
        UIImageView* pushDownRemind = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pushDownRemind"]];
        self.tableView.tableFooterView = pushDownRemind;
        [pushDownRemind release];
        UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(80, 300, 160, 480)];
        remind.text = NSLocalizedString(@"You can push down to refresh and tap the plus-icon to create a new a note", nil);
        remind.backgroundColor = [UIColor clearColor];
        remind.textColor = [UIColor grayColor];
        [pushDownRemind addSubview:remind];
        [remind release];
        pushDownRemind.tag = 10001;
        self.tableView.tableFooterView = pushDownRemind;
    } else
    {
        UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:count])];
        UIImageView* searchFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recentTableFooter"]];
        [footerView addSubview:searchFooter];
        self.tableView.tableFooterView = footerView;
        footerView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
        [searchFooter release];
        [footerView release];
        UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(90, 0, 210, 100)];
        remind.text = NSLocalizedString(@"recentRemind", nil);
        remind.backgroundColor = [UIColor clearColor];
        remind.textColor = [UIColor grayColor];
        [searchFooter addSubview:remind];
        [remind release];
    }
    
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    if ([index isFirstLog] ) {
        [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self startLoading];
        [index setFirstLog:YES];
    }
}

@end
