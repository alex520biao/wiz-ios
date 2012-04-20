//
//  WizAbstractCache.m
//  Wiz
//
//  Created by MagicStudio on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"
#import "WizAbstractCache.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
@implementation WizAbstractData

@synthesize text, image;

@end

@interface WizAbstractCache()
{
    NSMutableDictionary* data;
}
@end
@implementation WizAbstractCache
+ (id) shareCache
{
    static WizAbstractCache* shareCache;
    @synchronized(shareCache)
    {
        if (shareCache == nil) {
            shareCache = [[super allocWithZone:NULL] init];
        }
        return shareCache;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareCache] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}
- (oneway void) release
{
    return;
}
- (void) updateAbstract:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    if (documentGUID == nil) {
        return;
    }
    [data removeObjectForKey:documentGUID];
}
- (id) init
{
    self = [super init];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
        [WizNotificationCenter addObserverForUpdateDocument:self selector:@selector(updateAbstract:)];
    }
    return self;
}
//

- (UIFont*) nameFont
{
    static UIFont* nameFont = nil;
    if(nameFont == nil)
    {
        nameFont = [UIFont boldSystemFontOfSize:15];
    }
    return nameFont;
}

- (NSMutableDictionary*) getDetailAttributes
{
    static NSMutableDictionary* detailAttributes = nil;
    if (detailAttributes == nil) {
        detailAttributes = [[NSMutableDictionary alloc] init];
        UIFont* textFont = [UIFont systemFontOfSize:13];
        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
        [detailAttributes setObject:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [detailAttributes setObject:(id)textCtfont forKey:(NSString*)kCTFontAttributeName];
    }
    return detailAttributes;
}
- (NSMutableDictionary*) getNameAttributes
{
    static NSMutableDictionary* nameAttributes = nil;
    if (nameAttributes == nil) {
        nameAttributes = [[NSMutableDictionary alloc] init];
        UIFont* stringFont = [self nameFont];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        [nameAttributes setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting settings[]={lineBreakMode};
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        [nameAttributes setObject:(id)paragraphStyle forKey:(NSString*)kCTParagraphStyleAttributeName];
    }
    return nameAttributes;
}

- (NSMutableDictionary*) getTimeAttributes
{
    static NSMutableDictionary* timeAttributes=nil;
    if (timeAttributes == nil) {
        timeAttributes = [[NSMutableDictionary alloc] init];
        [timeAttributes setObject:(id)[[UIColor lightGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    return timeAttributes;
}

//

- (WizAbstractData*) readAbstractData:(NSString*)guid
{
    WizAbstractData* abs = nil;
    @try {
        abs = [data valueForKey:guid];
    }
    @catch (NSException *exception) {
        abs = nil;
    }
    @finally {
        
    }
    return abs;
}
- (NSString*) nameToDisplay:(NSString*)str   width:(CGFloat)width
{
    UIFont* nameFont = [self nameFont];
    CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, 20);
    CGSize requiredSize = [str sizeWithFont:nameFont constrainedToSize:boundingSize
                              lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat requireWidth = requiredSize.width;
    if (requireWidth > width) {
        if (nil == str || str.length <1) {
            return @"";
        }
        return [self nameToDisplay:[str substringToIndex:str.length-1 ] width:width];
    }
    else
    {
        return str;
    }
}
- (WizAbstractData*) generateAbstractForDocument:(NSString*)documentGUID
{
    WizIndex* index = [WizIndex activeIndex];
    WizDocument* doc = [index documentFromGUID:documentGUID];
    if (nil == doc) {
        return nil;
    }
    WizAbstract*   abstract = [index  abstractOfDocument:doc.guid];
    if (abstract == nil && ![index documentServerChanged:doc.guid]) {
        NSString* documentFilePath = [WizIndex documentFileName:[[WizAccountManager defaultManager] activeAccountUserId] documentGUID:doc.guid];
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentFilePath]) {
            [index extractSummary:documentGUID];
            abstract = [index abstractOfDocument:documentGUID];
        }
    }
    NSString* titleStr = doc.title;
    NSString* detailStr=@"";
    NSString* timeStr = @"";
    UIImage* abstractImage = nil;
    NSUInteger kOrderIndex = [index userTablelistViewOption];
    if (kOrderIndex == kOrderCreatedDate || kOrderIndex == kOrderReverseCreatedDate) {
        timeStr = doc.dateCreated;
    }
    else {
        timeStr = doc.dateModified;
    }
    timeStr = [timeStr stringByAppendingFormat:@"\n"];
    if ([index documentServerChanged:doc.guid]) {
        NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,doc.location == nil? @"":[WizGlobals folderStringToLocal:doc.location]];
        NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
        NSArray* tags = [index tagsByDocumentGuid:doc.guid];
        for (WizTag* each in tags) {
            NSString* tagName = getTagDisplayName(each.name);
            tagstr = [tagstr stringByAppendingFormat:@"%@|",tagName];
        }
        if (![tagstr isEqualToString:[NSString stringWithFormat:@"%@:",WizStrTags]]) {
            if (nil != tagstr || tagstr.length > 0) {
                tagstr = [tagstr substringToIndex:tagstr.length-1];
                folder = [folder stringByAppendingString:tagstr];
            }
        }
        detailStr = folder;
        abstractImage = [UIImage imageNamed:@"documentWithoutData"];
    }
    else {
        detailStr = abstract.text;
        abstractImage = abstract.image;
    }
    if (abstractImage != nil) {
        titleStr = [self nameToDisplay:titleStr width:230];
    }
    else {
        titleStr = [self nameToDisplay:titleStr width:300];
    }
    titleStr = [titleStr stringByAppendingFormat:@"\n"];
    NSMutableAttributedString* nameAtrStr = [[NSMutableAttributedString alloc] initWithString:titleStr attributes:[self getNameAttributes]];
    NSAttributedString* timeAtrStr = [[NSAttributedString alloc] initWithString:timeStr attributes:[self getTimeAttributes]];
    NSAttributedString* detailAtrStr = [[NSAttributedString alloc] initWithString:detailStr attributes:[self getDetailAttributes]];
    [nameAtrStr appendAttributedString:timeAtrStr];
    [nameAtrStr appendAttributedString:detailAtrStr];
    WizAbstractData* absData = [[WizAbstractData alloc] init];
    absData.text = nameAtrStr;
    absData.image = abstractImage;
    [timeAtrStr release];
    [detailAtrStr release];
    [nameAtrStr release];
    [data setObject:absData forKey:documentGUID];
    [absData release];
    return absData;
}
- (WizAbstractData*) documentAbstractForIphone:(NSString*)documentGUID
{
    WizAbstractData* abs = [self readAbstractData:documentGUID];
    if (nil == abs) {
        return [self generateAbstractForDocument:documentGUID];
    }
    return abs;
}
- (void) didReceivedMenoryWarning
{
    [data removeAllObjects];
}

- (NSDictionary*) paragrahAttributeDic
{
    static NSDictionary* paragrahAttributeDic=nil;
    if (paragrahAttributeDic == nil) {
        paragrahAttributeDic = [NSMutableArray array];
        long characheterSpacing = 0.5f;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &characheterSpacing);
        CGFloat lineSpace = 18;
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value = &lineSpace;
        CTParagraphStyleSetting settings[] = {lineSpaceStyle};
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings));
        UIFont* stringFont = [UIFont systemFontOfSize:13];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        paragrahAttributeDic = [[NSDictionary alloc] initWithObjectsAndKeys:(id)num,(NSString *)kCTKernAttributeName,(id)style,(id)kCTParagraphStyleAttributeName, (id)font,(NSString*)kCTFontAttributeName,nil];
        CFRelease(num);
    }
    return paragrahAttributeDic;
}
- (WizAbstractData*) generateAbstractForFolder:(NSString*)folderKey     userID:(NSString*)userId
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:userId];
    NSArray* documents = [index documentsByLocation:folderKey];
    NSMutableAttributedString* attibuteString = [[NSMutableAttributedString alloc] init];
    int max = ([documents count] > 8? 8:[documents count]);
    for (int i = 0; i <max; i++) {
        WizDocument* doc = [documents objectAtIndex:i];
        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@\n",i+1, doc.title]];
        [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, 1)];
        [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor grayColor].CGColor range:NSMakeRange(1, str.length-1)];
        [attibuteString appendAttributedString:str];
        [str release];
    }
    [attibuteString addAttributes:[self paragrahAttributeDic] range:NSMakeRange(0, attibuteString.length)];
    WizAbstractData* abs =[[WizAbstractData alloc] init];
    abs.text = attibuteString;
    [data setObject:abs forKey:folderKey];
    [abs release];
    [attibuteString release];
    return abs;
}
- (WizAbstractData*) folderAbstractForIpad:(NSString*)folderKey     userID:(NSString*)userId
{
    WizAbstractData* abs = [self readAbstractData:folderKey];
    if (nil == abs) {
        return [self generateAbstractForFolder:folderKey userID:userId];
    }
    return abs;
}
@end
