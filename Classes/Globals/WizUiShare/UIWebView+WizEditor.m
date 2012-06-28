//
//  UIWebView+WizEditor.m
//  Wiz
//
//  Created by 朝 董 on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIWebView+WizEditor.h"

@implementation UIWebView (WizEditor)
- (UIColor *)colorFromRGBValue:(NSString *)rgb { // General format is 'rgb(red, green, blue)'
    if ([rgb rangeOfString:@"rgb"].location == NSNotFound)
        return nil;
    
    NSMutableString *mutableCopy = [rgb mutableCopy];
    [mutableCopy replaceCharactersInRange:NSMakeRange(0, 4) withString:@""];
    [mutableCopy replaceCharactersInRange:NSMakeRange(mutableCopy.length-1, 1) withString:@""];
    
    NSArray *components = [mutableCopy componentsSeparatedByString:@","];
    int red = [[components objectAtIndex:0] intValue];
    int green = [[components objectAtIndex:1] intValue];
    int blue = [[components objectAtIndex:2] intValue];
    
    UIColor *retVal = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    [mutableCopy release];
    return retVal;
}
- (void)bold {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Bold\")"];
}

- (void)italic {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Italic\")"];
}

- (void)underline {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand(\"Underline\")"];
}
- (void)undo {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
}

- (void)redo {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
}
@end
