//
//  WizIphoneTreeController.m
//  Wiz
//
//  Created by wiz on 12-8-28.
//
//

#import "WizIphoneTreeController.h"

@interface WizIphoneTreeController () 

@end

@implementation WizIphoneTreeController
- (void) dealloc
{
    [rootTreeNode release];
    [needDisplayTreeNodes release];
    [super dealloc];
}
- (id) initWithRootTreeNode:(NSString *)nodeKey
{
    self = [super init];
    if (self) {
        TreeNode* folderRootNode = [[TreeNode alloc] init];
        folderRootNode.title   = nodeKey;
        folderRootNode.keyString = nodeKey;
        folderRootNode.isExpanded = YES;
        rootTreeNode = folderRootNode;
        needDisplayTreeNodes = [[NSMutableArray array] retain];
    }
    return self;
}

- (void) reloadAllTreeNodes
{
    
}

- (void) reloadAllData
{
    [self reloadAllTreeNodes];
    [needDisplayTreeNodes removeAllObjects];
    [needDisplayTreeNodes addObjectsFromArray:[rootTreeNode allExpandedChildrenNodes]];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [needDisplayTreeNodes count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadTreeTableCell";
    WizPadTreeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[WizPadTreeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    cell.strTreeNodeKey = node.keyString;
    [cell showExpandedIndicatory];
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
}

- (TreeNode*) findTreeNodeByKey:(NSString*)strKey
{
    return [rootTreeNode childNodeFromKeyString:strKey];
}
- (void) onExpandedNode:(TreeNode *)node
{
    NSInteger row = NSNotFound;
    for (int i = 0 ; i < [needDisplayTreeNodes count]; i++) {

        TreeNode* eachNode = [needDisplayTreeNodes objectAtIndex:i];
        if ([eachNode.keyString isEqualToString:node.keyString]) {
            row = i;
            break;
        }
    }
    if(row != NSNotFound)
    {
        [self onExpandNode:node refrenceIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    }
}

- (void) onExpandNode:(TreeNode*)node refrenceIndexPath:(NSIndexPath*)indexPath
{
    
    if (!node.isExpanded) {
        node.isExpanded = YES;
        NSArray* array = [node allExpandedChildrenNodes];
        
        NSInteger startPostion = [needDisplayTreeNodes count] == 0? 0: indexPath.row+1;
        
        NSMutableArray* rows = [NSMutableArray array];
        for (int i = 0; i < [array count]; i++) {
            NSInteger  positionRow = startPostion+ i;
            
            TreeNode* node = [array objectAtIndex:i];
            [needDisplayTreeNodes insertObject:node atIndex:positionRow];
            
            [rows addObject:[NSIndexPath indexPathForRow:positionRow inSection:indexPath.section]];
        }
        
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    else
    {
        node.isExpanded = NO;
        NSMutableArray* deletedIndexPaths = [NSMutableArray array];
        NSMutableArray* deletedNodes = [NSMutableArray array];
        for (int i = indexPath.row; i < [needDisplayTreeNodes count]; i++) {
            TreeNode* displayedNode = [needDisplayTreeNodes objectAtIndex:i];
            if ([node childNodeFromKeyString:displayedNode.keyString]) {
                [deletedIndexPaths addObject:[NSIndexPath indexPathForRow:i inSection:indexPath.section]];
                [deletedNodes addObject:displayedNode];
            }
        }
        
        for (TreeNode* each in deletedNodes) {
            [needDisplayTreeNodes removeObject:each];
        }
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:deletedIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
    
}

- (void) showExpandedIndicatory:(WizPadTreeTableCell*)cell
{
    
    NSLog(@"cell keystring is %@",cell.strTreeNodeKey);
    
    TreeNode* node = [self findTreeNodeByKey:cell.strTreeNodeKey];
    if ([node.childrenNodes count]) {
        if (!node.isExpanded) {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treeClosed"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.expandedButton setImage:[UIImage imageNamed:@"treeOpened"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [cell.expandedButton setImage:nil forState:UIControlStateNormal];
    }
}
- (void) onExpandedNodeByKey:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    if (node) {
        [self onExpandedNode:node];
    }
}
- (NSInteger) treeNodeDeep:(NSString*)strKey
{
    TreeNode* node = [self findTreeNodeByKey:strKey];
    return node.deep;
}
- (void) decorateTreeCell:(WizPadTreeTableCell*)cell
{
    
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"array is %@",needDisplayTreeNodes);
    [self reloadAllData];
}
- (void) deleteTreeNodeContentData:(NSString*)key
{
    
}

- (void) willDeleteTreeNode:(NSIndexPath*)indexPath
{

}

- (void) deleteTreeNode:(NSIndexPath*)indexPath
{
    TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
    [node.parentTreeNode removeChildTreeNode:node];
    if (node.isExpanded) {
        [self onExpandedNode:node];
    }
    NSArray* tags = [node allChildren];
    for (TreeNode* eachNode in tags) {
        [self deleteTreeNodeContentData:eachNode.keyString];
    }
    [self deleteTreeNodeContentData:node.keyString];
    [needDisplayTreeNodes removeObjectAtIndex:indexPath.row];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (indexPath.row > 0) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row -1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self willDeleteTreeNode:indexPath];
    }
}

@end
