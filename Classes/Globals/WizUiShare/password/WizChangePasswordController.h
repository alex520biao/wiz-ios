//
//  WizChangePasswordController.h
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizChangePasswordDelegate.h"
@class WizInputView;
@interface WizChangePasswordController : UIViewController <UIAlertViewDelegate, WizChangePasswordDelegate>
{
    WizInputView* oldPassword;
    WizInputView* passwordNew;
    WizInputView* passwordConfirmNew;
    NSString* accountUserId;
    UIAlertView* waitAlert;
}
@property (nonatomic, retain) WizInputView* oldPassword;
@property (nonatomic, retain) WizInputView* passwordNew;
@property (nonatomic, retain) WizInputView* passwordConfirmNew;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) UIAlertView* waitAlert;
@end
