//
//  WizPhoneAbstractImageView.m
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizPhoneAbstractImageView.h"

@implementation WizPhoneAbstractImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CALayer* layer = [self layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.5;
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
