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
    NSMutableArray* needGenAbstractDocuments;
    WizGenDocumentAbstract* genProc;
}
@property (atomic, retain) NSMutableDictionary* data;
@property (atomic, retain)  NSMutableArray* needGenAbstractDocuments;
@property (atomic, retain) WizGenDocumentAbstract* genProc;
@end
@implementation WizAbstractCache
@synthesize data;
@synthesize needGenAbstractDocuments;
@synthesize genProc;
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
//
- (void) didChangedAccountUser
{
    self.genProc.isChangedUser = YES;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.data = [NSMutableDictionary dictionary];
        WizGenDocumentAbstract* genAbs = [[WizGenDocumentAbstract alloc] initWithDelegate:self];
        [[NSOperationQueue mainQueue] addOperation:genAbs];
        [WizNotificationCenter addObserverForChangeAccount:self selector:@selector(didChangedAccountUser)];
    }
    return self;
}
- (NSString*) popNeedGenAbstrctDocument
{
    NSString* guid = [self.needGenAbstractDocuments lastObject];
    [self.needGenAbstractDocuments removeLastObject];
    return guid;
}
- (void) postUpdateCacheMassage:(NSString*)documentGuid
{
    [WizNotificationCenter postMessageUpdateCache:documentGuid];
}
- (void) didGenDocumentAbstract:(NSString*)documentGuid  abstractData:(WizAbstract*)abs
{
    if (abs == nil) {
        return;
    }
    [self.data setObject:abs forKey:documentGuid];
    [self performSelectorOnMainThread:@selector(postUpdateCacheMassage:) withObject:documentGuid waitUntilDone:NO];
}
- (void) pushNeedGenAbstractDoument:(NSString*)documentGuid
{
    [self.needGenAbstractDocuments addObject:documentGuid];
    [self.genProc start];
}
- (WizAbstract*) documentAbstractForIphone:(WizDocument*)document
{
    WizAbstract* abs = [self.data valueForKey:document.guid];
    if (nil == abs && document.serverChanged != YES) {
        [self pushNeedGenAbstractDoument:document.guid];
    }
    return abs;
}
- (void) didReceivedMenoryWarning
{
    [self.data removeAllObjects];
}
@end
