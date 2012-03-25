//
//  LoginViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, UINavigationControllerDelegate>
{
    UITableViewCell* userNameCell;
    UILabel*         userNameLabel;
    UITextField*     userNameTextField;
    UITableViewCell* userPasswordCell;
    UITableViewCell* addAccountCell;
    UIButton*        addAccountButton;
    UILabel*         userPasswordLabel;
    UITextField*    userPasswordTextField;
    UITableView*     contentTableView;
    UIButton*       loginButton;
    UIAlertView*    waitAlertView;
    UIButton*       createdAccountButton;
    UIButton* checkOtherAccountButton;
    NSArray* accountsArray;
    NSString* selecteAccountId;
    BOOL firstLoad;
    BOOL willAddUser;
}
@property (nonatomic, retain) IBOutlet UITableViewCell* userNameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell* userPasswordCell;
@property (nonatomic, retain) IBOutlet UILabel*         userNameLabel;
@property (nonatomic, retain) IBOutlet UITextField*     userNameTextField;
@property (nonatomic, retain) IBOutlet UILabel*         userPasswordLabel;
@property (nonatomic, retain) IBOutlet UITextField*    userPasswordTextField;
@property (nonatomic, retain) IBOutlet UIButton*     loginButton;
@property (nonatomic, retain) IBOutlet UITableViewCell* addAccountCell;
@property (nonatomic, retain) IBOutlet UIButton*        addAccountButton;
@property (nonatomic, retain) IBOutlet UIButton*        createdAccountButton;
@property (nonatomic, retain) IBOutlet UIButton* checkOtherAccountButton;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) UITableView* contentTableView;
@property (nonatomic, retain) NSArray* accountsArray;
@property (nonatomic, retain)   NSString* selecteAccountId;
@property (assign)  BOOL firstLoad;
@property (assign)  BOOL willAddUser;
- (void) xmlrpcDone: (NSNotification*)nc;
- (IBAction)userLogin:(id)sender;
- (void)addAccountEntry;
- (IBAction) getNewAccount:(id)sender;
- (IBAction) checkOtherAccounts:(id)sender;

@end
