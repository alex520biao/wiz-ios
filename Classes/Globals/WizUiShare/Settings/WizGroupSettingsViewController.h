//
//  WizGroupSettingsViewController.h
//  Wiz
//
//  Created by wiz on 12-6-26.
//
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WizSingleSelectDelegate.h"

@interface WizGroupSettingsViewController : UITableViewController <WizSingleSelectDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@end
