//
//  LocationTreeViewCell.h
//  Wiz
//
//  Created by dong zhao on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTreeNode.h"
@protocol WizTreeExpandDelegate
- (void) onExpand:(LocationTreeNode*)node;
@end

@interface LocationTreeViewCell : UITableViewCell {
    SEL onExpand;
    id<WizTreeExpandDelegate> expandDelegate;
    UIImage* expandImage;
    UIImage* closedImage;
}
@property(nonatomic, assign) id<WizTreeExpandDelegate> expandDelegate;
@property(nonatomic, retain) LocationTreeNode* treeNode;
@property(nonatomic,retain) UIImage* expandImage;
@property(nonatomic,retain) UIImage* closedImage;
-(void)onExpandThis;
@end
