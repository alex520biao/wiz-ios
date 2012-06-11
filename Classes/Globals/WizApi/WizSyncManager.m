//
//  WizSyncManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncManager.h"
#import "WizGlobalData.h"
#import "WizNotification.h"
#import "WizDbManager.h"
#import "WizSyncData.h"
#import "Reachability.h"
#import "WizSettings.h"
#import "MTStatusBarOverlay.h"
#import "WizSyncSearch.h"
#import "WizAccountManager.h"
#import "WizSync.h"


@interface WizSyncManager ()
{
    NSURL* serverUrl;
    NSURL* apiUrl;
    NSString* token;
    NSMutableArray* syncArray;
    WizSync* activeSync;
}
@property (nonatomic, retain) NSURL* apiUrl;
@property (nonatomic, retain) NSString* token;
- (void) refreshToken;
@end
@implementation WizSyncManager
@synthesize apiUrl;
@synthesize token;
@synthesize displayDelegate;
static WizSyncManager* shareManager;
+ (id) shareManager
{
    @synchronized(shareManager)
    {
        if (nil == shareManager) {
            shareManager = [[super allocWithZone:nil] init];
        }
    }
    return shareManager;
}
- (void) dealloc
{
    displayDelegate = nil;
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
        syncArray = [[NSMutableArray alloc] init];
        self.token = WizStrName;
    }
    return self;
}
//
- (void) restartApi:(WizApi*)each
{
    [self addSyncToken:each];
    [[WizSyncData shareSyncData] doErrorEndApi:each];
    [each start];
    [[WizSyncData shareSyncData] doWorkBegainApi:each];
}

- (void) restartSync
{
    for (WizSync* each in syncArray) {
        each.token = self.token;
        each.apiUrl = self.apiUrl;
    }
    for (WizApi* each in [[WizSyncData shareSyncData] errorQueque]) {
        if ([each isKindOfClass:[WizRefreshToken class]]) {
            continue;
        }
        if (each.busy) {
            continue;
        }
        if ([each isKindOfClass:[WizSyncSearch class]]) {
            WizSyncSearch* search = (WizSyncSearch*)each;
            if (!search.isSearching) {
                continue;
            }
        }
        [self restartApi:each];
    }
}

- (void) didRefreshToken:(NSDictionary*)dic
{
    NSString* _token = [dic valueForKey:@"token"];

    NSURL* urlAPI = [[NSURL alloc] initWithString:[dic valueForKey:@"kapi_url"]];
    self.token = _token;
    self.apiUrl = urlAPI;
    [urlAPI release];
    [self restartSync];
}

- (void) refreshToken
{
    WizRefreshToken* refresh = [[WizSyncData shareSyncData] refreshData];
    refresh.refreshDelegate = self;
    [refresh start];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.apiURL = self.apiUrl;
    return YES;
}
- (void) didChangedStatue:(WizApi *)api statue:(NSInteger)statue
{
    if (statue == WizSyncStatueEndSyncInfo) {
        [self.displayDelegate didChangedSyncDescription:nil];
    }
    else if (statue == WizSyncStatueError) {
        [self.displayDelegate didChangedSyncDescription:nil];
    }
}
- (void) didApiSyncError:(WizApi *)api error:(NSError *)error
{
    if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain]) {
        [[WizSyncData shareSyncData] doErrorBegainApi:api];
        [self refreshToken];
    }
}

- (void) didChangedSyncDescriptorMessage:(NSString *)descriptorMessage
{
    [self.displayDelegate didChangedSyncDescription:descriptorMessage];
}
- (void) resignActive
{
    self.token = @"";
}

- (void) didApiSyncDone:(WizApi *)api
{
    [[WizSyncData shareSyncData] doWorkEndApi:api];
    if ([api isKindOfClass:[WizSyncInfo class]]) {
        [activeSync uploadAllObject];
    }
}
- (WizSync*) syncDataForGroup:(NSString*)kbguid
{
    for (WizSync* each in syncArray) {
        if ([each.kbGuid isEqualToString:kbguid]) {
            return each;
        }
    }
    WizSync* sync = [[WizSync alloc] init];
    sync.token = self.token;
    sync.apiUrl = self.apiUrl;
    sync.kbGuid = kbguid;
    [syncArray addObject:sync];
    [sync release];
    return sync;
}
- (WizSync*) activeGroupSync
{
    return activeSync;
}
- (void) registerAciveGroup:(NSString *)kbguid
{
    if (activeSync) {
        [activeSync stopSync];
    }
    WizSync* sync = [self syncDataForGroup:kbguid];
    activeSync = sync;
    NSLog(@"%@",activeSync);
}
@end
