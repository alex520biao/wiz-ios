//
//  WizDecorate.m
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDecorate.h"

@implementation WizDecorate
+ (UIFont*) nameFont
{
    static UIFont* nameFont = nil;
    if(nameFont == nil)
    {
        nameFont = [UIFont boldSystemFontOfSize:15];
    }
    return nameFont;
}

+ (NSString*) nameToDisplay:(NSString*)str   width:(CGFloat)width
{
    UIFont* nameFont = [WizDecorate  nameFont];
    CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, 20);
    CGSize requiredSize = [str sizeWithFont:nameFont constrainedToSize:boundingSize
                              lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat requireWidth = requiredSize.width;
    if (requireWidth > width) {
        if (nil == str || str.length <=1) {
            return @"";
        }
        return [WizDecorate  nameToDisplay:[str substringToIndex:str.length-1 ] width:width];
    }
    else
    {
        return str;
    }
}
@end
