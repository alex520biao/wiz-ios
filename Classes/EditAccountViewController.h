//
//  EditAccountViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/10/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface EditAccountViewController : UIViewController
{
	UITableView *tableView;
	
	UITableViewCell *userIdTableViewCell;
	UITableViewCell *passwordTableViewCell;
	UITableViewCell *removeAccountTableViewCell;
	UITableViewCell *downloadAllDocumentsViewCell;
	UITableViewCell *downloadDocumentDataViewCell;
	UITableViewCell *protectViewCell;
    UITableViewCell *mobileViewCell;
    UITableViewCell *userTrafficProcessCell;
    UISlider* userTrafficUsedProgress;
	//
	UILabel* userIDLabel;
	UITextField* passwordTextField;
	UISwitch* downloadAllDocumentsSwitch;
	UISwitch* downloadDocumentDataSwitch;
	UISwitch* passwordProtectSwitch;
    UISwitch* mobileViewSwitch;
	//
	NSString* accountUserId;
	NSString* accountPassword;
	//
	UIAlertView* waitAlertView;
}
@property (nonatomic, retain) IBOutlet UITableViewCell* mobileViewCell;
@property (nonatomic, retain) IBOutlet  UISwitch* mobileViewSwitch;
@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* userIdTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* passwordTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* downloadAllDocumentsViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* downloadDocumentDataViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* removeAccountTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* protectViewCell;
@property (nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property (nonatomic, retain) IBOutlet UILabel* userIDLabel;
@property (nonatomic, retain) IBOutlet UISwitch* downloadAllDocumentsSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* downloadDocumentDataSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* passwordProtectSwitch;
@property (nonatomic, retain) IBOutlet UITableViewCell *userTrafficProcessCell;
@property (nonatomic, retain) IBOutlet  UISlider* userTrafficUsedProgress;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
@property (nonatomic, retain) UIAlertView* waitAlertView;

- (IBAction) cancel: (id)sender;
- (IBAction) save: (id)sender;
- (IBAction) removeAccount: (id)sender;
- (IBAction) textFieldDoneEditing: (id)sender;

- (void) xmlrpcDone: (NSNotification*)nc;
@end
