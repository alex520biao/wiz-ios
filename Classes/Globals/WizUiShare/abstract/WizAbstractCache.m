//
//  WizAbstractCache.m
//  Wiz
//
//  Created by wiz on 12-8-3.
//
//

#import "WizAbstractCache.h"
#import "WizDbManager.h"
@interface WizAbstractCache ()
{
    NSCache*  abstractCache;
}
@end

@implementation WizAbstractCache

+ (id) shareCache
{
    static WizAbstractCache* shareCache = nil;
    @synchronized (self)
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

//over Single

- (void) dealloc
{
    [abstractCache release];
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        abstractCache = [[NSCache alloc] init];
    }
    return self;
}

- (WizAbstract*)  documentAbstract:(NSString*)documentGuid
{
    WizAbstract* abstract = [abstractCache objectForKey:documentGuid];
    return abstract;
}

- (void) addDocumentAbstract:(WizDocument*)document   abstract:(WizAbstract*)abstract
{
    if (nil != abstract) {
       [abstractCache setObject:abstract forKey:document.guid];
        return;
    }
    

    WizAbstract* tempAbstract = [[WizAbstract alloc] init];
    if ([WizGlobals WizDeviceIsPad]) {
        static UIImage* ipadPlaceHolderImage = nil;
        if (nil == ipadPlaceHolderImage) {
            ipadPlaceHolderImage = [UIImage imageNamed:@"ipadPlaceHolder"];
        }
        tempAbstract.image = ipadPlaceHolderImage;
    }
    else
    {
        static UIImage* placeHoderImage;
        @synchronized (placeHoderImage)
        {
            if (nil == placeHoderImage) {
                placeHoderImage = [[UIImage imageNamed:@"documentWithoutData"] retain];
            }
        }
        tempAbstract.image = placeHoderImage;
    }
    tempAbstract.text = [WizGlobals folderStringToLocal:document.location];
    [abstractCache setObject:tempAbstract forKey:document.guid];
    [tempAbstract release];
}

- (void) clearCacheForDocument:(NSString*)documentGuid
{
    [abstractCache removeObjectForKey:documentGuid];
}
@end
