//
//  WizIphoneTreeController.h
//  Wiz
//
//  Created by wiz on 12-8-28.
//
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"
#import "WizPadTreeTableCell.h"
#import "WizTreeRemindView.h"
@interface WizIphoneTreeController : UITableViewController<WizPadTreeTableCellDelegate>
{
    TreeNode* rootTreeNode;
    NSMutableArray* needDisplayTreeNodes;
}
@property (nonatomic, retain) NSIndexPath* deleteLastPath;
- (id) initWithRootTreeNode:(NSString *)nodeKey;
- (void) reloadAllTreeNodes;
- (void) deleteTreeNodeContentData:(NSString*)key;
- (void) willDeleteTreeNode:(NSIndexPath*)indexPath;
- (void) deleteTreeNode:(NSIndexPath*)indexPath;
- (void) reloadAllData;
//
- (UIImage*) tableFootRemindImage;
- (NSString*) tableFootRemindString;
@end
