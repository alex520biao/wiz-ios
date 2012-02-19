//
//  WizCheckProtectPassword.h
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizCheckProtectPassword : UIViewController <UITextFieldDelegate>
{
    UITextField* number1;
    UITextField* number2;
    UITextField* number3;
    UITextField* number4;
}
@property (nonatomic, retain) UITextField* number1;
@property (nonatomic, retain) UITextField* number2;
@property (nonatomic, retain) UITextField* number3;
@property (nonatomic, retain) UITextField* number4;
@end
