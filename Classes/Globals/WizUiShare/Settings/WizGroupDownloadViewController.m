//
//  WizGroupDownloadViewController.m
//  Wiz
//
//  Created by wiz on 12-6-26.
//
//

#import "WizGroupDownloadViewController.h"
#import "WizAccountManager.h"
#import "WizSwitchCell.h"
#import "WizSettings.h"

@interface WizGroupDownloadViewController ()
{
    NSArray* groups;
}
@end

@implementation WizGroupDownloadViewController

- (void) dealloc
{
    [groups release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        groups = [[[WizAccountManager defaultManager] activeAccountGroupsWithoutSection] retain];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return [groups count];
        default:
            return 0;
    }
}
- (void) didSelectSwitch:(id)sender
{
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch* s = (UISwitch*)sender;
        WizGroup* group = [groups objectAtIndex:s.tag];
        [[WizSettings defaultSettings] setGroupAutoDownload:group.kbguid isAuto:s.on];
        NSLog(@"index is %d",s.tag);
    }
}
- (void) openAllGroupDownload
{
    WizSettings* set = [WizSettings defaultSettings];
    for (WizGroup* each in groups) {
        [set setGroupAutoDownload:each.kbguid isAuto:YES];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void) closeAllGroupDownload
{
    WizSettings* set = [WizSettings defaultSettings];
    for (WizGroup* each in groups) {
        [set setGroupAutoDownload:each.kbguid isAuto:NO];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static UITableViewCell* totalActionCell = nil;
        static UIButton* btn1;
        static UIButton* btn2;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            totalActionCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NNNNNNNN"];
            
             btn1 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn1 setTitle:NSLocalizedString(@"Open All", nil) forState:UIControlStateNormal];
            btn1.frame = CGRectMake(0.0, 0.0, 140, 44);
            [totalActionCell.contentView addSubview:btn1];
            
            btn2 =[UIButton buttonWithType:UIButtonTypeRoundedRect];
            [btn2 setTitle:NSLocalizedString(@"Close All", nil) forState:UIControlStateNormal];
            btn2.frame = CGRectMake(150, 0.0, 140, 44);
            [totalActionCell.contentView addSubview:btn2];
        });
        [btn1 addTarget:self action:@selector(openAllGroupDownload) forControlEvents:UIControlEventTouchUpInside];
        [btn2 addTarget:self action:@selector(closeAllGroupDownload) forControlEvents:UIControlEventTouchUpInside];
        return totalActionCell;
    }
    static NSString *CellIdentifier = @"DownloadSettingCell";
    WizSwitchCell *cell = (WizSwitchCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[WizSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell.valueSwitch addTarget:self action:@selector(didSelectSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    WizGroup* group = [groups objectAtIndex:indexPath.row];
    cell.textLabel.text = group.kbName;
    cell.valueSwitch.tag = indexPath.row;
    cell.valueSwitch.on = [[WizSettings defaultSettings] isGroupAutoDownload:group.kbguid];
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
