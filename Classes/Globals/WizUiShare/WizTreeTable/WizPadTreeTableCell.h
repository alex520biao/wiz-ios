//
//  WizPadTreeTableCell.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"
#define WizTreeViewTagKeyString         @"treeTag"
#define WizTreeViewFolderKeyString      @"treeLocation"
@protocol WizPadTreeTableCellDelegate <NSObject>

- (void) onExpandedNode:(TreeNode*)node;

@end

@interface WizPadTreeTableCell : UITableViewCell
{
    TreeNode* treeNode;
    UIButton*  expandedButton;
    UILabel*  titleLabel;
    UILabel*    detailLabel;
    id<WizPadTreeTableCellDelegate> delegate;
}
@property (nonatomic,  retain)     UIButton*  expandedButton;
@property (nonatomic,  retain)   UILabel*  titleLabel;
@property (nonatomic,  retain)   UILabel*    detailLabel;
@property (nonatomic, retain) TreeNode* treeNode;
@property (nonatomic, assign)  id<WizPadTreeTableCellDelegate> delegate;
- (void) showExpandedIndicatory;
@end
