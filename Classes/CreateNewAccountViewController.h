//
//  CreateNewAccountViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-15.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CreateNewAccountViewController : UIViewController <UITextFieldDelegate>
{
    UILabel* userIdLabel;
    UILabel* userPasswordLabel;
    UILabel* userPasswordAssertLabel;
    
    UITextField* userIdTextFiled;
    UITextField* userPasswordAsserTextField;
    UITextField* userPasswordTextFiled;
    
    UIButton* registerButton;
    UIImageView* backgroudVIew;
    CGRect  frameRect;
    CGRect  userIdRect;
    CGRect  passwordRect;
    CGRect  assertPasswordRect;
    
    UIAlertView* waitAlertView;
    
    id owner;
}
@property (nonatomic, retain) IBOutlet UILabel* userIdLabel;
@property (nonatomic, retain) IBOutlet UILabel* userPasswordLabel;
@property (nonatomic, retain) IBOutlet UILabel* userPasswordAssertLabel;

@property (nonatomic, retain) IBOutlet UITextField* userIdTextFiled;
@property (nonatomic, retain) IBOutlet UITextField* userPasswordAsserTextField;
@property (nonatomic, retain) IBOutlet UITextField* userPasswordTextFiled;

@property (nonatomic, retain) IBOutlet  UIButton* registerButton;

@property (nonatomic, retain) IBOutlet UIImageView* backgroudVIew;
@property (nonatomic, retain) UIAlertView* waitAlertView;

@property     CGRect  frameRect;
@property     CGRect  userIdRect;
@property     CGRect  passwordRect;
@property    CGRect  assertPasswordRect;

@property (nonatomic, retain) id owner;

- (void) xmlrpcDone: (NSNotification*)nc;
- (IBAction) save: (id)sender;
@end
