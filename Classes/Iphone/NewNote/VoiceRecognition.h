//
//  VoiceRecognition.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iFlyMSC/IFlyRecognizeControl.h>
#define APPID @"4f093dc0"
#define ENGINE_URL @"http://dev.voicecloud.cn:1028/index.htm"
#define H_CONTROL_ORIGIN CGPointMake(20, 40)

@protocol WizVoiceRecognitionDelegate <NSObject>

- (void) prepareForVoiceRecognitionStart;
- (void) didVoiceRecognitionEnd:(NSString*)string;

@end

@interface VoiceRecognition : UIView <IFlyRecognizeControlDelegate>
{
    IFlyRecognizeControl* iFlyRecongize;
    NSString* resuletString;
    UIView* parentView;
    id<WizVoiceRecognitionDelegate> recognitionDelegate;
}
@property (retain) IFlyRecognizeControl* iFlyRecongize;
@property (nonatomic, retain) NSString* resuletString;
@property (nonatomic, retain) UIView* parentView;
@property (nonatomic, assign) id<WizVoiceRecognitionDelegate> recognitionDelegate;
- (void) startRecognition;
- (id)initWithFrame:(CGRect)frame parentView:(UIView*) view;
@end
