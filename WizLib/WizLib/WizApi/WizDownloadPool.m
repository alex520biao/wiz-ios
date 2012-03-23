//
//  WizDownloadPool.m
//  Wiz
//
//  Created by wiz on 12-2-1.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDownloadPool.h"
#import "WizDownloadObject.h"
#import "WizGlobals.h"
#import "WizApi.h"
#import "WizNotification.h"
@implementation WizDownloadPool
@synthesize processPool;
@synthesize accountUserId;
- (void) dealloc
{
    self.processPool = nil;
    self.accountUserId = nil;
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.processPool = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return self;
}

- (NSString*) processKey:(NSString*)objectGUID  type:(NSString*)objectType
{
    return [NSString stringWithFormat:@"%@-%@",objectGUID,objectType];
}
- (BOOL) documentIsDownloading:(NSString*)documentGUID
{
    WizDownloadDocument* data = [self.processPool valueForKey:[self processKey:documentGUID type:[WizGlobals documentKeyString]]];
    if (nil != data) {
        return YES;
    }
    else
    {
        return data.busy;
    }
}
- (BOOL) attachmentIsDownloading:(NSString*)attachmentGUID
{
    id data = [self.processPool valueForKey:[self processKey:attachmentGUID type:[WizGlobals attachmentKeyString]]];
    return nil != data;
}
- (void) removeDownloadData:(NSNotification*)nc
{
    for (WizDownloadObject* each in [self.processPool allValues]) {
        if (!each.busy) {
            [self removeDownloadProcess:each.objGuid type:each.objType];
        }
    }
}

- (BOOL) checkCanProduceAProcess
{
    if ([[self.processPool allValues] count] < MaxDownloadProcessCount) {
        return YES;
    }
    else {
        return NO;
    }
}
- (id) getDownloadProcess:(NSString*)objectGUID  type:(NSString*)objectType
{
    NSString* proceessKey = [self processKey:objectGUID type:objectType];
    id  download = [processPool valueForKey:proceessKey];
    if (nil == download) {
        if ([WizGlobals checkObjectIsDocument:objectType]) {
            download = [[WizDownloadDocument alloc] initWithAccount:accountUserId password:@""];
            [self.processPool setObject:download forKey:proceessKey];
            [download release];
            [WizNotificationCenter addObserverForDownloadDocument:self selector:@selector(removeDownloadData:) documentGUID:objectGUID];
            
        }
        if ([WizGlobals checkObjectIsAttachment:objectType]) {
            download = [[WizDownloadAttachment alloc] initWithAccount:accountUserId password:@""];
            [self.processPool setObject:download forKey:proceessKey];
            [WizNotificationCenter addObserverForDownloadAttachment:self selector:@selector(removeDownloadData:) attachmentGUID:objectGUID];
            [download release];
        }
    }
    return download;
}
- (void) removeDownloadProcess:(NSString*)objectGUID  type:(NSString*)objectType
{
    NSString* proceessKey = [self processKey:objectGUID type:objectType];
    [processPool removeObjectForKey:proceessKey];
}
@end
