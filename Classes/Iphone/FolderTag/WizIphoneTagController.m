//
//  WizIphoneTagController.m
//  Wiz
//
//  Created by wiz on 12-8-29.
//
//

#import "WizIphoneTagController.h"
#import "WizDbManager.h"
#import "WizNotification.h"
#import "PhTagListViewController.h"

@implementation WizIphoneTagController

- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}

- (id) initWithRootTreeNode:(NSString *)nodeKey
{
    self = [super initWithRootTreeNode:nodeKey];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(reloadAllData) name:MessageTypeOfUpdateFolderTable];
    }
    return self;
}

- (void) addTagTreeNodeToParent:(WizTag*)tag   rootNode:(TreeNode*)root  allTags:(NSArray*)allTags
{
    TreeNode* node = [[TreeNode alloc] init];
    node.title = getTagDisplayName(tag.title);
    node.keyString = tag.guid;
    node.isExpanded = NO;
    node.strType = WizTreeViewTagKeyString;
    if (tag.parentGUID == nil || [tag.parentGUID isEqual:@""]) {
        [root addChildTreeNode:node];
    }
    else
    {
        TreeNode* parentNode = [root childNodeFromKeyString:tag.parentGUID];
        if(nil != parentNode)
        {
            [parentNode addChildTreeNode:node];
        }
        else
        {
            WizTag* parent = nil;
            for (WizTag* each in allTags) {
                if ([each.guid isEqualToString:tag.parentGUID]) {
                    parent = each;
                }
            }
            [self addTagTreeNodeToParent:parent rootNode:root allTags:allTags];
            parentNode = [root childNodeFromKeyString:parent.parentGUID];
            [parentNode addChildTreeNode:node];
        }
    }
    [node release];
}

- (void) reloadTagRootNode
{

    NSArray* tagArray = [[[WizDbManager shareDbManager] shareDataBase] allTagsForTree];
    TreeNode* tagRootNode = rootTreeNode;
    
    [tagRootNode removeAllChildrenNodes];
    
    for (WizTag* each in tagArray) {
        if (each.title != nil && ![each.title isEqualToString:@""]) {
            [self addTagTreeNodeToParent:each rootNode:tagRootNode allTags:tagArray];
        }
    }
}

- (void) reloadAllTreeNodes
{
    [self reloadTagRootNode];
}

- (void) decorateTreeCell:(WizPadTreeTableCell *)cell
{
    TreeNode* node = [rootTreeNode childNodeFromKeyString:cell.strTreeNodeKey];
    if (node == nil) {
        return;
    }
    NSInteger fileNumber = [WizTag fileCountOfTag:node.keyString];
    NSString* count = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),fileNumber];
    cell.detailLabel.text = count;
    cell.titleLabel.text = getTagDisplayName(node.title);
}
- (void) deleteTreeNodeContentData:(NSString *)key
{
    [WizTag deleteLocalTag:key];
}
- (UIImage*) placeHolderImage
{
    return [UIImage imageNamed:@"treeItemTag"];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        TreeNode* node = [needDisplayTreeNodes objectAtIndex:indexPath.row];
        PhTagListViewController* tagView = [[PhTagListViewController alloc] initWithTagGuid:node.keyString];
        [self.navigationController pushViewController:tagView animated:YES];
        [tagView release];
    }
}
- (UIImage*) tableFootRemindImage
{
    return [UIImage imageNamed:@"tagTableFooter"];
}
- (NSString*) tableFootRemindString
{
    return NSLocalizedString(@"Tap on a tag above to see all notes with that tag. Make your notes easier to find by creating and assinging more tags.", nil);
}
//
- (NSString*) deletedAlertTitle
{
    return NSLocalizedString(@"Delete Tag", nil);
}
- (NSString*) deletedAlertMessage:(TreeNode*)node
{
    return [NSString stringWithFormat:NSLocalizedString(@"You will delete the tag %@ , are you sure?", nil), getTagDisplayName(node.title)];
}
- (BOOL) isDeletedVaild:(TreeNode*)node
{
    return ![node.title isEqualToString:WizTagPublic];
}
//
- (TreeNode*) createNewTreeNode:(NSString*)title fromeRootNode:(TreeNode*)node
{
    NSString* parentGuid = nil;
    WizTag* tag = [[[WizTag alloc] init] autorelease];
    tag.guid = [WizGlobals genGUID];
    tag.title = title;
    tag.parentGUID = parentGuid;
    [tag save];
    TreeNode* nodeAdded = [[TreeNode alloc] init];
    nodeAdded.title = title;
    nodeAdded.strType = WizTreeViewTagKeyString;
    nodeAdded.keyString = tag.guid;
    [node addChildTreeNode:nodeAdded];
    return [nodeAdded autorelease];
}
- (NSString*) addNodeAlertTitle
{
    return NSLocalizedString(@"Add Tag", nil);
}

- (NSString*) alertTextfiledPlaceHolder
{
    return NSLocalizedString(@"Tag title", nil);
}
- (BOOL) isAddTreeNodeVaild:(NSString *)title
{
    BOOL isTagExist = [[[WizDbManager shareDbManager] shareDataBase] isExistTagWithTitle:title];
    NSLog(@"title is %@ exist is %d",title, isTagExist);
    if (isTagExist) { 
        [WizGlobals reportWarningWithString:[NSString stringWithFormat:NSLocalizedString(@"Tag named %@ exists!", nil),title]];
    }
    return !isTagExist;
}

@end
