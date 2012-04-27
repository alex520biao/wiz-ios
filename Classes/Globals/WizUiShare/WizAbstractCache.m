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
#import "WizDecorate.h"
#import "WizGlobalData.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizGenDocumentAbstract.h"
@interface WizAbstractCache()
{
    NSMutableDictionary* data;
    NSOperationQueue* genQueue;
}
@property (atomic, retain) NSOperationQueue* genQueue;
@property (atomic, retain) NSMutableDictionary* data;
@end
@implementation WizAbstractCache
@synthesize genQueue;
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
    NSLog(@"abstract delete documentGuid %@",documentGUID);
    if (documentGUID == nil) {
        return;
    }
    [data removeObjectForKey:documentGUID];
    WizGenDocumentAbstract* gen = [[WizGenDocumentAbstract alloc] initWithDegeate:documentGUID delegate:self];
    [self.genQueue addOperation:gen];
    [gen release];
}
- (id) init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableDictionary dictionary];
        self.genQueue = [[[NSOperationQueue alloc] init] autorelease];
        [WizNotificationCenter addObserverForUpdateDocument:self selector:@selector(updateAbstract:)];
    }
    return self;
}

- (void) startCacheAbstrat
{
    NSArray* rectents = [WizDocument recentDocuments];
    
}

- (WizAbstractData*) genDocumentPlaceHolder:(WizDocument*)doc
{
    if (nil == doc) {
        return nil;
    }
    NSString* titleStr = doc.title;
    NSString* detailStr=@"";
    NSString* timeStr = @"";
    UIImage* abstractImage = nil;
    NSUInteger kOrderIndex = [[WizDbManager shareDbManager] userTablelistViewOption];
    if (kOrderIndex == kOrderCreatedDate || kOrderIndex == kOrderReverseCreatedDate) {
        timeStr = [doc.dateCreated  stringLocal];
    }
    else {
        timeStr = [doc.dateModified stringLocal];
    }
    timeStr = [timeStr stringByAppendingFormat:@"\n"];
    NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,doc.location == nil? @"":[WizGlobals folderStringToLocal:doc.location]];
    NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
    NSArray* tags = [doc tagDatas];
    for (WizTag* each in tags) {
        NSString* tagName = getTagDisplayName(each.title);
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
    titleStr = [WizDecorate nameToDisplay:titleStr width:400];
    titleStr = [titleStr stringByAppendingFormat:@"\n"];
    NSMutableAttributedString* nameAtrStr = [[NSMutableAttributedString alloc] initWithString:titleStr attributes:[WizDecorate getNameAttributes]];
    NSAttributedString* timeAtrStr = [[NSAttributedString alloc] initWithString:timeStr attributes:[WizDecorate getTimeAttributes]];
    NSAttributedString* detailAtrStr = [[NSAttributedString alloc] initWithString:detailStr attributes:[WizDecorate getDetailAttributes]];
    [nameAtrStr appendAttributedString:timeAtrStr];
    [nameAtrStr appendAttributedString:detailAtrStr];
    WizAbstractData* absData = [[WizAbstractData alloc] init];
    absData.text = nameAtrStr;
    absData.image = abstractImage;
    [timeAtrStr release];
    [detailAtrStr release];
    [nameAtrStr release];
    return [absData autorelease];
}
- (void) postUpdateCacheMassage:(NSString*)documentGuid
{
    [WizNotificationCenter postMessageUpdateCache:documentGuid];
}
- (void) didGenDocumentAbstract:(NSString*)documentGuid  abstractData:(WizAbstractData*)abs
{
    [self.data setObject:abs forKey:documentGuid];
    [self performSelectorOnMainThread:@selector(postUpdateCacheMassage:) withObject:documentGuid waitUntilDone:NO];
}

- (WizAbstractData*) documentAbstractForIphone:(WizDocument*)document
{
    
    WizAbstractData* abs = [self.data valueForKey:document.guid];
    if (nil == abs) {
        WizGenDocumentAbstract* genAbs = [[WizGenDocumentAbstract alloc] initWithDegeate:document.guid delegate:self];
        [self.genQueue addOperation:genAbs];
    }
    else {
        return abs;
    }
    return [self genDocumentPlaceHolder:document];
}
- (void) didReceivedMenoryWarning
{
    [self.data removeAllObjects];
}

//- (NSDictionary*) paragrahAttributeDic
//{
//    static NSDictionary* paragrahAttributeDic=nil;
//    if (paragrahAttributeDic == nil) {
//        paragrahAttributeDic = [NSMutableArray array];
//        long characheterSpacing = 0.5f;
//        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &characheterSpacing);
//        CGFloat lineSpace = 18;
//        CTParagraphStyleSetting lineSpaceStyle;
//        lineSpaceStyle.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
//        lineSpaceStyle.valueSize = sizeof(lineSpace);
//        lineSpaceStyle.value = &lineSpace;
//        CTParagraphStyleSetting settings[] = {lineSpaceStyle};
//        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings));
//        UIFont* stringFont = [UIFont systemFontOfSize:13];
//        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
//        paragrahAttributeDic = [[NSDictionary alloc] initWithObjectsAndKeys:(id)num,(NSString *)kCTKernAttributeName,(id)style,(id)kCTParagraphStyleAttributeName, (id)font,(NSString*)kCTFontAttributeName,nil];
//        CFRelease(num);
//    }
//    return paragrahAttributeDic;
//}
//- (WizAbstractData*) generateAbstractForFolder:(NSString*)folderKey     userID:(NSString*)userId
//{
////    WizIndex* index = [[WizGlobalData sharedData] indexData:userId];
////    NSArray* documents = [index documentsByLocation:folderKey];
////    NSMutableAttributedString* attibuteString = [[NSMutableAttributedString alloc] init];
////    int max = ([documents count] > 8? 8:[documents count]);
////    for (int i = 0; i <max; i++) {
////        WizDocument* doc = [documents objectAtIndex:i];
////        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@\n",i+1, doc.title]];
////        [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, 1)];
////        [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor grayColor].CGColor range:NSMakeRange(1, str.length-1)];
////        [attibuteString appendAttributedString:str];
////        [str release];
////    }
////    [attibuteString addAttributes:[self paragrahAttributeDic] range:NSMakeRange(0, attibuteString.length)];
////    WizAbstractData* abs =[[WizAbstractData alloc] init];
////    abs.text = attibuteString;
////    [data setObject:abs forKey:folderKey];
////    [abs release];
////    [attibuteString release];
////    return abs;
//}
//- (WizAbstractData*) folderAbstractForIpad:(NSString*)folderKey     userID:(NSString*)userId
//{
//    WizAbstractData* abs = [self readAbstractData:folderKey];
//    if (nil == abs) {
//        return [self generateAbstractForFolder:folderKey userID:userId];
//    }
//    return abs;
//}
@end
