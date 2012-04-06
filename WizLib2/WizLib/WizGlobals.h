//
//  WizGlobals.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define WizNullString   @""
#define ErrorCodeWizTokenUnActive   301
//
#define WizDocumentKeyString        @"document"
#define WizAttachmentKeyString      @"attachment"
//
#define WizErrorDomin               @"error.wiz.cn"
BOOL WizDeviceIsPad(void);
@interface WizGlobals : NSObject
+ (void) reportErrorWithString:(NSString*)error;
+ (void) reportError:(NSError*)error;
+ (void) reportWarningWithString:(NSString*)error;
+ (void) reportWarning:(NSError*)error;
+ (NSString*) iso8601TimeToStringSqlTimeString:(NSString*) str;
+ (NSDate *) sqlTimeStringToDate:(NSString*) str;
+ (NSString*) dateToSqlString:(NSDate*) date;
+ (NSError*) tokenUnActiveError;
+ (NSString*) md5:(NSData *)input;
+ (NSString*)fileMD5:(NSString*)path;
@end
