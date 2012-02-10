//
//  SortOptionsView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SortOptionsView : UITableViewController
{
    NSArray* options;
    id delegate;
    int kOrder;
}
@property (nonatomic, retain) NSArray* options;
@property (nonatomic, retain) id delegate;
@property int kOrder;
@end
