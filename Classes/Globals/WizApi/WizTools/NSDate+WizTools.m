//
//  NSDate+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-4-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+WizTools.h"
#import "NSDate-Utilities.h"

@implementation NSDate (WizTools)
- (NSString*) stringYearAndMounth
{
    NSString* dateToLocalString = [self stringLocal];
    if (nil == dateToLocalString || dateToLocalString.length <7) {
        return nil;
    }
    NSRange range = NSMakeRange(0, 7);
   return [dateToLocalString substringWithRange:range];
}
- (NSString*) stringLocal
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    return [dateFormatter stringFromDate:self];
}
-(NSString*) stringSql
{
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
	NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents* com = [cal components:unitFlags fromDate:self];
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
@end
