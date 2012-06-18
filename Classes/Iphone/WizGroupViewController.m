//
//  WizGroupViewController.m
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import "WizGroupViewController.h"
#import "WizAccountManager.h"
#import "PickViewController.h"
#import "UserSttingsViewController.h"
#import "WizNotification.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
#import "WizSyncManager.h"
#import <QuartzCore/QuartzCore.h>
#import "WizTempDataBase.h"

@interface WizGroupViewController ()
{
    NSArray* groupsArray;
    id<WizAbstractDbDelegate> dataBase;
    NSFetchedResultsController* fetch;
}
@property (nonatomic, retain) NSFetchedResultsController* fetch;
@property (nonatomic, retain) NSArray* groupsArray;
@end

@implementation WizGroupViewController

@synthesize groupsArray;

- (void) dealloc
{
    [groupsArray release];
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) reloadAllData
{
    [self.fetch performFetch:nil];
    [self.tableView reloadData];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadAllData) name:MessageTypeOfRefreshGroupsData];
        dataBase = [[WizDbManager shareDbManager] getWizTempDataBase:[[WizAccountManager defaultManager] activeAccountUserId]];
    }
    
    return self;
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self reloadAllData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = item;
    [item release];
    self.fetch = [[WizAccountManager defaultManager] groupsFetchResultController];
    
    UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAccountGroudData)];
    self.navigationItem.rightBarButtonItem = refreshItem;
    [refreshItem release];
    
//    self.groupsArray =[[WizAccountManager defaultManager] activeAccountGroups] ;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
   
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) setupAccount
{
    UserSttingsViewController* editAccountView = [[UserSttingsViewController alloc] initWithStyle:UITableViewStyleGrouped ];
    editAccountView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editAccountView animated:YES];
    [editAccountView release];
}

- (void) refreshAccountGroudData
{
    [[WizSyncManager shareManager] refreshGroupsData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [[self.fetch sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetch sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 80) ]autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        cell.accessoryView.layer.borderWidth = 0.6f;
        
    }
    UIImageView* imageView = (UIImageView*) cell.accessoryView;
    WizGroup* group = [self.fetch objectAtIndexPath:indexPath];
    cell.textLabel.text = group.kbName;
    WizAbstract* abs = [dataBase abstractForGroup:group.kbguid];
    NSLog(@"%@ %@",abs.text, abs.image);
        imageView.image = abs.image;
    return cell;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizGroup* group = [self.fetch objectAtIndexPath:indexPath];
    [[WizAccountManager defaultManager] registerActiveGroup:group];
    PickerViewController* pick = [[PickerViewController alloc] init];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self.fetch sections] objectAtIndex:section] name];
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView* sectionView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 20)] autorelease];
    sectionView.image = [UIImage imageNamed:@"tableSectionHeader"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:13]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    [label release];
    sectionView.alpha = 0.8f;
    return sectionView;
}
@end