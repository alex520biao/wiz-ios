//
//  WizPadMainViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizPadViewDocumentDelegate.h"
#import "SearchHistoryView.h"

@interface WizPadMainViewController : UIViewController <UIPopoverControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate,WizSearchHistoryDelegate,WizPadViewDocumentDelegate>
- (void) refreshAccountBegin:(id) sender;
@end
