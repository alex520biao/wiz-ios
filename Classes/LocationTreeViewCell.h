//
//  LocationTreeViewCell.h
//  Wiz
//
//  Created by dong zhao on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationTreeNode.h"

@interface LocationTreeViewCell : UITableViewCell {
    SEL onExpand;
    LocationTreeNode* treeNode;
    id owner;
    UIImage* expandImage;
    UIImage* closedImage;
}
@property (assign) SEL onExpand;
@property(nonatomic, retain) id owner;
@property(nonatomic, retain) LocationTreeNode* treeNode;
@property(nonatomic,retain) UIImage* expandImage;
@property(nonatomic,retain) UIImage* closedImage;
-(void)onExpandThis;
@end
