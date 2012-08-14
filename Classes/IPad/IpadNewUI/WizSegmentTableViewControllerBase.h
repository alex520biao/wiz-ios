//
//  WizSegmentTableViewControllerBase.h
//  Wiz
//
//  Created by wiz on 12-8-14.
//
//

#import <UIKit/UIKit.h>
#import "WizSegmentOrientationDelegate.h"
@interface WizSegmentTableViewControllerBase : UITableViewController
{
    id<WizSegmentOrientationDelegate> orientationDelegate;
}
@property (nonatomic, assign) id<WizSegmentOrientationDelegate> orientationDelegate;
@end
