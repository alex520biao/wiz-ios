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
#import "WizSettings.h"
#import "UserSttingsViewController.h"
#import "NSDate-Utilities.h"
#import "WizNotification.h"
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

- (void) addNewDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    WizDocument* newDocument = [index documentFromGUID:documentGUID];
    [self.sourceArray insertObject:newDocument atIndex:0];
    if ([self.tableArray count]) {
        NSDate * date = [WizGlobals sqlTimeStringToDate:[[[self.tableArray objectAtIndex:0] objectAtIndex:0] dateModified]];
        if ([date isToday]) {
            [[self.tableArray objectAtIndex:0] insertObject:newDocument atIndex:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray array];
            [array addObject:newDocument];
            [self.tableArray insertObject:array atIndex:0];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    else
    {
        NSMutableArray* array = [NSMutableArray array];
        [array addObject:newDocument];
        [self.tableArray insertObject:array atIndex:0];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    }
    self.currentDoc = newDocument;
    [self viewDocument];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [WizNotificationCenter removeObserver:self];
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
	return [NSString stringWithString:WizStrRecentNotes];
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
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];

    self.navigationItem.leftBarButtonItem = item;
    [item release];
    [super viewDidLoad];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(addNewDocument:) name:MessageTypeOfNewDocument];

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
        remind.text = NSLocalizedString(@"You can pull down to sync notes or tap the plus (+) icon to create a new a note", nil);
        remind.backgroundColor = [UIColor clearColor];
        remind.textColor = [UIColor grayColor];
        [pushDownRemind addSubview:remind];
        remind.textAlignment = UITextAlignmentCenter;
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
        remind.text = NSLocalizedString(@"Recent notes view shows the notes that you modified recently.", nil);
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