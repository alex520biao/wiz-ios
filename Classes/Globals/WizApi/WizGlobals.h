//
//  WizGlobals.h
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizTools/NSArray+WizTools.h"
#import "WizGlobalError.h"
#import "NSString+WizString.h"
#import "NSDate+WizTools.h"
#import "UIImage+WizTools.h"
#import "UIWebView+WizTools.h"
#import "NSIndexPath+WizTools.h"
#define _DEBUG
#ifdef _DEBUG
#else
#define NSLog(s,...) ;
#endif


#define MaxDownloadProcessCount 10
// wiz-dzpqzb test
#define TestFlightToken             @"5bfb46cb74291758452c20108e140b4e_NjY0MzAyMDEyLTAyLTI5IDA0OjIwOjI3LjkzNDUxOQ"
#define WIZTESTFLIGHTDEBUG

//
#define WizDocumentKeyString        @"document"
#define WizAttachmentKeyString      @"attachment"

//
#define WizUpdateError              @"UpdateError"
//


#define WizLog(s,...) logTofile(__FILE__,(char *)__FUNCTION__ ,__LINE__,s,##__VA_ARGS__)
void logTofile(char*sourceFile, char*functionName ,int lineNumber,NSString* format,...);
@interface WizGlobals : NSObject {

}
+(float) heightForWizTableFooter:(int)exisitCellCount;
+ (NSString*) folderStringToLocal:(NSString*) str;
+(int) currentTimeZone;
+(NSString*) iso8601TimeToStringSqlTimeString:(NSString*) str;

+(NSNumber*) wizNoteAppleID;
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView;


+(void) reportErrorWithString:(NSString*)error;
+(void) reportError:(NSError*)error;
+ (BOOL) checkObjectIsDocument:(NSString*)type;
+ (BOOL) checkObjectIsAttachment:(NSString*)type;
+(NSString*) genGUID;
+(BOOL) WizDeviceIsPad;

+(NSString*)fileMD5:(NSString*)path;
+ (NSURL*) wizServerUrl;
+ (void) reportMemory;
+ (BOOL) checkAttachmentTypeIsAudio:(NSString*) attachmentType;
+ (BOOL) checkAttachmentTypeIsImage:(NSString *)attachmentType;
+(float) WizDeviceVersion;
+ (NSString*) documentKeyString;
+ (NSString*) attachmentKeyString;
//2012-2-22
+ (BOOL) checkAttachmentTypeIsPPT:(NSString*)type;
+ (BOOL) checkAttachmentTypeIsWord:(NSString*)type;
+ (BOOL) checkAttachmentTypeIsExcel:(NSString*)type;
//2012-2-25
+ (BOOL) checkFileIsEncry:(NSString*)filePath;
+(void) reportWarningWithString:(NSString*)error;
+ (void) reportWarning:(NSError*)error;
//2012-3-9
//2012-3-16
//+ (NSString*) tagsDisplayStrFromGUIDS:(NSArray*)tags;
//2012-3-19
+ (BOOL) checkAttachmentTypeIsTxt:(NSString*)attachmentType;
+ (NSString*) wizNoteVersion;
+ (NSString*) localLanguageKey;
+ (void) toLog:(NSString*)log;
//
+ (NSString*) md5:(NSData *)input;
+ (NSString*) encryptPassword:(NSString*)password;
+ (BOOL) checkPasswordIsEncrypt:(NSString*)password;
//
+ (UIView*) noNotesRemind;
+ (UIView*) noNotesRemindFor:(NSString*)string;
//
+ (NSInteger)fileLength:(NSString*)path;
+ (NSString*) pinyinFirstLetter:(NSString *)string;
+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime;
+ (BOOL) checkAttachmentTypeIsHtml:(NSString *)attachmentType;
@end


extern BOOL WizDeviceIsPad(void);


