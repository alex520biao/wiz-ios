//
//  UIRecognizeController.h
//  MSC20Demo

//  description:转写演示类

//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDemoBaseController.h"
#import "iFlyMSC/IFlyRecognizeControl.h"
#import "UIRecognizeSetupController.h"


// 按键坐标
// the button coordinates
#define H_BUTTON_RECOGNIZE			CGRectMake(50, 300, 80, 40)
#define H_BUTTON_RECOGNIZE_SETUP	CGRectMake(190, 300, 80, 40)


#define SECTION_TITLE1 @"识别结果"
#define SECTION_TITLE2 @"用户操作"

#define BUTTON_TITLE1  @"开始听写"
#define BUTTON_TITLE2  @"设置"

#define TITLE @"转写演示"


@interface UIRecognizeController : UIDemoBaseController <IFlyRecognizeControlDelegate>
{
	UIButton *_recognizeButton;
	UIButton *_setupButton;
	
	IFlyRecognizeControl		*_iFlyRecognizeControl;         //识别控件,recognizer
	UIRecognizeSetupController	*_recoginzeSetupController;     
}

@end
