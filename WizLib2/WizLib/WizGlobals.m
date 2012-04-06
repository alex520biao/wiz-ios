//
//  WizGlobals.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "WizGlobals.h"
#import "pinyin.h"
#define WizErrorDomain  @"WizErrorDomain"

//
#define MD5PART 10*1024
BOOL DeviceIsPad(void)
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
		UIDevice* device = [UIDevice currentDevice];
		UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
		return(deviceId == UIUserInterfaceIdiomPad);	
	}
	
	return(NO);
}

BOOL WizDeviceIsPad(void)
{
	BOOL b = DeviceIsPad(); 
	return b;
}
@implementation WizGlobals
+(void) reportErrorWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
	[alert release];
}
+(void) reportError:(NSError*)error
{
	[WizGlobals reportErrorWithString:[error localizedDescription]];
}
+(void) reportWarningWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning message:error delegate:nil cancelButtonTitle:WizStrOK otherButtonTitles:nil];
	[alert show];
	[alert release];
}
+ (void) reportWarning:(NSError*)error
{
    [WizGlobals reportWarningWithString:[error localizedDescription]];
}
+(NSString*) iso8601TimeToStringSqlTimeString:(NSString*) str
{
	NSMutableString* val = [[NSMutableString alloc] initWithString:str];
	//XXXXXXXXTXX:XX:XX
	[val replaceOccurrencesOfString:@"T" withString:@" " options:0 range:NSMakeRange(0, [val length])];
	[val insertString:@"-" atIndex:6];
	[val insertString:@"-" atIndex:4];
	//
	NSString* ret = [NSString stringWithString:val];
	//
	[val release];
	//
	return ret;
}
+(NSDate *) sqlTimeStringToDate:(NSString*) str
{
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* date = [formatter dateFromString:str];
	[formatter release];
	return date ;
}
+(NSString*) dateToSqlString:(NSDate*) date
{
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* com = [cal components:unitFlags fromDate:date];
	int year = [com year];
	int month = [com month];
	int day = [com day];
	int hour = [com hour];
	int minute = [com minute];
	int second = [com second];
	//
	[cal release];
	//
	NSString* str = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second];
	return str;
}
+ (NSError*) tokenUnActiveError
{
    NSError* error = [NSError errorWithDomain:WizErrorDomain code:ErrorCodeWizTokenUnActive userInfo:nil];
    return error;
}
+(NSString*) md5:(NSData *)input {
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(input.bytes, input.length, md5Buffer);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH *2];
    for(int i =0; i <CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    return  output;
}
+(NSString*)fileMD5:(NSString*)path  
{  
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];  
    if( handle== nil ) return @"ERROR GETTING FILE MD5"; // file didnt exist  
    
    CC_MD5_CTX md5;  
    
    CC_MD5_Init(&md5);  
    
    BOOL done = NO;  
    while(!done)  
    {  
        NSData* fileData = [handle readDataOfLength: MD5PART ];  
        CC_MD5_Update(&md5, [fileData bytes], [fileData length]);  
        if( [fileData length] == 0 ) done = YES;  
    }  
    unsigned char digest[CC_MD5_DIGEST_LENGTH];  
    CC_MD5_Final(digest, &md5);  
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",  
                   digest[0], digest[1],   
                   digest[2], digest[3],  
                   digest[4], digest[5],  
                   digest[6], digest[7],  
                   digest[8], digest[9],  
                   digest[10], digest[11],  
                   digest[12], digest[13],  
                   digest[14], digest[15]];  
    return s;  
} 

@end

