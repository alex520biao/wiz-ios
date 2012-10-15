//
//  UIRecognizeSetupController.h
//  MSC20Demo

//  description: 识别控件设置类

//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIDemoBaseController.h"
#import "iFlyMSC/IFlyRecognizeControl.h"

#define H_VAD_KEYWORD_LABEL_FRAME		CGRectMake(20, 60, 130, 40)
#define H_VAD_KEYWORD_SWITCH_FRAME		CGRectMake(170, 65, 100, 40)

#define H_SEG_LABEL_FRAME				CGRectMake(20, 110, 130, 40)
#define H_SEG_FRAME						CGRectMake(120, 110, 150, 40)

#define H_AREA_FRAME					CGRectMake(10, 170, 120, 50)

#define SECTION_TITLE1 @"选择"
#define SECTION_TITLE2 @"类型"

#define TITLE @"转写设置"

@interface UIRecognizeSetupController : UIDemoBaseController <UIPickerViewDataSource,UIPickerViewDelegate> 
{
	// UI
	UIPickerView				*_areaPickerView;
	
	UILabel						*_recognizeTypeLabel;	
	UISegmentedControl			*_recognizeTypeSegment;
	
	IFlyRecognizeControl		*_iFlyRecognizeControl; //语音识别控件
	NSInteger					_selectRow;
	
	NSArray						*_pickerViewArray;
}

// init the iFlyRecognizeControl
// 初始化识别控件
- (id)initWithRecognize:(IFlyRecognizeControl *)iFlyRecognizeControl;

@end
