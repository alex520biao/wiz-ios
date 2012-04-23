//
//  TagsListTreeView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TagsListTreeView.h"

#import "WizGlobalData.h"
#import "LocationTreeNode.h"
#import "LocationTreeViewCell.h"
#import "TagDocumentListView.h"
#import "WizDbManager.h"
@implementation TagsListTreeView

@synthesize accountUserId;
@synthesize displayTree;
@synthesize tree;

- (void) dealloc
{
    [accountUserId release];
    [displayTree release];
    [tree release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
   
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
-(void) setNodeRow {
    int i=0;
    for(LocationTreeNode* each in self.displayTree) {
        each.row = i++;
    }
}
-(void)onExpand:(LocationTreeNode*)node{
    
    if(!node.expanded)
    {
        for( int i = node.row+1; i < [self.displayTree count];) 
        {
            NSIndexPath *index = [NSIndexPath indexPathForRow:i inSection:0];
            LocationTreeNode* each = [self.displayTree objectAtIndex:i];
            if(![LocationTreeNode isChildToNode:node :each] )  break;
            [self.displayTree removeObject:each];
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
                [self.displayTree insertObject:each atIndex:i];
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

- (WizTag*) findTagInArray:(NSString*)tagGuid :(NSArray*) tagArray
{
    for (WizTag* each in tagArray)
    {
        if ([each.guid isEqualToString:tagGuid] ) {
            return each;
        }
    }
    return nil;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];

   
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
//    NSArray* tagArray = [[[WizGlobalData sharedData] indexData:accountUserId] allTagsForTree];
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    tree = [[LocationTreeNode alloc]init] ;
//    tree.deep = 0;
//    tree.title = @"/";
//    tree.locationKey = @"/";
//    tree.hidden = YES;
//    tree.expanded =YES;
//    for (WizTag* each in tagArray)
//    {
//        LocationTreeNode* node = [[LocationTreeNode alloc] init];
//        node.title = each.title;
//        node.locationKey = each.guid;
//        if (nil != each.parentGUID && ![each.parentGUID isEqualToString:@""]) {
//            LocationTreeNode* parent = [LocationTreeNode findNodeByKey:each.parentGUID :self.tree];
//            if (nil == parent) {
//                WizTag* parentTag = [[WizDbManager shareDbManager] tagFromGuid:each.parentGUID];
//                LocationTreeNode* nodee = [[LocationTreeNode alloc] init];
//                nodee.title = parentTag.title;
//                nodee.locationKey = parentTag.guid;
//                [tree addChild:parent];
//                [nodee addChild:node];
//                [nodee release];
//                [node release];
//                continue;
//            }
//            else
//            {
//                [parent addChild:node];
//                [node release];
//                continue;
//            }
//        }
//        else
//        {
//            [tree addChild:node];
//            [node release];
//        }
//        
//    }
//    if (nil == self.displayTree) {
//        self.displayTree = [NSMutableArray array];
//    } else
//    {
//        [self.displayTree removeAllObjects];
//    }
//    [LocationTreeNode getLocationNodes:self.tree :self.displayTree];
//    [self setNodeRow];
//    [self.tableView reloadData];
//
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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

    return [self.displayTree count];
}
-(void)configCell:(LocationTreeViewCell*)cell :(LocationTreeNode*)node{
	cell.selectionStyle=UITableViewCellSelectionStyleNone;
	NSString* filename;
	NSPredicate* predicate=[NSPredicate predicateWithFormat:
							@"SELF LIKE '01*' "];
	if ([predicate evaluateWithObject:node.locationKey]) {
		filename=@"tagListIcon";
	}else {
		filename=@"tagListIcon";
	}
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    cell.imageView.image = [UIImage imageNamed:filename];
    cell.textLabel.text = node.title;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[index fileCountOfLocation:node.locationKey]];
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellId = @"FolderCell";
    LocationTreeViewCell *cell =(LocationTreeViewCell*)[tableView dequeueReusableCellWithIdentifier:CellId];
	if (cell == nil)
	{
		cell = [[[LocationTreeViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:CellId] autorelease];
	}
	LocationTreeNode* node = [self.displayTree objectAtIndex:indexPath.row];
    [cell setOwner:self];
    [cell setOnExpand:@selector(onExpand:)];
    [cell setTreeNode:node];
    [self configCell:cell :node];
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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    if (0 == indexPath.section)
//	{
//		if (indexPath.row < [self.displayTree count])
//		{
//			WizTag* tag =  [ index tagFromGuid:[[self.displayTree objectAtIndex:indexPath.row] locationKey]];;
//			//
//			TagDocumentListView* tagView = [[TagDocumentListView alloc] initWithStyle:UITableViewStylePlain];
//			tagView.tag = tag;
//			[self.navigationController pushViewController:tagView animated:YES];
//			[tagView release];
//			return;
//		}
//    }
}
@end
