//
//  WizCheckProtectPassword.h
//  Wiz
//
//  Created by wiz on 12-2-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MessageOfCheckPasswordMakesure @"MessageOfCheckPasswordMakesure"

@interface WizCheckProtectPassword : UIViewController <UITextViewDelegate>
{ 
    UITextView* number1;
    UITextView* number2;
    UITextView* number3;
    UITextView* number4;
    NSString* finalPassword;
    BOOL willMakeSure;
    BOOL isMakeSure;
}
@property (nonatomic, retain) UITextView* number1;
@property (nonatomic, retain) UITextView* number2;
@property (nonatomic, retain) UITextView* number3;
@property (nonatomic, retain) UITextView* number4;
@property (nonatomic, retain)  NSString* finalPassword;
@property BOOL willMakeSure;
@property BOOL isMakeSure;
@end
