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
#import "MBProgressHUD.h"
#import "WizSettingsParentNavigationDelegate.h"
#import "WizFolderSelectDelegate.h"

@interface UserSttingsViewController:UITableViewController <WizFolderSelectDelegate,MBProgressHUDDelegate,UIActionSheetDelegate,WizSyncDescriptionDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate,WizSingleSelectDelegate>
{
    id<WizSettingsParentNavigationDelegate> navigationDelegate;
}
@property (atomic, assign) id<WizSettingsParentNavigationDelegate> navigationDelegate;
@end
