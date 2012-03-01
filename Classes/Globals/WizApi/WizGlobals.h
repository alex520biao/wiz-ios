//
//  WizGlobals.h
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MaxDownloadProcessCount 5
// wiz-dzpqzb test
#define TestFlightToken @"5bfb46cb74291758452c20108e140b4e_NjY0MzAyMDEyLTAyLTI5IDA0OjIwOjI3LjkzNDUxOQ"
#define WIZTESTFLIGHTDEBUG
@interface WizGlobals : NSObject {

}
+ (NSString*)documentMD5:(NSString *)documentGUID :(NSString*)accountUserId;
+(float) heightForWizTableFooter:(int)exisitCellCount;
+ (NSString*) folderStringToLocal:(NSString*) str;
+(int) currentTimeZone;
+(NSString*) iso8601TimeToStringSqlTimeString:(NSString*) str;
+(NSDate*) sqlTimeStringToDate:(NSString*) str;
+(NSString*) dateToSqlString:(NSDate*) date;
+(NSString*) documentsPath;
+(NSNumber*) wizNoteAppleID;
+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView;

+(BOOL) ensurePathExists:(NSString*)path;
+(BOOL) pathFileExists:(NSString*)path;
+(BOOL) deleteFile:(NSString*)fileName;

+(void) reportErrorWithString:(NSString*)error;
+(void) reportError:(NSError*)error;
+ (BOOL) checkObjectIsDocument:(NSString*)type;
+ (BOOL) checkObjectIsAttachment:(NSString*)type;
+(NSString*) genGUID;
+(BOOL) WizDeviceIsPad;
+(NSString*) dateToLocalString: (NSDate*)date;
+(NSString*) sqlTimeStringToToLocalString: (NSString*)str;
+(NSString*)fileMD5:(NSString*)path;

+(UIImage*) scaleAndRotateImage:(UIImage*)photoimage bounds_width:(CGFloat)bounds_width bounds_height:(CGFloat)bounds_height;

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
//2012-2-27
+(NSString*)getAttachmentSourceFileName:(NSString*)userId;
//2012-2-28
+(void) reportWarningWithString:(NSString*)error;
+ (void) reportWarning:(NSError*)error;
@end


@interface NSString (WizStringHelp)

-(NSString*) trim;
-(NSString*) trimChar:(unichar) ch;
-(int) indexOfChar:(unichar)ch;
-(int) indexOf:(NSString*)find;
-(int) lastIndexOfChar: (unichar)ch;
-(int) lastIndexOf:(NSString*)find;
-(NSString*) firstLine;
-(NSString*) toHtml;

-(NSString*) toValidPathComponent;
  
@end;


extern BOOL WizDeviceIsPad(void);

@interface UIImage (Compress)  

- (UIImage *)compressedImage:(float)qulity;  
- (UIImage *)compressedImageWidth:(float)qulity;
- (CGFloat)compressionQuality;  
- (UIImage*) wizCompressedImageWidth:(float)width   height:(CGFloat)height;

- (NSData *)compressedData;  

- (NSData *)compressedData:(CGFloat)compressionQuality;  

@end  

@interface UIImageView (AddAction) 
- (void) addAction:(SEL)action  target:(id) target;
@end
@interface UIWebView (SearchWebView)

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

@end