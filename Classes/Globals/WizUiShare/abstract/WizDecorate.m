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

//+ (NSDictionary*) getDetailAttributes
//{
//    static NSMutableDictionary* detailAttributes = nil;
//    if (detailAttributes == nil) {
//        detailAttributes = [[NSMutableDictionary alloc] init];
//        UIFont* textFont = [UIFont systemFontOfSize:13];
//        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
//        [detailAttributes setObject:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
//        [detailAttributes setObject:(id)textCtfont forKey:(NSString*)kCTFontAttributeName];
//    }
//    return detailAttributes;
//}
//+ (NSDictionary*) getNameAttributes
//{
//    static NSMutableDictionary* nameAttributes = nil;
//    if (nameAttributes == nil) {
//        nameAttributes = [[NSMutableDictionary alloc] init];
//        UIFont* stringFont = [WizDecorate  nameFont];
//        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
//        [nameAttributes setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
//        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
//        CTParagraphStyleSetting settings[]={lineBreakMode};
//        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
//        [nameAttributes setObject:(id)paragraphStyle forKey:(NSString*)kCTParagraphStyleAttributeName];
//    }
//    return nameAttributes;
//}
//
//+ (NSDictionary*) getTimeAttributes
//{
//    static NSMutableDictionary* timeAttributes=nil;
//    if (timeAttributes == nil) {
//        timeAttributes = [[NSMutableDictionary alloc] init];
//        [timeAttributes setObject:(id)[[UIColor lightGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
//    }
//    return timeAttributes;
//}


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
