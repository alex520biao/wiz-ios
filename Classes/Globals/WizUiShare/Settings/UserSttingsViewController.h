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
    UITableViewCell *mobileViewCell;
    UILabel* mbileViewCellLabel;
    UISwitch* mobileViewSwitch;
    UITableViewCell* protectCell;
    UILabel*    protectCellNameLabel;
    UISwitch*   protectCellSwitch;
    UITableViewCell* defaultUserCell;
    UILabel* defaultUserLabel;
    UISwitch* defaultUserSwitch;
    NSString* accountProtectPassword;
    UITableViewCell* connectViaWifiCell;
    UILabel* connectViaWifiLabel;
    UISwitch* connectViaWifiSwitch;
    UIPickerView* pickView;
    NSArray* downloadDurationData;
    NSArray* imageQualityData;
    NSArray* downloadDurationRemind;
    NSArray* viewOptions;
    int downloadDuration;
    int imageQulity;
    int tablelistViewOption;
}
@property (nonatomic, retain) NSArray* viewOptions;
@property (nonatomic, retain) IBOutlet UITableViewCell *mobileViewCell;
@property (nonatomic, retain) IBOutlet UILabel* mbileViewCellLabel;
@property (nonatomic, retain) IBOutlet UISwitch* mobileViewSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* protectCell;
@property (nonatomic, retain) IBOutlet UILabel*    protectCellNameLabel;
@property (nonatomic, retain) IBOutlet UISwitch*   protectCellSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* defaultUserCell;
@property (nonatomic, retain) IBOutlet UILabel* defaultUserLabel;
@property (nonatomic, retain) IBOutlet UISwitch* defaultUserSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell* connectViaWifiCell;
@property (nonatomic, retain) IBOutlet UILabel* connectViaWifiLabel;
@property (nonatomic, retain) IBOutlet UISwitch* connectViaWifiSwitch;
@property (nonatomic, retain) NSString* accountProtectPassword;
@property (nonatomic, retain) UIPickerView* pickView;
@property (nonatomic, retain) NSArray* downloadDurationData;
@property (nonatomic, retain) NSArray* imageQualityData;
@property (nonatomic, retain) NSArray* downloadDurationRemind;
@property int downloadDuration;
@property int imageQulity;
@property int tablelistViewOption;
- (IBAction)setUserProtectPassword:(id)sender;
- (IBAction)setMobileView:(id)sender;
- (IBAction)setDownloadOnlyByWifi:(id)sender;
@end
