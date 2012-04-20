//
//  WizAddAcountViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizVerifyAccount.h"
@class WizInputView;
@interface WizAddAcountViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,WizVerifyAccountDeletage>
{
    WizInputView* nameInput;
    WizInputView* passwordInput;
    UITableView* existAccountsTable;
    UIAlertView* waitAlertView;
    NSMutableArray* fitAccounts;

}
@property (nonatomic,retain) WizInputView* nameInput;
@property (nonatomic,retain) WizInputView* passwordInput;
@property (nonatomic,retain) UIAlertView* waitAlertView;
@property (nonatomic,retain) UITableView* existAccountsTable;
@property (nonatomic,retain) NSMutableArray* fitAccounts;
@end
