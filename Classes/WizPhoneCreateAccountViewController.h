//
//  WizPhoneCreateAccountViewController.h
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizInputView;
@interface WizPhoneCreateAccountViewController : UIViewController <UITextFieldDelegate>
{
    WizInputView* idInputView;
    WizInputView* passwordInputView;
    WizInputView* confirmInputView;
    UIButton* registerButton;
    UIAlertView* waitAlertView;
}
@property (nonatomic, retain) WizInputView* idInputView;
@property (nonatomic, retain) WizInputView* passwordInputView;
@property (nonatomic, retain) WizInputView* confirmInputView;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain)    UIButton* registerButton;

- (void) xmlrpcDone: (NSNotification*)nc;
@end
