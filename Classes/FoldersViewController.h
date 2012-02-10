//
//  FoldersViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationTreeViewCell.h"

@interface FoldersViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>{
	NSString* accountUserId;
	NSArray* locations;
    NSMutableArray *displayNodes;
    LocationTreeNode* tree;
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSArray* locations;
@property(nonatomic, retain) NSMutableArray* displayNodes;
@property(nonatomic,retain) LocationTreeNode* tree;

-(void)onExpand:(LocationTreeNode*)node;
-(void) setNodeRow;
@end
