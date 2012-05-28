//
//  WizPadRegisterController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizCreateAccount.h"
@class WizInputView;
@interface WizPadRegisterController : UIViewController <WizCreateAccountDelegate>
{
    WizInputView* accountEmail;
    WizInputView* accountPassword;
    WizInputView* accountPasswordConfirm;
    UIAlertView* waitAlertView;
}
@property (nonatomic, retain) WizInputView* accountEmail;
@property (nonatomic, retain) WizInputView* accountPassword;
@property (nonatomic, retain) WizInputView* accountPasswordConfirm;
@property (nonatomic,retain) UIAlertView* waitAlertView;
@end
