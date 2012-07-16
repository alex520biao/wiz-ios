//
//  UIWebView+WizEditor.m
//  Wiz
//
//  Created by 朝 董 on 12-6-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIWebView+WizEditor.h"
#import "NSString+WizString.h"

#define  WizNotCmdInditify @"<Wiznote-dzpqzb>"


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
    return retVal;
}
- (void)bold {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('Bold')"];
}

- (void)italic {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('Italic')"];
}

- (void)underline {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('Underline')"];
}
- (void)undo {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
}

- (void)redo {
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
}

- (NSString*) getDocumentBodyHtml
{
    return [self stringByEvaluatingJavaScriptFromString:@"getDocumentEditedBodyHtml();"];
}
- (NSString*) getRelativePath:(NSString*)path
{
    NSInteger indexOfEditDir = [path indexOf:@"index_files"];
    NSString* ralativePath = path;
    if (indexOfEditDir != NSNotFound) {
        ralativePath = [path substringFromIndex:indexOfEditDir];
    }
    return ralativePath;
}
- (void) insertImage:(NSString*)imagePath
{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"insertPhoto('%@')",[self getRelativePath:imagePath]]];
}
- (BOOL) insertAudio:(NSString*)audioPath
{
    NSString* pat = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"insertAudio('%@')",[self getRelativePath:audioPath]]];
    return ![pat isEqualToString:@"false"];
}
- (void) focusEditor
{
    [self stringByEvaluatingJavaScriptFromString:@"focusEditor()"];
}

- (void) highlightText
{
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'yellow')"];
}

- (void) strikeThrough
{
    [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('strikeThrough')"];
}
- (void)highlight {
    NSString *currentColor = [self stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('backColor')"];
    if ([currentColor isEqualToString:@"rgb(255, 255, 0)"]) {
        [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'white')"];
    } else {
        [self stringByEvaluatingJavaScriptFromString:@"document.execCommand('backColor', false, 'yellow')"];
    }
}
- (void)fontSizeUp {
    int size = [[self stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] + 1;
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
}

- (void)fontSizeDown {
    int size = [[self stringByEvaluatingJavaScriptFromString:@"document.queryCommandValue('fontSize')"] intValue] - 1;
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.execCommand('fontSize', false, '%i')", size]];
}
- (void) prapareForEdit
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"editor" withExtension:@"js"];
    NSString* string = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
    [self stringByEvaluatingJavaScriptFromString:string];
}

- (void) prapareForEditLessThan5
{
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"commenEditorLessThan5" withExtension:@"js"];
//    NSURL* url = [[NSBundle mainBundle] URLForResource:@"editorLess5" withExtension:@"js"];

    NSString* string = [NSString stringWithContentsOfURL:url usedEncoding:nil error:nil];
    
    [self stringByEvaluatingJavaScriptFromString:string];
}
- (NSArray*) decodeJsCmd:(NSString*)urlCmd
{
    if (!urlCmd) {
        return nil;
    }
    NSString* cmd = [urlCmd URLDecodedString];
    NSInteger indexOfWizCmdIndity = [cmd indexOf:WizNotCmdInditify compareOptions:NSCaseInsensitiveSearch];
    if (NSNotFound == indexOfWizCmdIndity) {
        return nil;
    }
    NSLog(@"cmd is%@",[cmd substringFromIndex:indexOfWizCmdIndity]);
    NSMutableArray* array =[NSMutableArray arrayWithArray:[[cmd substringFromIndex:indexOfWizCmdIndity] componentsSeparatedByString:WizNotCmdInditify]];
    if ([[array objectAtIndex:0] isBlock]) {
        [array removeObjectAtIndex:0];
    }
    return array;
}
- (BOOL) deleteImage
{
   NSString* ret = [self stringByEvaluatingJavaScriptFromString:@"deleteImage()"];
    
    if ([ret isEqualToString:@"false"]) {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (void) insertText:(NSString*)text
{
    [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"insertText('%@')", text]];
}

@end
