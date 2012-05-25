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
    NSMutableDictionary* syncData;
    
    WizDownloadObject* downloader;
    WizUploadObjet* uploader;
    WizSyncInfo*    syncInfoer;
    WizRefreshToken* refresher;
    
    NSTimer* restartTimer;
    BOOL isRefreshToken;
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
- (BOOL) startUpload;
@end
@implementation WizSyncManager
@synthesize serverUrl;
@synthesize apiUrl;
@synthesize token;
@synthesize kbGuid;
@dynamic syncDescription;
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
- (NSString*) syncDescription
{
    NSArray* allSyncData = [syncData allValues];
    for (id each in allSyncData) {
        if ([each isKindOfClass:[WizApi class]]) {
            WizApi* api = (WizApi*)each;
            if (api.busy) {
                return api.syncMessage;
            }
        }
    }
    return syncDescription;
}
- (void) setSyncDescription:(NSString *)_syncDescription
{
    if (syncDescription == _syncDescription) {
        return;
    }
    if (_syncDescription == nil) {
        [syncDescription release];
        [self.displayDelegate didChangedSyncDescription:@""];
        return;
    }
    else {
        [syncDescription release];
        syncDescription =[_syncDescription retain];
        [self.displayDelegate didChangedSyncDescription:_syncDescription];
    }
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
}
- (id) init
{
    self = [super init];
    if (self) {
        
        syncData = [[NSMutableDictionary alloc] init];
        
        downloader = [syncData shareDownloader];
        uploader = [syncData shareUploader];
        refresher = [syncData shareRefreshTokener];
        syncInfoer = [syncData shareSyncInfo];
        //
        errorQueque = [[NSMutableArray alloc] init];
        
        self.token = WizStrName;
        self.kbGuid = WizStrName;
        [WizNotificationCenter addObserverForTokenUnactiveError:self selector:@selector(refreshToken)];
        isRefreshToken = NO;
        [self loadServerUrl];
        self.syncDescription = @"ddddd";
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
        [self addSyncToken:each];
        NSLog(@"%@",each);
        [each start];
    }
    [errorQueque removeAllObjects];
}

- (void) didRefreshToken:(NSDictionary *)dic
{
    isRefreshToken = NO;
    NSString* _token = [dic valueForKey:@"token"];
    NSString* _kbGuid = [dic valueForKey:@"kb_guid"];
    NSURL* urlAPI = [[NSURL alloc] initWithString:[dic valueForKey:@"kapi_url"]];
    self.token = _token;
    self.apiUrl = urlAPI;
    [urlAPI release];
    self.kbGuid = _kbGuid;
    self.syncDescription = @"did sync token";
    [self restartSync];
}
- (void) pauseAllSync
{
    NSArray* syncs = [syncData allValues];
    for (id each in syncs) {
        if ([each isKindOfClass:[WizRefreshToken class]]) {
            continue;
        }
        if ([each isKindOfClass:[WizApi class]])
        {
            WizApi* api = (WizApi*)each;
            if (!api.busy) {
                [errorQueque addObjectUnique:each];
            }
        }
    }
}
- (void) refreshToken
{
    [self pauseAllSync];
    if (isRefreshToken) {
        return;
    }
    isRefreshToken = YES;
    refresher.refreshDelegate = self;
    [refresher start];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    return YES;
}

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
    [uploader stopUpload];
    [downloader stopDownload];
    [syncInfoer cancel];
    [refresher cancel];
    [errorQueque removeAllObjects];
}

- (void) resignActive
{
    self.token = @"";
    self.kbGuid = @"";
    [self stopSync];
}
@end
