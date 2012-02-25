//
//  SearchHistoryView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface SearchHistoryView : UITableViewController
{
    NSString* accountUserId;
    NSMutableArray* history;
    id          owner;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSMutableArray* history;
@property (nonatomic, retain) id            owner;

- (void) reloadData;
@end
