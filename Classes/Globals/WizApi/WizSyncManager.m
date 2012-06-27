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
#import "WizGlobalError.h"


@interface WizSyncManager ()
{
    NSURL* serverUrl;
    NSURL* apiUrl;
    NSString* token;
    NSMutableDictionary* syncDataDictionary;
}
@property (atomic, retain) NSMutableDictionary* syncDataDictionary;
@property (nonatomic, retain) NSURL* apiUrl;
@property (nonatomic, retain) NSString* token;
- (void) refreshToken;
@end
@implementation WizSyncManager
@synthesize apiUrl;
@synthesize token;
@synthesize displayDelegate;
@synthesize syncDataDictionary;
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

- (NSString*)getShareToken
{
    return self.token;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.syncDataDictionary = [NSMutableDictionary dictionary];
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


- (WizSync*) getWizSyncForGroup:(NSString*)kbguid
{
    if (kbguid == nil) {
        return nil;
    }
    WizSync* sync = [self.syncDataDictionary valueForKey:kbguid];
    if (!sync) {
        sync = [[WizSync alloc] init];
        sync.kbGuid = kbguid;
        sync.token = self.token;
        sync.apiUrl = self.apiUrl;
        [self.syncDataDictionary setObject:sync forKey:kbguid];
        [sync release];
    }
    return sync;
}

- (void) restartSync
{
    for (NSArray* each in [self.syncDataDictionary allValues]) {
        WizSync* sync = (WizSync*)each;
        sync.token = self.token;
        sync.apiUrl = self.apiUrl;
        [sync restartSync];
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
    else if (error.code == WizCanNoteResloceErrorCode && [error.domain isEqualToString:WizErrorDomain])
    {
        [[WizSyncData shareSyncData] doErrorEndApi:api];
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
    if ([api isKindOfClass:[WizSyncInfo class]])
    {
        WizSync* sync = [self getWizSyncForGroup:api.kbguid];
        [sync downloadCacheDocuments];
        [sync uploadAllObject];
    }
}

- (BOOL) isWizSyncCanReuse:(WizSync*)sync
{
    if ([sync isSyncing]) {
        return NO;
    }
    else
    {
        return YES;
    }
}


- (WizSync*) syncDataForGroup:(NSString*)kbguid
{
    WizSync* sync = [self getWizSyncForGroup:kbguid];
    return sync;
}
- (WizSync*) activeGroupSync
{
    return [self getWizSyncForGroup:[[WizAccountManager defaultManager] activeAccountGroupKbguid]];
}
- (void) registerAciveGroup:(NSString *)kbguid
{
    
}

- (void) refreshGroupsData
{
    NSArray* array = [[WizAccountManager defaultManager] activeAccountGroups];
    for (NSArray* each in array) {
        for (WizGroup* group in each) {
            WizSync* sync = [self getWizSyncForGroup:group.kbguid];
            [sync startSyncInfo];
        }
    }
}
- (void) stopSync
{
    for (WizSync* each in [self.syncDataDictionary allValues]) {
        if ([each isSyncing]) {
            [each stopSync];
        }
    }
}


@end
