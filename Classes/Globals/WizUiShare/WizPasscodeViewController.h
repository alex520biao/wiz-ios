//
//  WizPasscodeViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
enum WizCheckPasscodeType
{
    WizCheckPasscodeTypeOfNew,
    WizCheckPasscodeTypeOfClear,
    WizcheckPasscodeTypeOfCheck,
};

typedef NSUInteger WizCheckPasscodeType;
@interface WizPasscodeViewController : UIViewController <UITextFieldDelegate>
{
    WizCheckPasscodeType checkType;
}
@property (assign) WizCheckPasscodeType checkType;
@end
