//
//  TreeTableViewBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TreeTableViewBase : UITableViewController
{
    NSMutableArray* staticTree;
    NSMutableArray* motiveTree;
}
@property (nonatomic, retain) NSMutableArray* staticTree;
@property (nonatomic, retain) NSMutableArray* motiveTree;
@end
