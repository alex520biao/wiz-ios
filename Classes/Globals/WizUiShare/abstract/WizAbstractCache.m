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

- (WizAbstract*)  documentAbstract:(WizDocument*)document  decorateView:(id)decorateView
{
    
    WizAbstract* abstract = [abstractCache objectForKey:document.guid];
    if (abstract == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<WizTemporaryDataBaseDelegate> abstractDataBase = [[WizDbManager shareDbManager] shareAbstractDataBase];
            WizAbstract* abstract = [abstractDataBase abstractOfDocument:document.guid];
            if (document.serverChanged ==0 && !abstract) {
                [abstractDataBase extractSummary:document.guid kbGuid:@""];
                abstract = [abstractDataBase abstractOfDocument:document.guid];
            }
            if (abstract != nil) {
                [abstractCache setObject:abstract forKey:document.guid];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [decorateView setNeedsDisplay];
                });
            }

        });
    }
    return abstract;
}
@end
