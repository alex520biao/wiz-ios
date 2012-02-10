//
//  WizGlobals.m
//  Wiz
//
//  Created by Wei Shijun on 3/4/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import <CommonCrypto/CommonDigest.h>
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#define MD5PART 10*1024
@implementation WizGlobals

+ (float) WizDeviceVersion
{
    return [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(BOOL) DeviceIsPad
{
	if ([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)])
	{
		UIDevice* device = [UIDevice currentDevice];
		UIUserInterfaceIdiom deviceId = device.userInterfaceIdiom;
		return(deviceId == UIUserInterfaceIdiomPad);	
	}
	
	return(NO);
}

+(BOOL) WizDeviceIsPad
{
	BOOL b =[self DeviceIsPad];
	return b;
}

+ (BOOL) checkObjectIsDocument:(NSString*)type
{
    return [type isEqualToString:@"document"];
}
+ (BOOL) checkObjectIsAttachment:(NSString*)type
{
    return [type isEqualToString:@"attachment"];
}
+ (NSString*) documentKeyString
{
    return @"document";
}
+ (NSString*) attachmentKeyString
{
    return @"attachment";
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


+ (NSString*)documentMD5:(NSString *)documentGUID :(NSString*)accountUserId
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    NSString* zip = [index createZipByGuid:documentGUID];
    NSString* md5 = [WizGlobals fileMD5:zip];
    [WizGlobals deleteFile:zip];
    return md5;
}

+(float) heightForWizTableFooter:(int)exisitCellCount
{
    float currentTableHeight = exisitCellCount*44.0;
    if (currentTableHeight < 44.0*6) {
        return 44.0*9 - currentTableHeight;
    }
    else
    {
        return 100.0;
    }
}

+ (NSString*) folderStringToLocal:(NSString*) str
{
    NSArray* strArr = [str componentsSeparatedByString:@"/"];
    NSMutableString* ret = [NSMutableString string];
    for (NSString* each in strArr) {
        if ([each isEqualToString:@""]) {
            continue;
        }
        NSString* localStr = NSLocalizedString(each, nil);
        [ret appendFormat:@"/%@",localStr];
    }
    return ret;
}

+(int)currentTimeZone
{
	static int hours = 100;
	if (hours == 100)
	{
		NSTimeZone* tz = [NSTimeZone systemTimeZone];
		int seconds = [tz secondsFromGMTForDate:[NSDate date]];
		//
		hours = seconds / 60 / 60;
	}
	//
	return hours;
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

+ (BOOL) checkAttachmentTypeIsAudio:(NSString *)attachmentType
{
    if ([attachmentType isEqualToString:@"aif"]) {
        return YES;
    }
    if ([attachmentType isEqualToString:@"amr"]) {
        return YES;
    }
    else if ( [attachmentType isEqualToString:@"mp3"])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

+ (BOOL) checkAttachmentTypeIsImage:(NSString *)attachmentType
{
    if ([attachmentType isEqualToString:@"png"] || [attachmentType isEqualToString:@"PNG"]) {
        return YES;
    }
    else if ([attachmentType isEqualToString:@"jpg"] || [attachmentType isEqualToString:@"JPG"])
    {
        return YES;
    }
    else if ([attachmentType isEqualToString:@"jpeg"] || [attachmentType isEqualToString:@"JPEG"])
    {
        return YES;
    }
    else if ([attachmentType isEqualToString:@"bmp"] || [attachmentType isEqualToString:@"BMP"])
    {
        return YES;
    }
    else if ([attachmentType isEqualToString:@"gif"] || [attachmentType isEqualToString:@"GIF"])
    {
        return YES;
    }
    else 
    {
        return NO;
    }
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

+(NSString*) dateToLocalString: (NSDate*)date
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	
    NSLocale *locale = [NSLocale currentLocale];
    [dateFormatter setLocale:locale];
    
    return [dateFormatter stringFromDate:date]; 
}
+(NSString*) sqlTimeStringToToLocalString: (NSString*)str
{
	NSDate* dt = [WizGlobals sqlTimeStringToDate:str];
	return [WizGlobals dateToLocalString:dt];
}

+(NSString*) documentsPath
{
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString* documentDirectory = [paths objectAtIndex:0];
	//
	return documentDirectory;
}

+(void) showAlertView:(NSString*)title message:(NSString*)message delegate: (id)callback retView:(UIAlertView**) pAlertView
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:callback cancelButtonTitle:nil otherButtonTitles:nil];
	UIActivityIndicatorView* progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//
	[alert addSubview:progress];
    [progress release];
	//
	[alert show];
	//
	CGRect rc = alert.frame;
	//
	CGPoint pt = CGPointMake(rc.size.width / 2 - 14 , rc.size.height / 2 + 10);
	//
	[progress setCenter:pt];
	[progress startAnimating];
	//
	*pAlertView = alert;
}

+(BOOL) pathFileExists:(NSString*)path
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	BOOL b = [fileManager fileExistsAtPath:path];
	//
	[fileManager release];
	//
	return b;
}

+(BOOL) deleteFile:(NSString*)fileName
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSError* err = nil;
	BOOL b = [fileManager removeItemAtPath:fileName error:&err];
	//
	[fileManager release];
	//
	if (!b && err)
	{
		[WizGlobals reportError:err];
	}
	//
	return b;
}

+(void) reportErrorWithString:(NSString*)error
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}
+(void) reportError:(NSError*)error
{
	[WizGlobals reportErrorWithString:[error localizedDescription]];
}
+(BOOL) ensurePathExists:(NSString*)path
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	BOOL b = YES;
    if (![fileManager fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
			[WizGlobals reportError:err];
		}
	}
	//
	[fileManager release];
	//
	return b;
}

+(NSString*) genGUID
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	//
	NSString* str = [NSString stringWithString:(NSString*)string];
	//
	CFRelease(string);
	//
	return [str lowercaseString];
}



+ (UIImage *)resizeImage:(UIImage *)image 
			   scaledToSize:(CGSize)newSize 
{
    UIGraphicsBeginImageContext(newSize);    
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return newImage;
}

+(UIImage*) scaleAndRotateImage:(UIImage*)photoimage bounds_width:(CGFloat)bounds_width bounds_height:(CGFloat)bounds_height
{
    //int kMaxResolution = 300;
	
    CGImageRef imgRef =photoimage.CGImage;
	
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
	
	
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    /*if (width > kMaxResolution || height > kMaxResolution)
	 {
	 CGFloat ratio = width/height;
	 if (ratio > 1)
	 {
	 bounds.size.width = kMaxResolution;
	 bounds.size.height = bounds.size.width / ratio;
	 }
	 else
	 {
	 bounds.size.height = kMaxResolution;
	 bounds.size.width = bounds.size.height * ratio;
	 }
	 }*/
    bounds.size.width = bounds_width;
    bounds.size.height = bounds_height;
	
    CGFloat scaleRatio = bounds.size.width / width;
    CGFloat scaleRatioheight = bounds.size.height / height;
	/*
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
	
    CGFloat boundHeight;
    UIImageOrientation orient =photoimage.imageOrientation;
    switch(orient)
    {
			
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
			
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
			
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
			
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
			
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
			
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
			
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid?image?orientation"];
            break;
    }
	 */
	
    UIGraphicsBeginImageContext(bounds.size);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    //if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft)
    //{
    //    CGContextScaleCTM(context, -scaleRatio, scaleRatioheight);
    //    CGContextTranslateCTM(context, -height, 0);
    //}
    //else
    //{
        CGContextScaleCTM(context, scaleRatio, -scaleRatioheight);
        CGContextTranslateCTM(context, 0, -height);
    //}
	
    CGContextConcatCTM(context, transform);
	
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


@end



@implementation NSString (WizStringHelp)

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
		return -1;
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
		return -1;
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
	if (-1 == index)
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
	//
	return [name autorelease];
	
}





@end;



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


#define MAX_IMAGEPIX 200.0          // max pix 200.0px  
#define MAX_IMAGEDATA_LEN 50000.0   // max data length 5K  

@implementation UIImage (Compress)  

- (UIImage *)compressedImage:(float)qulity {  
    CGSize imageSize = self.size;  
    CGFloat width = imageSize.width;  
    CGFloat height = imageSize.height;  
    
    if (width <= MAX_IMAGEPIX && height <= MAX_IMAGEPIX) {  
        // no need to compress.  
        return self;  
    }  
    
    if (width == 0 || height == 0) {  
        // void zero exception  
        return self;  
    }  
    
    UIImage *newImage = nil;  
    CGFloat widthFactor = qulity / width;  
    CGFloat heightFactor = qulity / height;  
    CGFloat scaleFactor = 0.0;  
    
    if (widthFactor > heightFactor)  
        scaleFactor = heightFactor; // scale to fit height  
    else  
        scaleFactor = widthFactor; // scale to fit width  
    
    CGFloat scaledWidth  = width * scaleFactor;  
    CGFloat scaledHeight = height * scaleFactor;  
    CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);  
    
    UIGraphicsBeginImageContext(targetSize); // this will crop  
    
    CGRect thumbnailRect = CGRectZero;  
    thumbnailRect.size.width  = scaledWidth;  
    thumbnailRect.size.height = scaledHeight;  
    
    [self drawInRect:thumbnailRect];  
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();  
    
    //pop the context to get back to the default  
    UIGraphicsEndImageContext();  
    
    return newImage;  
    
}  

- (NSData *)compressedData:(CGFloat)compressionQuality {  
    assert(compressionQuality <= 1.0 && compressionQuality >= 0);  
    
    return UIImageJPEGRepresentation(self, compressionQuality);  
}  

- (CGFloat)compressionQuality {  
    NSData *data = UIImageJPEGRepresentation(self, 1.0);  
    NSUInteger dataLength = [data length];  
    
    if(dataLength > MAX_IMAGEDATA_LEN) {  
        return 1.0 - MAX_IMAGEDATA_LEN / dataLength;  
    } else {  
        return 1.0;  
    }  
}  

- (NSData *)compressedData {  
    CGFloat quality = [self compressionQuality];  
    
    return [self compressedData:quality];  
}  

@end  

@implementation UIWebView (SearchWebView)

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SearchWebView" ofType:@"js"];
	NSString *jsCode = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	
	
    [self stringByEvaluatingJavaScriptFromString:jsCode];
	
    NSString *startSearch = [NSString stringWithFormat:@"MyApp_HighlightAllOccurencesOfString('%@')",str];
    [self stringByEvaluatingJavaScriptFromString:startSearch];
	
    NSString *result = [self stringByEvaluatingJavaScriptFromString:@"MyApp_SearchResultCount"];
    return [result integerValue];
}

- (void)removeAllHighlights
{
    [self stringByEvaluatingJavaScriptFromString:@"MyApp_RemoveAllHighlights()"];
}

@end


@implementation UIImageView (AddAction)

- (void) addAction:(SEL)action target:(id)target
{
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:target action:action] autorelease];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired =1;
    [self addGestureRecognizer:tap];
    self.userInteractionEnabled = YES;
}

@end
