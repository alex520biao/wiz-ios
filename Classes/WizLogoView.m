//
//  WizLogoView.m
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizLogoView.h"


@implementation WizLogoView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
	}
    return self;
}


- (void)drawRect:(CGRect)rect 
{
	// Drawing code
	UIImage *image = [UIImage imageNamed:@"wizlogo.png"];
	CGSize imageSize = image.size ;
	CGRect imageRect = CGRectMake(CGRectGetMidX(rect)-imageSize.width/2, rect.origin.y, imageSize.width, imageSize.height);
	[image drawInRect:imageRect];
}


- (void)dealloc {
    [super dealloc];
}


@end
