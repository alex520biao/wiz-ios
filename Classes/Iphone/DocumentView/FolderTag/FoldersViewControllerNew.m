//
//  FoldersViewControllerNew.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "FoldersViewControllerNew.h"
#import "TreeViewBaseController.h"
#import "WizGlobalData.h"
#import "LocationTreeNode.h"
#import "LocationTreeViewCell.h"
#import "WizGlobals.h"
#import "WizPhoneNotificationMessage.h"
#import "WizTableViewController.h"
#import "WizDbManager.h"
#import "PhFolderListViewController.h"

@implementation FoldersViewControllerNew

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadAllData) name:MessageTypeOfUpdateFolderTable];
    }
    return self;
}
- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString*) restructLoactionKey:(NSArray*)locationArray  maxIndex:(int)index
{
    NSMutableString* key = [NSMutableString string];
    [key appendString:@"/"];
    for (int i =1; i <= index; i++) {
        [key appendFormat:@"%@/",[locationArray objectAtIndex:i]];
    }
    return key;
}

- (void) removeBlockLocationNode:(LocationTreeNode*)node
{
    if ([node hasChildren]) {
        NSArray* arr = [node.children copy];
        for (LocationTreeNode* each in arr) {
            [self removeBlockLocationNode:each];
        }
        if (![node hasChildren] && [WizObject fileCountOfLocation:node.locationKey]==0 && ![node.locationKey isEqualToString:@"/My Mobiles/"]) {
            [node.parentLocationNode removeChild:node];
        }
        [arr release];
    }
    else
    {
        if ([WizObject fileCountOfLocation:node.locationKey]==0 && ![node.locationKey isEqualToString:@"/My Mobiles/"] ) {
            [node.parentLocationNode removeChild:node];
        }
    }
}

- (void) makeSureParentExisted:(NSArray*)locationArray
{
    for (int i = 1; i < (NSInteger)[locationArray count] -1 ; i++) {
        NSString* key = [self restructLoactionKey:locationArray maxIndex:i];
        NSString* title = [locationArray objectAtIndex:i];
        LocationTreeNode* currentNode = [LocationTreeNode findNodeByKey:key :tree];
        if (nil == currentNode) {
            currentNode = [[LocationTreeNode alloc] init];
            currentNode.title = title;
            currentNode.locationKey = key;
            if (1 == i) {
                [tree addChild:currentNode];
            }
            else
            {
                NSString* parentKey = [self restructLoactionKey:locationArray maxIndex:i-1];
                LocationTreeNode* parentNode = [LocationTreeNode findNodeByKey:parentKey :tree];
                [parentNode addChild:currentNode];
            }
            [currentNode release];
        }
    }
}

-(void) reloadAllData
{
    NSArray* wizDocumentLoationTemp = [[[WizDbManager shareDbManager] shareDataBase] allLocationsForTree];
    NSMutableArray *wizDocumentLocations =[wizDocumentLoationTemp mutableCopy];
    tree = [[LocationTreeNode alloc]init];
    tree.deep = 0;
    tree.title = @"/";
    tree.locationKey = @"/";
    tree.hidden = YES;
    tree.expanded =YES;
    for(int i=0; i<[wizDocumentLocations count]; i++) {
        
        NSString *location = [wizDocumentLocations objectAtIndex:i];
        if ([location isEqualToString:@"/Deleted Items/"]) {
            continue;
        }
        NSArray* breakLocation = [location componentsSeparatedByString:@"/"];
        [self makeSureParentExisted:breakLocation];
        
    }
    [wizDocumentLocations release];
    [self removeBlockLocationNode:tree];
    self.displayNodes = [[[NSMutableArray alloc] initWithCapacity:40] autorelease];
    [tree.children sortUsingComparator:^(LocationTreeNode* l1, LocationTreeNode* l2)
    {
        return [l1.title compareFirstCharacter:l2.title];
    }];
    [LocationTreeNode getLocationNodes:tree :self.displayNodes];
    [self setNodeRow];
	[[self tableView] reloadData];
    
    self.tableFooterRemindView.frame = CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[self.displayNodes count]]);
    self.tableView.tableFooterView = self.tableFooterRemindView;
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = WizStrFolders;
    self.closedImage = [UIImage imageNamed:@"treePlus"];
    self.expandImage = [UIImage imageNamed:@"treeCut"];
    

    self.tableFooterRemindView.imageView.image = [UIImage imageNamed:@"folderTableFooter"];
    self.tableFooterRemindView.textLabel.text = NSLocalizedString(@"Folders allow you to organize your notes however you like. Your folders will sync with every version of WizNote you use.", nil);

}
- (void) setDetail:(LocationTreeViewCell *)cell
{
    NSInteger currentCount = [WizObject fileCountOfLocation:cell.treeNode.locationKey];
    NSInteger totalCount = [WizObject filecountWithChildOfLocation:cell.treeNode.locationKey];
    if (currentCount != totalCount) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d",currentCount,totalCount];
    }
    else {
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),currentCount];
    }
    if (![cell.treeNode hasChildren]) {
        cell.imageView.image = [UIImage imageNamed:@"treeFolder"];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        LocationTreeNode* node = [self.displayNodes objectAtIndex:indexPath.row];
        PhFolderListViewController* folder = [[PhFolderListViewController alloc] initWithFolder:node.locationKey];
        [self.navigationController pushViewController:folder animated:YES];
        [folder release];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}
@end
