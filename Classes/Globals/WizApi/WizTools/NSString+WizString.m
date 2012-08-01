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

- (NSString*) stringReplaceUseRegular:(NSString *)regex withString:(NSString*)replaceStr
{
    @try {
        if (self) {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
            return [reg stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:replaceStr];
        }

    }
    @catch (NSException *exception) {
        return self;
    }
    @finally {
            
    }
    
}

- (NSString*) stringReplaceUseRegular:(NSString*)regex
{
    @try {
        if (self) {
            NSRegularExpression* reg = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:nil];
            return [reg stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@""];
        }
    }
    @catch (NSException *exception) {
        return self;
    }
    @finally {
        
    }
    
}

- (NSDate *) dateFromSqlTimeString
{
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    @synchronized(formatter)
    {
        if (self.length < 19) {
            return nil;
        }
         NSDate* date = [formatter dateFromString:self];
        return date ;
    }
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

- (NSInteger) indexOf:(NSString *)find compareOptions:(NSStringCompareOptions)mask
{
    NSRange range = [self rangeOfString:find options:mask];
    if (range.location == NSNotFound) {
        return NSNotFound;
    }
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
	return [[text substringToIndex:index] trim];
}

- (NSString*) fromHtml
{
    if (!self) {
        return nil;
    }
    NSMutableString* name = [[NSMutableString alloc] initWithString:self];
	//
	[name replaceOccurrencesOfString:@"" withString:@"\r" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&gt;" withString:@"<" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&lt;" withString:@">" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<br>" withString:@"\n" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&nbsp;&nbsp;&nbsp;&nbsp;" withString:@"\t" options:0 range:NSMakeRange(0, [name length])];
	return [name autorelease];
}

- (NSString*) nToHtmlBr
{
    return [self stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
}

-(NSString*) toHtml
{
    if (!self) {
        return nil;
    }
	NSMutableString* name = [[NSMutableString alloc] initWithString:self];
	//
	[name replaceOccurrencesOfString:@"\r" withString:@"" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"<" withString:@"&gt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@">" withString:@"&lt;" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\n" withString:@"<br>" options:0 range:NSMakeRange(0, [name length])];
	[name replaceOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;&nbsp;&nbsp;" options:0 range:NSMakeRange(0, [name length])];
	return [name autorelease];
	
}

- (NSString *)URLEncodedString{    
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           (CFStringRef)self,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}
- (NSString*)URLDecodedString{
    NSString *result = (NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                           (CFStringRef)self,
                                                                                           CFSTR(""),
                                                                                           kCFStringEncodingUTF8);
    [result autorelease];
    return result;
}

- (BOOL) checkHasInvaildCharacters
{
    static NSRegularExpression* regular = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError* error = nil;
        regular = [[NSRegularExpression regularExpressionWithPattern:@"[\\,/,:,<,>,*,?,\",&,\"]" options:NSRegularExpressionCaseInsensitive error:&error] retain];
        NSLog(@"regular %@",regular);
    });
    NSArray* regularArray = [regular  matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (regularArray && [regularArray count]) {
        return YES;
    }
    return NO;
}

- (BOOL) writeToFile:(NSString *)path useUtf8Bom:(BOOL)isWithBom error:(NSError **)error
{
    
    char BOM[] = {0xEF, 0xBB, 0xBF};
    NSMutableData* data = [NSMutableData data];
    [data appendBytes:BOM length:3];
    [data appendData:[self dataUsingEncoding:NSUTF8StringEncoding]];
    NSFileManager* fileNamger = [NSFileManager defaultManager];
    if ([fileNamger fileExistsAtPath:path]) {
        [fileNamger removeItemAtPath:path error:nil];
    }
    [fileNamger createFileAtPath:path contents:data attributes:nil];
    return YES;
}
@end
