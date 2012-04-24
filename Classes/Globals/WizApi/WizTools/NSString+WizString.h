//
//  NSString+WizString.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WizString)
- (BOOL) isBlock;
- (NSString*) fileName;
- (NSString*) fileType;
- (NSString*) stringReplaceUseRegular:(NSString*)regex;
- (NSDate *) dateFromSqlTimeString;
//help
-(NSString*) trim;
-(NSString*) trimChar:(unichar) ch;
-(int) indexOfChar:(unichar)ch;
-(int) indexOf:(NSString*)find;
-(int) lastIndexOfChar: (unichar)ch;
-(int) lastIndexOf:(NSString*)find;
-(NSString*) firstLine;
-(NSString*) toHtml;

-(NSString*) toValidPathComponent;
@end