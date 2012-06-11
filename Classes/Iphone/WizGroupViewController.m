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

@interface WizGroupViewController ()
{
    NSArray* groupsArray;
}
@property (nonatomic, retain) NSArray* groupsArray;
@end

@implementation WizGroupViewController

@synthesize groupsArray;

- (void) dealloc
{
    [groupsArray release];
    [super dealloc];
}
- (void) reloadAllData
{
    self.groupsArray =[[WizAccountManager defaultManager] activeAccountGroups];
    [self.tableView reloadData];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadAllData) name:MessageTypeOfRefreshGroupsData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [item release];
    self.groupsArray =[[WizAccountManager defaultManager] activeAccountGroups] ;
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.groupsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizGroup* group = [self.groupsArray objectAtIndex:indexPath.row];
    cell.textLabel.text = group.kbName;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizGroup* group = [self.groupsArray objectAtIndex:indexPath.row];
    NSLog(@"group array %d",[self.groupsArray count]);
    NSLog(@"%@ %@",group.kbName,group.kbguid);
    [[WizAccountManager defaultManager] registerActiveGroup:group];
    PickerViewController* pick = [[PickerViewController alloc] init];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}
@end