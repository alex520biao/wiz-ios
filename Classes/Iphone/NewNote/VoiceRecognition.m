//
//  VoiceRecognition.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceRecognition.h"
#import "WizGlobals.h"
#import <iFlyMSC/IFlyRecognizeControl.h>

@interface VoiceRecognition()
{
    UIButton* recognitionButton;
}

@end

@implementation VoiceRecognition
@synthesize iFlyRecongize;
@synthesize resuletString;
@synthesize parentView;
@synthesize recognitionDelegate;
- (void) dealloc
{
    [iFlyRecongize release];
    [recognitionButton release];
    [resuletString release];
    [parentView release];
    recognitionDelegate = nil;
    [super dealloc];
}

- (void) startRecognition
{
    [self.recognitionDelegate prepareForVoiceRecognitionStart];
    if (![self.iFlyRecongize start]) {
        [WizGlobals toLog:@"start flyRecongized error!"];
    }
}


- (void)onRecognizeEnd:(IFlyRecognizeControl *)iFlyRecognizeControl theError:(SpeechError) error
{
    [self.recognitionDelegate didVoiceRecognitionEnd:self.resuletString];
    self.resuletString = @"";
}
- (void)onRecognizeResult:(NSArray *)array
{
	self.resuletString = [[array objectAtIndex:0] objectForKey:@"NAME"];
}

- (void)onResult:(IFlyRecognizeControl *)iFlyRecognizeControl theResult:(NSArray *)resultArray
{
	[self onRecognizeResult:resultArray];
}
- (id)initWithFrame:(CGRect)frame parentView:(UIView*)pView
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *initParam = [[NSString alloc] initWithFormat:
                               @"server_url=%@,appid=%@",ENGINE_URL,APPID];
        // 识别控件
        
        IFlyRecognizeControl* recg  = nil;
        if ([WizGlobals WizDeviceIsPad]) {
           recg = [[IFlyRecognizeControl alloc] initWithOrigin:CGPointMake(284, 284) theInitParam:initParam];
        }
        else
        {
            recg = [[IFlyRecognizeControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];
        }
        self.iFlyRecongize = recg;
        [recg release];
        [pView addSubview:self.iFlyRecongize];
        [self.iFlyRecongize setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
        [self.iFlyRecongize setSampleRate:16000];
        self.iFlyRecongize.delegate = self;
        [initParam release];
        
        recognitionButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [recognitionButton setImage:[UIImage imageNamed:@"voiceInput"] forState:UIControlStateNormal];
        [recognitionButton addTarget:self action:@selector(startRecognition) forControlEvents:UIControlEventTouchUpInside];
       
        [self addSubview:recognitionButton];
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
