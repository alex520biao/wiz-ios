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
#import "WizShareSyncObjectCache.h"

//
#define ServerUrlFile           @"config.dat"
//
#define SyncDataOfUploader      @"SyncDataOfUploader"
#define SyncDataOfDownloader    @"SyncDataOfDownloader"
#define SyncDataOfRefreshToken  @"SyncDataOfRefreshToken"
#define SyncDataOfSyncInfo      @"SyncDataOfSyncInfo"
//
#define SyncDataOfObjectGUID        @"SyncDataOfObjectGUID"
#define SyncDataOfObjectType        @"SyncDataOfObjectType"
//
#define SyncDataOfToken         @"SyncDataOfToken"
#define SyncDataOfKbGuid        @"SyncDataOfKbGuid"
#define SyncDataOfWizApi        @"SyncDataOfWizApi"
#define SyncDataOfWizServerUrl  @"SyncDataOfWizServerUrl"
//
#define KeyOfServerUrl          @"KeyOfServerUrl"
#define KeyOfApiUrl             @"KeyOfApiUrl"


@interface WizSyncManager ()
{
    NSTimer* restartTimer;
    NSURL* serverUrl;
    NSURL* apiUrl;
    NSString* token;
    NSString* kbGuid;
}
@property (nonatomic, retain) NSURL* serverUrl;
@property (nonatomic, retain) NSURL* apiUrl;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSString* kbGuid;
- (void) refreshToken;
@end
@implementation WizSyncManager
@synthesize serverUrl;
@synthesize apiUrl;
@synthesize token;
@synthesize kbGuid;
@synthesize displayDelegate;
static WizSyncManager* shareManager;

- (BOOL) isSyncing
{
    for (WizApi* each in [[WizShareSyncObjectCache shareSyncObjectCache] allWorkWizApi]) {
        if (each.busy) {
            return YES;
        }
    }
    if ([[[WizShareSyncObjectCache shareSyncObjectCache] shareRefreshTokener] busy]) {
        return YES;
    }
    if ([[[WizShareSyncObjectCache shareSyncObjectCache] allErrorWizApi] count]) {
        return YES;
    }
    return NO;
}
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
    [restartTimer release];
    displayDelegate = nil;
    
    [super dealloc];
}
- (void) loadServerUrl
{
    self.serverUrl = [[WizSettings defaultSettings] wizServerUrl];
}
- (void) automicSyncData
{
    NSLog(@"************start automic sync****************");
    WizSettings* settings = [WizSettings defaultSettings];
    Reachability* reach = [[Reachability alloc] init];
    if ([settings isAutomicSync]) {
        if ([settings connectOnlyViaWifi]) {
            if ([reach currentReachabilityStatus] == ReachableViaWiFi) {
                 [self startSyncInfo];
            }
        }
        else {
             [self startSyncInfo];
        }
    }
    [reach release];
}
- (id) init
{
    self = [super init];
    if (self) {

        self.token = WizStrName;
        self.kbGuid = WizStrName;
        [self loadServerUrl];
    }
    return self;
}
//
- (void) restartSync
{
    for (WizApi* each in [[WizShareSyncObjectCache shareSyncObjectCache] allErrorWizApi]) {
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
        [self addSyncToken:each];
        [each start];
        [[WizShareSyncObjectCache shareSyncObjectCache] clearErrorWizApi:each];
    }
    [[WizShareSyncObjectCache shareSyncObjectCache] clearAllErrorWizApi];
}

- (void) didRefreshToken:(NSDictionary*)dic
{
    NSString* _token = [dic valueForKey:@"token"];
    NSString* _kbGuid = [dic valueForKey:@"kb_guid"];
    NSURL* urlAPI = [[NSURL alloc] initWithString:[dic valueForKey:@"kapi_url"]];
    self.token = _token;
    self.apiUrl = urlAPI;
    [urlAPI release];
    self.kbGuid = _kbGuid;
    [self restartSync];
}
- (void) pauseAllSync
{
    for (WizApi* each in [[WizShareSyncObjectCache shareSyncObjectCache] allWorkWizApi])
    {
        if ([each isKindOfClass:[WizRefreshToken class]])
        {
            continue;
        }
        if (!each.busy)
            [[WizShareSyncObjectCache shareSyncObjectCache] addErrorWizApi:each];
    }
}
- (void) refreshToken
{
    WizRefreshToken* refresher = [[WizShareSyncObjectCache shareSyncObjectCache] shareRefreshTokener];
    refresher.refreshDelegate = self;
    refresher.apiManagerDelegate = self;
    [refresher start];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    api.apiManagerDelegate = self;
    [[WizShareSyncObjectCache shareSyncObjectCache] addWorkWizApi:api];
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
- (void) didApiSyncDone:(WizApi *)api
{
    [[WizShareSyncObjectCache shareSyncObjectCache] clearWorkWizApi:api];
    [self.displayDelegate didChangedSyncDescription:nil];
}

- (void) didApiSyncError:(WizApi *)api error:(NSError *)error
{
    NSLog(@"%@",error);
    if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain]) {
        [self pauseAllSync];
        [self refreshToken];
    }
    else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorNotConnectedToInternet)
    {
        [[WizShareSyncObjectCache shareSyncObjectCache] clearAllWorkWizApi];
        [[WizShareSyncObjectCache shareSyncObjectCache] clearAllErrorWizApi];
        if (self.displayDelegate) {
            [self.displayDelegate didChangedSyncDescription:nil];
        }
    }
}

- (void) didChangedSyncDescriptorMessage:(NSString *)descriptorMessage
{
    [self.displayDelegate didChangedSyncDescription:descriptorMessage];
//    MTStatusBarOverlay* share = [MTStatusBarOverlay sharedInstance];
//    [share postFinishMessage:descriptorMessage duration:1.5 animated:YES];
//    [share setDetailViewMode:MTDetailViewModeHistory];
//    share.progress = 1.0;
}
//
- (BOOL) isUploadingWizObject:(WizObject*)wizobject
{
    return [[WizShareSyncObjectCache shareSyncObjectCache] isUploadingWizObject:wizobject];
}
- (BOOL) uploadWizObject:(WizObject*)object
{
    WizShareSyncObjectCache* share = [WizShareSyncObjectCache shareSyncObjectCache];
    [share addShouldUploadWizObject:object];
    WizUploadObjet* uploader = [share shareUploadTool];
    if (uploader) {
        uploader.apiManagerDelegate = self;
        [self addSyncToken:uploader];
        [uploader startUpload];
    }
    return YES;
}

- (BOOL) isDownloadingWizobject:(WizObject*)object
{
    return [[WizShareSyncObjectCache shareSyncObjectCache] isDownloadingWizObject:object];
}
- (void) downloadWizObject:(WizObject*)object
{
    WizShareSyncObjectCache* share = [WizShareSyncObjectCache shareSyncObjectCache];
    WizDownloadObject* downloader = [share shareDownloadTool];
    [share addShouldDownloadWizObject:object];
    if (downloader) {
        downloader.apiManagerDelegate = self;
        [self addSyncToken:downloader];
        [downloader startDownload];
    }
}
//
- (BOOL) startSyncInfo
{
    WizSyncInfo* shareSyncInfoer = [[WizShareSyncObjectCache shareSyncObjectCache] shareSyncInfo];
    shareSyncInfoer.apiManagerDelegate = self;
    [self addSyncToken:shareSyncInfoer];
    return [shareSyncInfoer start];
}
//

- (void) stopSync
{
    [[WizShareSyncObjectCache shareSyncObjectCache] stopAllWizApi];

}

- (void) resignActive
{
    self.token = @"";
    self.kbGuid = @"";
    [self stopSync];
}

- (void) searchKeywords:(NSString*)keywords  searchDelegate:(id<WizSyncSearchDelegate>)searchDelegate
{
    WizSyncSearch* searcher = [[WizShareSyncObjectCache shareSyncObjectCache] shareSearch];
    searcher.apiManagerDelegate = self;
    [searcher setSearchDelegate:searchDelegate];
    searcher.keyWord = keywords;
    [self addSyncToken:searcher];
    [searcher start];
}
@end
