//
//  WizChangePasswordController.h
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizInputView;
@interface WizChangePasswordController : UIViewController
{
    WizInputView* oldPassword;
    WizInputView* passwordNew;
    WizInputView* passwordConfirmNew;
    NSString* accountUserId;
}
@property (nonatomic, retain) WizInputView* oldPassword;
@property (nonatomic, retain) WizInputView* passwordNew;
@property (nonatomic, retain) WizInputView* passwordConfirmNew;
@property (nonatomic, retain) NSString* accountUserId;
@end
