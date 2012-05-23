//
//  WizPadDocumentViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIBadgeView;
@interface WizPadDocumentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
{
    NSUInteger listType;
    NSString* documentListKey;
}
@property  NSUInteger listType;
@property (nonatomic, retain) NSString* documentListKey;
- (void) shrinkDocumentWebView;
- (void) zoomDocumentWebView;
@end
