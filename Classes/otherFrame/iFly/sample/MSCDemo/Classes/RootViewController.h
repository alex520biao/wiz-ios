//
//  RootViewController.h
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIRecognizeController.h"
#import "UISynthesizerController.h"

#define RECOGNIZE_TITLE @"语音识别技术，是将声音转换为文字，让机器能够听懂您的声音。它包括听写技术和关键字识别技术，\
前者可以翻译出您说的日常用语、热词、视频和地点信息等，而后者能够针对性的识别您指定的关键词集。"

#define SYNTHESIZER_TITLE @"语音合成技术，是将文字转换为声音，让机器能够把文字读给您听。"

#define BUTTON_TITLE1  @"立即体验语音听写"
#define BUTTON_TITLE3 @"立即体验语音合成"

#define SECTION_TITLE1 @"语音识别"
#define SECTION_TITLE2 @"语音合成"

#define TITLE @"讯飞语音控件"

@interface RootViewController : UITableViewController 
{
	// UI
	UIRecognizeController		*_recognizeController;
	UISynthesizerController		*_synthesizerController;
	
	// 中间变量
	NSArray *_tableArray;
}

@end
