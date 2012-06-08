//
//  WizLabel.m
//  Wiz
//
//  Created by 朝 董 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizLabel.h"

@implementation WizLabel


- (VerticalAlignment) verticalAlignment
{
    return verticalAlignment;
}

- (void) setVerticalAlignment:(VerticalAlignment)verticalAlignment_
{
    verticalAlignment = verticalAlignment_;
    [self setNeedsDisplay];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.highlightedTextColor = [UIColor lightGrayColor];
        self.lineBreakMode = UILineBreakModeCharacterWrap;
        self.numberOfLines = 0;
        self.adjustsFontSizeToFitWidth = YES;
        verticalAlignment = VerticalAlignmentTop;
    }
    return self;
}

- (void) setWidth:(CGFloat)width
{
    if (self.numberOfLines == 0) {
        NSInteger lines = ceil([self.text sizeWithFont:self.font].width/width);
        super.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, lines*self.font.lineHeight);
    }
}

- (void) setHeight:(CGFloat)height
{
    if (self.numberOfLines == 0) {
        NSInteger lines = ceil(height/self.font.lineHeight);
        super.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [self.text sizeWithFont:self.font].width/lines  , height);
        
    }
}

- (void) setFrame:(CGRect)frame
{
    if (frame.size.height == 0) {
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, 0, 0)];
        [self setWidth:frame.size.width];
    }
    else if (frame.size.width == 0) {
        [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, 0, 0)];
        [self setHeight:frame.size.height];
    }
    else {
        [super setFrame:frame];
    }
}

- (CGRect) textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect rect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    CGRect result;
    switch (verticalAlignment) {
        case VerticalAlignmentTop:
            result = CGRectMake(bounds.origin.x, bounds.origin.y, rect.size.width, rect.size.height);
            break;
            
        case VerticalAlignmentBottom:
            result = CGRectMake(bounds.origin.x, bounds.origin.y+ (bounds.size.height - rect.size.height)/2, rect.size.width, rect.size.height);
            break;
        case VerticalAlignmentMiddle:
            result = CGRectMake(bounds.origin.x, bounds.origin.y+(bounds.size.height -rect.size.height), rect.size.width, rect.size.height);
            break;
        default:
            result = rect;
            break;
    }
    return result;
}
- (void) drawRect:(CGRect)rect
{
    CGRect r = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:r];
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
