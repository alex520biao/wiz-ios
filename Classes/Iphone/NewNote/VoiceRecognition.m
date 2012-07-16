//
//  VoiceRecognition.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceRecognition.h"
#import "WizGlobals.h"
#import "iFlyISR/IFlyRecognizeControl.h"
@implementation VoiceRecognition
@synthesize image;
@synthesize iFlyRecongize;
@synthesize resuletString;
@synthesize parentView;
@synthesize recognitionDelegate;
- (void) dealloc
{
    [image release];
    [iFlyRecongize release];
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
        IFlyRecognizeControl* recg  = [[IFlyRecognizeControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];
        self.iFlyRecongize = recg;
        [recg release];
        [pView addSubview:self.iFlyRecongize];
        [self.iFlyRecongize setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
        [self.iFlyRecongize setSampleRate:16000];
        self.iFlyRecongize.delegate = self;
        [initParam release];
        UIImageView* _image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _image.image = [UIImage imageNamed:@"voiceInput"];
        [self addSubview:_image];
        self.image = _image;
        [_image release];
        
        
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startRecognition)] autorelease];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
        
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
