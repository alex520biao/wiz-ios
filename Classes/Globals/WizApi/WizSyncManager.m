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
    NSMutableArray* errorQueque;
    NSMutableArray* workQueque;
    
    NSMutableDictionary* syncData;
    
    WizDownloadObject* downloader;
    WizUploadObjet* uploader;
    WizSyncInfo*    syncInfoer;
    WizRefreshToken* refresher;
    WizSyncSearch* searcher;
    
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
    NSArray* allSyncData = [syncData allValues];
    for (id each in allSyncData) {
        if ([each isKindOfClass:[WizApi class]]) {
            WizApi* api = (WizApi*)each;
            if (api.busy) {
                return YES;
            }
        }
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
    [errorQueque release];
    [syncData release];
    [restartTimer release];
    displayDelegate = nil;
    
    downloader = nil;
    uploader = nil;
    refresher = nil;
    syncInfoer = nil;
    
    [workQueque release];
    workQueque = nil;
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
        syncData = [[NSMutableDictionary alloc] init];
        //
        downloader = [syncData shareDownloader];
        downloader.apiManagerDelegate = self;
        //
        uploader = [syncData shareUploader];
        uploader.apiManagerDelegate = self;
        //
        refresher = [syncData shareRefreshTokener];
        refresher.apiManagerDelegate = self;
        //
        syncInfoer = [syncData shareSyncInfo];
        syncInfoer.apiManagerDelegate = self;
        //
        searcher = [syncData shareSearch];
        searcher.apiManagerDelegate = self;
        //
        errorQueque = [[NSMutableArray alloc] init];
        workQueque = [[NSMutableArray alloc] init];
        //
        self.token = WizStrName;
        self.kbGuid = WizStrName;
        [self loadServerUrl];
    }
    return self;
}
//
- (void) restartSync
{
    NSLog(@"error api count is %d",[errorQueque count]);
    for (WizApi* each in errorQueque) {
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
        NSLog(@"%@",each);
        [each start];
    }
    [errorQueque removeAllObjects];
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
    for (WizApi* each in workQueque)
    {
        if ([each isKindOfClass:[WizRefreshToken class]])
        {
            continue;
        }
        if (!each.busy)  [errorQueque addObjectUnique:each];
    }
    for(WizApi* each in errorQueque)
{
    [workQueque removeObject:each];
}
}
- (void) refreshToken
{
    refresher.refreshDelegate = self;
    [refresher start];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    [workQueque addObject:api];
    return YES;
}

- (void) didApiSyncDone:(WizApi *)api
{
    [workQueque removeObject:api];
    NSLog(@"work count is %d",[workQueque count]);
}

- (void) didApiSyncError:(WizApi *)api error:(NSError *)error
{
    NSLog(@"%@",error);
    if (error.code == CodeOfTokenUnActiveError && [error.domain isEqualToString:WizErrorDomain]) {
        [self pauseAllSync];
        [self refreshToken];
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
    return [uploader isUploadWizObject:wizobject];
}
- (BOOL) uploadWizObject:(WizObject*)object
{
    [self addSyncToken:uploader];
    return [uploader uploadWizObject:object];
}

- (BOOL) isDownloadingWizobject:(WizObject*)object
{
    return [downloader isDownloadWizObject:object];
}
- (void) downloadWizObject:(WizObject*)object
{
    [self addSyncToken:downloader];
    [downloader downloadWizObject:object];
}
//
- (BOOL) startSyncInfo
{
    [self addSyncToken:syncInfoer];
    return [syncInfoer start];
}
//

- (void) stopSync
{
    [workQueque removeAllObjects];
    [errorQueque removeAllObjects];
    [uploader stopUpload];
    [downloader stopDownload];
    [syncInfoer cancel];
    [refresher cancel];
    [searcher cancel];

}

- (void) resignActive
{
    self.token = @"";
    self.kbGuid = @"";
    [self stopSync];
}

- (void) searchKeywords:(NSString*)keywords  searchDelegate:(id<WizSyncSearchDelegate>)searchDelegate
{
    [searcher setSearchDelegate:searchDelegate];
    searcher.keyWord = keywords;
    [self addSyncToken:searcher];
    [searcher start];
}
@end
