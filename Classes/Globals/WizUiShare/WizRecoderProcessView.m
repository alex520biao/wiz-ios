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
}
@end

@implementation WizRecoderProcessView

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
