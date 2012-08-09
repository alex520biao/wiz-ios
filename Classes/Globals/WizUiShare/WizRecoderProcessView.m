//
//  WizRecoderProcessView.m
//  Wiz
//
//  Created by wiz on 12-7-10.
//
//

#import "WizRecoderProcessView.h"

@interface WizRecoderProcessView ()
{
    NSMutableArray* processInicatorView;
    UIView* indicatorView;
}
@end

@implementation WizRecoderProcessView

@dynamic currentProcess;
@dynamic maxProcess;

- (NSInteger) maxProcess
{
    return maxProcess;
}
- (NSInteger) currentProcess
{
    return currentProcess;
}

- (void) setMaxProcess:(NSInteger)maxProcess_
{
    maxProcess = maxProcess_;
}

- (void) setCurrentProcess:(NSInteger)currentProcess_
{
    currentProcess = currentProcess_;
    float width = self.frame.size.width;
    float currentWidth = width/maxProcess*currentProcess;
    indicatorView.frame = CGRectMake(currentWidth, 0.0, 2, self.frame.size.height);
}
- (void) dealloc
{
    [processInicatorView dealloc];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        processInicatorView = [[NSMutableArray alloc] init];
        indicatorView = [[UIView alloc] init];
        [self addSubview:indicatorView];
        indicatorView.backgroundColor = [UIColor redColor];
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
