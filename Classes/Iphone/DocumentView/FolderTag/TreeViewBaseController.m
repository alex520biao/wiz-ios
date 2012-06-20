//
//  TreeViewBaseController.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TreeViewBaseController.h"
#import "LocationTreeNode.h"

#import "WizApi.h"

#import "WizGlobals.h"
#import "WizGlobalData.h"

@implementation TreeViewBaseController
@synthesize isWillReloadAllData;
@synthesize locations;
@synthesize tree, displayNodes;
@synthesize closedImage;
@synthesize expandImage;
- (void) dealloc
{
    [tree release];
    [displayNodes release];
	[locations release];
    [closedImage release];
    [expandImage release];
    [super dealloc];
}
-(void) setNodeRow {
    int i=0;
    for(LocationTreeNode* each in displayNodes) {
        each.row = i++;
    }
}

- (void) willReloadAllData
{
    self.isWillReloadAllData = YES;
}
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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isWillReloadAllData = YES;
    }
    return self;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"folder retain count %d",[self retainCount]);
    if (self.isWillReloadAllData) {
        [self reloadAllData];
        self.isWillReloadAllData = !self.isWillReloadAllData;
    }
    NSLog(@"folder retain count %d",[self retainCount]);
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"folder retain count %d",[self retainCount]);
    [super viewWillDisappear:animated];
    NSLog(@"folder retain count %d",[self retainCount]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"folder retain count %d",[self retainCount]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.displayNodes count];
}

-(void)configCell:(LocationTreeViewCell*)cell :(LocationTreeNode*)node{
	cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = NSLocalizedString(node.title, nil);
    cell.textLabel.backgroundColor = [UIColor clearColor];

    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.closedImage = self.closedImage;
    cell.expandImage = self.expandImage;
    if (node.expanded) {
        cell.imageView.image = self.expandImage;
    }
    else
    {
        cell.imageView.image = self.closedImage;
    }
    if (![node hasChildren]) {
        cell.imageView.image = [UIImage imageNamed:@"treeFolder"];
    }
    [self setDetail:cell];
   
}

- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static NSString* CellNoChild = @"Cell";
    LocationTreeNode* node = [displayNodes objectAtIndex:indexPath.row];
    LocationTreeViewCell *cell = (LocationTreeViewCell*)[tableView dequeueReusableCellWithIdentifier:CellNoChild];
    if (!cell) {
        cell = [[[LocationTreeViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellNoChild] autorelease]; ;
        cell.expandDelegate = self;
    }
    [cell setTreeNode:node];
    [self configCell:cell :node];
	return cell;
}
#pragma mark - Table view delegate


- (NSInteger) tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LocationTreeNode* node = [self.displayNodes objectAtIndex:indexPath.row];
    NSUInteger ret = node.deep-1;
    return  ret;
}
- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [viewController viewWillAppear:animated];
}
@end
