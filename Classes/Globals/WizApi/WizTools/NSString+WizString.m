//
//  NSString+WizString.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+WizString.h"

@implementation NSString (WizString)
- (BOOL) isBlock
{
    return nil == self ||[self isEqualToString:@""];
}
- (NSString*) fileName
{
    return [[self componentsSeparatedByString:@"/"] lastObject];
}
- (NSString*) fileType
{
    NSString* fileName = [self fileName];
    if (fileName == nil || [fileName isBlock]) {
        return nil;
    }
    return [[fileName componentsSeparatedByString:@"."] lastObject];
}
- (NSString*) stringReplaceUseRegular:(NSString*)regex
{
    NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
    return [reg stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
}
@end
