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

@implementation WizDownloadPool
@synthesize processPool;
@synthesize accountUserId;
- (void) dealloc
{
   self.processPool = nil;
    self.accountUserId = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        int count = [[self.processPool allValues] count];
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"There are %d notes that is downloaded, please wait a while....", nil),count ];
        NSError* error = [NSError errorWithDomain:@"MyDomain" code:2 userInfo:[NSDictionary dictionaryWithObject:msg forKey:NSLocalizedDescriptionKey]];
        [WizGlobals reportWarning:error];
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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDownloadData:) name:[download notificationName: WizSyncXmlRpcDonlowadDoneNotificationPrefix] object:nil];
            [download release];
        }
        if ([WizGlobals checkObjectIsAttachment:objectType]) {
            download = [[WizDownloadAttachment alloc] initWithAccount:accountUserId password:@""];
            [self.processPool setObject:download forKey:proceessKey];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDownloadData:) name:[download notificationName: WizSyncXmlRpcDonlowadDoneNotificationPrefix] object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeDownloadData:) name:[download notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
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
