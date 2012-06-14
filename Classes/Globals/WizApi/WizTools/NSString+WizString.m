//
//  NSString+WizString.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+WizString.h"

@implementation NSString (WizString)

- (NSComparisonResult) compareFirstCharacter:(NSString*)string
{
    return [[self pinyinFirstLetter] compare:[string pinyinFirstLetter]];
}

//
- (NSString*) pinyinFirstLetter
{
    return [WizGlobals pinyinFirstLetter:self];
}
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

- (NSDate *) dateFromSqlTimeString
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    if (self.length < 19) {
        [formatter release];
        return nil;
    }
    NSDate* date = [formatter dateFromString:self];
	[formatter release];
	return date ;
}
//
-(NSString*) trim
{
	NSString* ret = [self stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];	
	return ret;
}
-(NSString*) trimChar: (unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString: str];
	//
	return [self stringByTrimmingCharactersInSet: cs];	
}

-(int) indexOfChar:(unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	//
	return [self indexOf: str];
}
-(int) indexOf:(NSString*)find
{
	NSRange range = [self rangeOfString:find];
	if (range.location == NSNotFound)
		return NSNotFound;
	//
	return range.location;
}
-(int) lastIndexOfChar: (unichar)ch
{
	NSString* str = [NSString stringWithCharacters:&ch length: 1];
	//
	return [self lastIndexOf: str];
}
-(int) lastIndexOf:(NSString*)find
{
	NSRange range = [self rangeOfString:find options:NSBackwardsSearch];
	if (range.location == NSNotFound)
		return NSNotFound;
	//
	return range.location;
}

-(NSString*) toValidPathComponent
{
	NSMutableString* name = [[[NSMutableString alloc] initWithString:self] autorelease];
	//
	[name replaceOccurrencesOfString:@"\\" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"/" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"'" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\"" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"*" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"?" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@">" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"|" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"!" withString:@"-" options:0 range:NSMakeRange(0, [name length])];
	//
	if ([name length] > 50)
	{
		return [name substringToIndex:50];
	}
	//
	return name;
}

-(NSString*) firstLine
{
	NSString* text = [self trim];
	int index = [text indexOfChar:'\n'];
	if (NSNotFound == index)
		return text;
	//
	return [[text substringToIndex:index] trim];
}

-(NSString*) toHtml
{
	NSMutableString* name = [[NSMutableString alloc] initWithString:self];
	//
	[name replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<" withString:@"&gt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@">" withString:@"&lt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\n" withString:@"<br />" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;" options:0 range:NSMakeRange(0, [name length])];
	return [name autorelease];
	
}


@end
