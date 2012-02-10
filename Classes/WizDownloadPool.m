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
@implementation WizDownloadPool
@synthesize processPool;
@synthesize accountUserId;
- (void) dealloc
{
   self.processPool = nil;
    self.accountUserId = nil;
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
    id data = [self.processPool valueForKey:[self processKey:documentGUID type:[WizGlobals documentKeyString]]];
    return nil != data;
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
        }
        if ([WizGlobals checkObjectIsAttachment:objectType]) {
            download = [[WizDownloadAttachment alloc] initWithAccount:accountUserId password:@""];
            [self.processPool setObject:download forKey:proceessKey];
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
