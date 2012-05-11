//
//  WizSingleSelectViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSingleSelectDelegate.h"
@interface WizSingleSelectViewController : UITableViewController
{
    id<WizSingleSelectDelegate> singleSelectDelegate;
}

@property (nonatomic, retain) id<WizSingleSelectDelegate> singleSelectDelegate;
- (id) initWithValusAndLastIndex:(NSArray*)array    lastIndex:(NSInteger)index;
@end
