//
//  FoldersViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "FoldersViewController.h"
#import "WizGlobalData.h"
#import "WizIndex.h"

//#import "FolderViewController.h"
#import "FolderListView.h"

@implementation FoldersViewController

@synthesize accountUserId;
@synthesize locations;
@synthesize tree, displayNodes;

-(void)onExpand:(LocationTreeNode*)node{

    if(!node.expanded)
    {
        for( int i = node.row+1; i < [displayNodes count];) 
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            LocationTreeNode* each = [displayNodes objectAtIndex:i];
            if(![LocationTreeNode isChildToNode:node :each] )  break;
            [displayNodes removeObject:each];
            NSArray* delteIndexPathAttay = [[NSArray alloc] initWithObjects:index, nil];
            [self.tableView deleteRowsAtIndexPaths:delteIndexPathAttay withRowAnimation:UITableViewRowAnimationTop];
            [delteIndexPathAttay release];
            [self setNodeRow];
        }

    }
    else {
        NSMutableArray* array = [[NSMutableArray alloc] init ];
        [array removeAllObjects];
        NSMutableArray *index = [[NSMutableArray alloc] init ];
        if([node hasChildren]) {
            [LocationTreeNode getLocationNodes:node :array];
            int i = node.row +1;
            for(LocationTreeNode* each in array ) {
                if(each == node) continue;
                NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
                [displayNodes insertObject:each atIndex:i];
                NSArray* insertIndexPathArray = [[NSArray alloc] initWithObjects:index, nil];
                [self.tableView insertRowsAtIndexPaths:insertIndexPathArray withRowAnimation:UITableViewRowAnimationTop];
                [insertIndexPathArray release];
                i++;

            }
        [self setNodeRow];
        }
        [array release];
        [index release];
    }

}
-(id) init
{
    self = [super init];
    self.title = WizStrFolders;
    self.tabBarItem.image = [UIImage imageNamed:@"folders.png"];
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidUnload
{
   
	[super viewDidUnload];
}

- (void) dealloc
{

    [accountUserId release];
    [locations release];
    [tree release];
    [displayNodes release];
	[super dealloc];
}
-(void) setNodeRow {
    int i=0;
    for(LocationTreeNode* each in displayNodes) {
        each.row = i++;
    }
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//
	self.locations = nil;
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{

	return [displayNodes count];
}

-(void)configCell:(LocationTreeViewCell*)cell :(LocationTreeNode*)node{
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	NSString* filename;
	NSPredicate* predicate=[NSPredicate predicateWithFormat:
							@"SELF LIKE '01*' "];
	if ([predicate evaluateWithObject:node.locationKey]) {
		filename=@"icon_for_folder";
	}else {
		filename=@"icon_for_folder";
	}
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    cell.imageView.image = [UIImage imageNamed:filename];
    cell.textLabel.text = node.title;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[index fileCountOfLocation:node.locationKey]];	
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    if (![node hasChildren]) {
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    }
}


- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	NSString* CellId = [NSString stringWithFormat:@"%@%d",@"FolderCell",indexPath.row];
    static NSString* CellNoChild = @"cell_no_child";
    LocationTreeNode* node = [displayNodes objectAtIndex:indexPath.row];
    LocationTreeViewCell *cell = nil;
    if (![node hasChildren]) {
        cell=(LocationTreeViewCell*)[tableView dequeueReusableCellWithIdentifier:CellNoChild];
        if (cell == nil)
        {
            cell = [[[LocationTreeViewCell alloc]
                     initWithStyle:UITableViewCellStyleValue1
                     reuseIdentifier:CellNoChild] autorelease];
        }
    }
    
    else
    {
        cell=(LocationTreeViewCell*)[tableView dequeueReusableCellWithIdentifier:CellId];
        if (cell == nil)
        {
            cell = [[[LocationTreeViewCell alloc]
                     initWithStyle:UITableViewCellStyleValue1
                     reuseIdentifier:CellId] autorelease];
        }

    }
	
	
      
    [cell setOwner:self];
    [cell setOnExpand:@selector(onExpand:)];
    [cell setTreeNode:node];
    [self configCell:cell :node];
	return cell;
}
-(void)onSelectedRow:(NSIndexPath *)indexPath :(LocationTreeNode*)node{
	NSString* subLocation = [[self.displayNodes objectAtIndex:indexPath.row] locationKey];
    //
    FolderListView* folderView = [[FolderListView alloc] initWithStyle:UITableViewStylePlain];
    
    folderView.accountUserID = accountUserId;
    folderView.location = subLocation;
    //
    [self.navigationController pushViewController:folderView animated:YES];
    //
    [folderView release];
    return;
}
#pragma mark -
#pragma mark Table View Delegate Methods
- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    LocationTreeViewCell* cell = (LocationTreeViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell onExpandThis];
}
-(void) didReceiveMemoryWarning
{
    [[self tableView]reloadData];
}

- (NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{

    LocationTreeNode* node = [self.displayNodes objectAtIndex:indexPath.row];
    NSUInteger ret = node.deep-1;
    return  ret;
}


@end
