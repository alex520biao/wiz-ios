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
@synthesize owner;
- (void) dealloc
{
    [image release];
    [iFlyRecongize release];
    [resuletString release];
    [parentView release];
    [owner release];;
    [super dealloc];
}

- (void) startRecognition
{
    if ([self.iFlyRecongize start]) {
    
    }
}



- (void)onRecognizeEnd:(IFlyRecognizeControl *)iFlyRecognizeControl theError:(SpeechError) error
{
    [owner performSelector:@selector(voiceInputOver:) withObject:self.resuletString];
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
- (id)initWithFrame:(CGRect)frame parentView:(UIView*) view
{
    self = [super initWithFrame:frame];
    if (self) {
        self.parentView = view;
        NSString *initParam = [[NSString alloc] initWithFormat:
                               @"server_url=%@,appid=%@",ENGINE_URL,APPID];
        // 识别控件
        IFlyRecognizeControl* recg  = [[IFlyRecognizeControl alloc] initWithOrigin:H_CONTROL_ORIGIN theInitParam:initParam];
        self.iFlyRecongize = recg;
        [recg release];
        [self.parentView addSubview:self.iFlyRecongize];
        [self.iFlyRecongize setEngine:@"sms" theEngineParam:nil theGrammarID:nil];
        [self.iFlyRecongize setSampleRate:16000];
        self.iFlyRecongize.delegate = self;
        [initParam release];
        UIImageView* _image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _image.image = [UIImage imageNamed:@"voiceInput"];
        [self addSubview:_image];
        self.image = _image;
        [_image release];
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
