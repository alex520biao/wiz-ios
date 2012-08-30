//
//  WizPadTreeTableHeaderView.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>
#import "TreeNode.h"
@class WizPadTreeTableHeaderView;
@protocol WizPadTableHeaderDeleage <NSObject>
- (void) didSelectedHeader:(WizPadTreeTableHeaderView*)header forTreeNode:(TreeNode*)node;
- (void) addNewTreeNodeFrom:(NSString*)strNodeKey;
@end

@interface WizPadTreeTableHeaderView : UIView
{
    UILabel*  titleLabel;
    id<WizPadTableHeaderDeleage> delegate;
    TreeNode* treeNode;
}
@property (nonatomic, retain) TreeNode* treeNode;
@property (nonatomic ,assign) id<WizPadTableHeaderDeleage> delegate;
@property (nonatomic, readonly ,retain) UILabel* titleLabel;
- (void) showExpandedIndicatory;
@end
