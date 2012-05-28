//
//  UserSttingsViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WizSingleSelectDelegate.h"
#import "WizSyncDescriptionDelegate.h"

@interface UserSttingsViewController:UITableViewController <WizSyncDescriptionDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,WizSingleSelectDelegate>
@end
