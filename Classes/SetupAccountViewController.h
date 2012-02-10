//
//  SetupAccountViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/9/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SetupAccountViewController : UIViewController
{
	UITableView *tableView;

	UITableViewCell *userIdTableViewCell;
	UITableViewCell *passwordTableViewCell;
	UITableViewCell *downloadAllDocumentsViewCell;
	UITableViewCell *downloadDocumentDataViewCell;
	UITableViewCell *protectViewCell;

	UITextField* userIdTextField;
	UITextField* passwordTextField;
	UISwitch* downloadAllDocumentsSwitch;
	UISwitch* downloadDocumentDataSwitch;
	UISwitch* passwordProtectSwitch;
	//
	UIAlertView* waitAlertView;
}

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UITableViewCell* userIdTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* passwordTableViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* downloadAllDocumentsViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* downloadDocumentDataViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* protectViewCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* moblieViewCell;
@property (nonatomic, retain) IBOutlet UITextField* userIdTextField;
@property (nonatomic, retain) IBOutlet UITextField* passwordTextField;
@property (nonatomic, retain) IBOutlet UISwitch* downloadAllDocumentsSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* downloadDocumentDataSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* passwordProtectSwitch;
@property (nonatomic, retain) IBOutlet UISwitch* mobileViewSwitch;


@property (nonatomic, retain) UIAlertView* waitAlertView;

- (IBAction) cancel: (id)sender;
- (IBAction) save: (id)sender;
- (IBAction) textFieldDoneEditing: (id)sender;


- (void) xmlrpcDone: (NSNotification*)nc;

@end
