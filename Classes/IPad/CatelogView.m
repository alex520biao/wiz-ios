//
//  CatelogView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogView.h"

@implementation CatelogView
@synthesize selectedDelegate;

- (void) dealloc
{
    selectedDelegate = nil;
    [super dealloc];
}
- (void) didSelectedCateLogView
{
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat height = 300;
        CGFloat width = 200;
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectedCateLogView)] autorelease];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [self addGestureRecognizer:tap];
        self.userInteractionEnabled = YES;
        backGroudImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0 , width, height-60)];
        [self addSubview:backGroudImageView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,height - 75 , width, 40)];
        nameLabel.numberOfLines = 0;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = UITextAlignmentCenter;
        nameLabel.textColor = [UIColor whiteColor];
        [self addSubview:nameLabel];

        
        documentsCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0,height - 35 , width, 20)];
        documentsCountLabel.backgroundColor = [UIColor clearColor];
        documentsCountLabel.textAlignment = UITextAlignmentCenter;
        documentsCountLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:documentsCountLabel];
        
        detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 38, 140, 160)];
        detailLabel.numberOfLines = 0;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.textColor = [UIColor grayColor];
        detailLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:detailLabel];
        
        self.backgroundColor = [UIColor clearColor];
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
