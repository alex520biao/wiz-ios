//
//  UserSttingsViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UserSttingsViewController:UITableViewController <UIAlertViewDelegate>
{
    NSString* accountUserId;
    UITableViewCell *mobileViewCell;
    UILabel* mbileViewCellLabel;
    UISwitch* mobileViewSwitch;
    UITableViewCell* downloadDataDurationCell;
    UILabel*    downloadDataDurationCellNameLabel;
    UIAlertView* waitAlertView;
    UITableViewCell* protectCell;
    UILabel*    protectCellNameLabel;
    UISwitch*   protectCellSwitch;
    UITableViewCell* imageQualityCell;
    UILabel*          imageQualityLabel;
    UITableViewCell* defaultUserCell;
    UILabel* defaultUserLabel;
    UISwitch* defaultUserSwitch;
    NSString* oldPassword;
    NSString* newUserPassword;
    int downloadDuration;
    int imageQulity;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* newUserPassword;
@property (nonatomic, retain) IBOutlet UITableViewCell *mobileViewCell;
@property (nonatomic, retain) IBOutlet UILabel* mbileViewCellLabel;
@property (nonatomic, retain) IBOutlet UISwitch* mobileViewSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* downloadDataDurationCell;
@property (nonatomic, retain) IBOutlet UILabel*    downloadDataDurationCellNameLabel;
@property (nonatomic, retain) IBOutlet UITableViewCell* imageQualityCell;
@property (nonatomic, retain) IBOutlet UILabel*          imageQualityLabel;
@property (nonatomic, retain) IBOutlet UITableViewCell* protectCell;
@property (nonatomic, retain) IBOutlet UILabel*    protectCellNameLabel;
@property (nonatomic, retain) IBOutlet UISwitch*   protectCellSwitch;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) IBOutlet UITableViewCell* defaultUserCell;
@property (nonatomic, retain) IBOutlet UILabel* defaultUserLabel;
@property (nonatomic, retain) IBOutlet UISwitch* defaultUserSwitch;
@property int downloadDuration;
@property int imageQulity;
@property (nonatomic, retain) NSString* oldPassword;
- (IBAction)setUserProtectPassword:(id)sender;
- (void) imageQualityChanged:(id)sender;
- (void) downloadDurationChanged:(id)sender;
@end
