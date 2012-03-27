//
//  WizTableAbstractViewDecorate.m
//  Wiz
//
//  Created by wiz on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import "WizGlobalData.h"
#import "WizTableAbstractViewDecorate.h"
#import "WizIndex.h"
#import "WizGlobals.h"
//@interface WizTableAbstractDecorateInfo
//{
//    CGRect* frame;
//}
//@end
@interface WizTableAbstractViewDecorate ()
{
    CALayer* backLayer;
}
@property (nonatomic, retain) CALayer* backLayer;
+ (NSMutableDictionary*) getDetailAttributes;
+ (NSMutableDictionary*) getNameAttributes;
+ (NSMutableDictionary*) getTimeAttributes;
@end
@implementation WizTableAbstractViewDecorate
@synthesize backLayer;
@synthesize detailStr;
@synthesize nameStr;
@synthesize abstractImage;
@synthesize timerStr;
@synthesize isLoadingAbstract;
@synthesize hasAbstract;
static NSMutableDictionary* detailAttributes;
static NSMutableDictionary* nameAttributes;
static NSMutableDictionary* timeAttributes;
+ (NSMutableDictionary*) getDetailAttributes
{
    if (detailAttributes == nil) {
        detailAttributes = [[NSMutableDictionary alloc] init];
        UIFont* textFont = [UIFont systemFontOfSize:13];
        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
        [detailAttributes setObject:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [detailAttributes setObject:(id)textCtfont forKey:(NSString*)kCTFontAttributeName];
    }
    return detailAttributes;
}
+ (NSMutableDictionary*) getNameAttributes
{
    if (nameAttributes == nil) {
        nameAttributes = [[NSMutableDictionary alloc] init];
        UIFont* stringFont = [UIFont boldSystemFontOfSize:15];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        [nameAttributes setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
        
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting settings[]={lineBreakMode};
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        [nameAttributes setObject:(id)paragraphStyle forKey:(NSString*)kCTParagraphStyleAttributeName];
    }
    return nameAttributes;
}

+ (NSMutableDictionary*) getTimeAttributes
{
    if (timeAttributes == nil) {
        timeAttributes = [[NSMutableDictionary alloc] init];
        [timeAttributes setObject:(id)[[UIColor blueColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    return timeAttributes;
}
- (void) dealloc
{
    timerStr = nil;
    nameStr = nil;
    abstractImage = nil;
    detailStr = nil;
    [super dealloc];
}
- (void) initBacklayer
{
    self.backLayer = [CALayer layer];
    backLayer.shadowColor = [[UIColor lightGrayColor] CGColor];
    backLayer.shadowRadius = 0.5f;
    backLayer.shadowOffset = CGSizeMake(1, 1);
    backLayer.shadowOpacity = 0.5f;
    backLayer.borderColor = [[UIColor whiteColor] CGColor];
    backLayer.borderWidth = 0.5f;
    backLayer.backgroundColor = [[UIColor clearColor]CGColor];
}
- (id) initWithFrame:(CGRect)frame userId:(NSString *)userId
{
    self = [super initWithFrame:frame userId:userId];
    if (self) {
        [self initBacklayer];
    }
    return self;
}
- (void) setDocumentGuid:(NSString *)documentGuid_
{
    [super setDocumentGuid:documentGuid_];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:documentGuid_];
    nameStr = doc.title;
    timerStr = doc.dateModified;
    if (doc.serverChanged) {
        WizAbstract* abstract = [index abstractOfDocument:documentGuid_];
        detailStr = abstract.text;
        abstractImage = abstract.image;
    }
    else {
        NSString* tagStr = [WizGlobals tagsDisplayStrFromGUIDS:[index tagsByDocumentGuid:documentGuid_]];
        NSString* folderStr = [WizGlobals folderStringToLocal:doc.location];
        if (tagStr !=nil && ![tagStr isEqualToString:@""]) {
            folderStr = [folderStr stringByAppendingString:tagStr];
        }
        detailStr = folderStr;
        abstractImage = nil;
    }
}
- (void) drawRect:(CGRect)rect
{
//    CGFloat imageWidthRate = 0.25;
//    CGFloat imageHeightRate = 0.25;
//    CGFloat imageWidth = rect.size.width * imageWidthRate;
//    CGFloat imageHeight = rect.size.height * imageHeightRate;
//    CGRect imageRect = CGRectMake(rect.size.width-imageWidth, rect.size.height-imageHeight, imageWidth, imageHeight);
//    CGRect textRect = CGRectMake(0.0, 0.0, rect.size.width, rect.size.height);
}
@end
