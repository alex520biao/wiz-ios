//
//  WizEditItemBackgroudView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizEditItemBackgroudView.h"


@implementation WizEditItemBackgroudView
@synthesize imageView;
@synthesize label;

- (void) dealloc
{
    [imageView release];
    [label release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect subFrame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        CAGradientLayer* gradient = [CAGradientLayer layer];
        gradient.borderColor = [UIColor colorWithRed:159/256.0 green:159/256.0 blue:159/256.0 alpha:1.0].CGColor;
        gradient.borderWidth = 0.5f;
        gradient.shadowColor = [UIColor whiteColor].CGColor;
        gradient.shadowOffset = CGSizeMake(1, 1);
        gradient.shadowOpacity = 0.5;
        gradient.shadowRadius = 0.9;
        gradient.frame = subFrame;
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[UIColor colorWithRed:241/256.0 green:241/256.0 blue:241/256.0 alpha:1.0].CGColor,
                           (id)[UIColor colorWithRed:207/256.0 green:207/256.0 blue:207/256.0 alpha:1.0].CGColor,
                           
                           nil];
        gradient.cornerRadius = 2;
        gradient.masksToBounds = YES;
        [self.layer insertSublayer:gradient atIndex:0];
        UIImageView* imV = [[UIImageView alloc] initWithFrame:CGRectMake(18, 13, 24, 24)];
        self.imageView = imV;
        [self addSubview:imV];
        [imV release];
        
        UILabel* startLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 15, 50, 20)];
        startLabel.adjustsFontSizeToFitWidth = YES;
        startLabel.backgroundColor = [UIColor clearColor];
        [startLabel setFont:[UIFont systemFontOfSize:13]];
        [startLabel setTextColor:[UIColor grayColor]];
        startLabel.textAlignment = UITextAlignmentLeft;
        self.label = startLabel;
        [self addSubview:startLabel];
        [startLabel release];
    }
    return self;
}
- (void) setTargetAndSelector:(id)target  selector:(SEL)selector
{
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
    tap.numberOfTapsRequired = 1;
     tap.numberOfTouchesRequired =1;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap];
    [tap release];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

@end
