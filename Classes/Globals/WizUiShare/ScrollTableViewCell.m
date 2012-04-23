//
//  ScrollTableViewCell.m
//  Wiz
//
//  Created by dong zhao on 11-11-23.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ScrollTableViewCell.h"

@implementation ScrollTableViewCell
@synthesize attach;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 60, 30)] autorelease];
        label.text = @"ddddddddddd";
        [self addSubview:label];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if(selected)
    {
        if([self viewWithTag:100] != nil)
        {
            [[self viewWithTag:100] removeFromSuperview];
        }
        else {
            if([attach.type isEqualToString:@"png"] )
            {
//                UIScrollView* scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320, 420)];
//                UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:attach.AttachLocation]];
//                [scrollView addSubview:imageView];
//                scrollView.contentSize=CGSizeMake(800, 600);
//                [self addSubview:scrollView];
//                [self bringSubviewToFront:scrollView];
//                scrollView.tag = 100;
//                scrollView.scrollEnabled = YES;
//                scrollView.userInteractionEnabled = YES;
//                [imageView release];
//                [scrollView release];
            }
        }
    }
    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
