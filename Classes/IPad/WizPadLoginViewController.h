//
//  WizPagLoginViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizPadLoginViewController : UIViewController <UIAlertViewDelegate>
{
    @private
    UIButton* loginButton;
    UIImageView* backgroudView;
    UIButton* registerButton;
    UIButton* checkExistedAccountButton;
    UILabel* CripytLabel;
    BOOL firstLoad;
}
@property (nonatomic, retain) IBOutlet UIButton* loginButton;
@property (nonatomic, retain) IBOutlet UIImageView* backgroudView;
@property (nonatomic, retain) IBOutlet  UIButton* registerButton;
@property (nonatomic, retain) IBOutlet UIButton* checkExistedAccountButton;
@property (nonatomic, retain) IBOutlet UILabel* CripytLabel;
- (IBAction)loginViewAppear:(id)sender;
- (IBAction)registerViewApper:(id)sender;
- (IBAction)checkOtherAccounts:(id)sender;
@end
