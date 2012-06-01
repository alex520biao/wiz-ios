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
#import "WizSettingsParentNavigationDelegate.h"
#import "WizPadNewNoteViewNavigationDelegate.h"

@interface WizPadMainViewController : UIViewController <WizPadNewNoteViewNavigationDelegate,WizSettingsParentNavigationDelegate,UIPopoverControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate,WizSearchHistoryDelegate,WizPadViewDocumentDelegate>
- (void) refreshAccountBegin:(id) sender;
@end
