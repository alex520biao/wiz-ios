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
    return [abstractCache objectForKey:documentGuid];
}

- (void) addDocumentAbstract:(NSString*)documentGuid  abstract:(WizAbstract*)abstract
{
    [abstractCache setObject:documentGuid forKey:abstractCache];
}

- (void) clearCacheForDocument:(NSString*)documentGuid
{
    [abstractCache removeObjectForKey:documentGuid];
}
@end
