//
//  WizAddAcountViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizInputView;
@interface WizAddAcountViewController : UIViewController
{
    WizInputView* nameInput;
    WizInputView* passwordInput;
    UIAlertView* waitAlertView;
}
@property (nonatomic,retain) WizInputView* nameInput;
@property (nonatomic,retain) WizInputView* passwordInput;
@property (nonatomic,retain) UIAlertView* waitAlertView;
@end
