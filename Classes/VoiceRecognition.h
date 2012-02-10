//
//  VoiceRecognition.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iFlyISR/IFlyRecognizeControl.h"
#define APPID @"4f093dc0"
#define ENGINE_URL @"http://dev.voicecloud.cn:1028/index.htm"
#define H_CONTROL_ORIGIN CGPointMake(20, 40)

@interface VoiceRecognition : UIView <IFlyRecognizeControlDelegate>
{
    IFlyRecognizeControl* iFlyRecongize;
    NSString* resuletString;
    UIImageView* image;
    UIView* parentView;
    id owner;
}
@property (retain) IFlyRecognizeControl* iFlyRecongize;
@property (nonatomic, retain) NSString* resuletString;
@property (nonatomic, retain) UIImageView* image;
@property (nonatomic, retain) UIView* parentView;
@property (nonatomic, retain)     id owner;
- (void) startRecognition;
- (id)initWithFrame:(CGRect)frame parentView:(UIView*) view;
@end
