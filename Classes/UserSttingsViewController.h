//
//  UserSttingsViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-13.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
@interface UserSttingsViewController:UITableViewController <UIAlertViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,MFMailComposeViewControllerDelegate>
{
    NSString* accountUserId;
    UITableViewCell *mobileViewCell;
    UILabel* mbileViewCellLabel;
    UISwitch* mobileViewSwitch;
    UITableViewCell* protectCell;
    UILabel*    protectCellNameLabel;
    UISwitch*   protectCellSwitch;
    UITableViewCell* defaultUserCell;
    UILabel* defaultUserLabel;
    UISwitch* defaultUserSwitch;
    NSString* oldPassword;
    NSString* accountProtectPassword;
    
    UIPickerView* pickView;
    NSArray* downloadDurationData;
    NSArray* imageQualityData;
    NSArray* downloadDurationRemind;
    int downloadDuration;
    int imageQulity;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) IBOutlet UITableViewCell *mobileViewCell;
@property (nonatomic, retain) IBOutlet UILabel* mbileViewCellLabel;
@property (nonatomic, retain) IBOutlet UISwitch* mobileViewSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* protectCell;
@property (nonatomic, retain) IBOutlet UILabel*    protectCellNameLabel;
@property (nonatomic, retain) IBOutlet UISwitch*   protectCellSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* defaultUserCell;
@property (nonatomic, retain) IBOutlet UILabel* defaultUserLabel;
@property (nonatomic, retain) IBOutlet UISwitch* defaultUserSwitch;
@property (nonatomic, retain) NSString* accountProtectPassword;
@property (nonatomic, retain) UIPickerView* pickView;
@property (nonatomic, retain) NSArray* downloadDurationData;
@property (nonatomic, retain) NSArray* imageQualityData;
@property (nonatomic, retain) NSArray* downloadDurationRemind;
@property int downloadDuration;
@property int imageQulity;
@property (nonatomic, retain) NSString* oldPassword;
- (IBAction)setUserProtectPassword:(id)sender;
@end
