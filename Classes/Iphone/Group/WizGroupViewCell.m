//
//  WizGroupViewCell.m
//  Wiz
//
//  Created by 朝 董 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGroupViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation WizGroupViewCell
@synthesize imageView;
@synthesize textLabel;
- (void) dealloc
{
    [imageView release];
    [textLabel release];
    [super dealloc];
}

- (id) initWithSize:(CGSize)size
{
    self = [super init];
    if (self) {
        self.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        self.deleteButtonOffset = CGPointMake(-15, -15);
        UIView* content = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        self.contentView = content;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        //        view.layer.masksToBounds = NO;
        //        view.layer.cornerRadius = 8;
        imageView.image = [UIImage imageNamed:@"edit"];
        content.backgroundColor = [UIColor clearColor];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.alpha = 0.75;
        self.backgroundColor = [UIColor lightGrayColor];
        [content addSubview:imageView];
        NSLog(@"%f %f",size.height,size.width);
        textLabel= [[WizLabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        textLabel.verticalAlignment = VerticalAlignmentTop;
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        textLabel.textAlignment = UITextAlignmentCenter;
        textLabel.textColor = [UIColor whiteColor];
        textLabel.highlightedTextColor = [UIColor lightGrayColor];
        textLabel.font = [UIFont boldSystemFontOfSize:20];
        textLabel.numberOfLines = 0;
        textLabel.backgroundColor = [UIColor clearColor];
        [content addSubview:textLabel];
        textLabel.text = @"ddd";
        [textLabel setShadowColor:[UIColor lightGrayColor]];
        [textLabel setShadowOffset:CGSizeMake(1, 1)];
        content.layer.borderColor = [UIColor grayColor].CGColor;
        content.layer.borderWidth = 2.0f;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        
    }
    return self;
}
- (void) drawRect:(CGRect)rect
{
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:textLabel];
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
