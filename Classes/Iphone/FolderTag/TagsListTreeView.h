//
//  TagsListTreeView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-12.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocationTreeNode;
@interface TagsListTreeView : UITableViewController
{
    NSString* accountUserId;
    LocationTreeNode* tree;
    NSMutableArray* displayTree;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) LocationTreeNode* tree;
@property (nonatomic, retain) NSMutableArray* displayTree;
@end
