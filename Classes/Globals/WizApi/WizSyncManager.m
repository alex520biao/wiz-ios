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

@interface NSMutableArray (WizSyncData)
- (BOOL) hasWizObject:(WizObject*)obj;
@end

@implementation NSMutableArray (WizSyncData)
- (BOOL) hasWizObject:(WizObject *)obj
{
    for (WizObject* each in self) {
        if ([each.guid isEqualToString:obj.guid]) {
            return YES;
        }
    }
    return  NO;
}
@end
@interface WizSyncManager ()
{
    NSMutableArray* downloadQueque;
    NSMutableArray* uploadQueque;
    NSMutableArray* errorQueque;
    NSMutableDictionary* syncData;
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
- (void) startDownload;
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
    if ([errorQueque count] || [downloadQueque count] || [uploadQueque count]) {
        return YES;
    }
    else {
        self.syncDescription = @"";
        return NO;
    }
}
- (NSString*) syncDescription
{
    return syncDescription;
}
- (void) setSyncDescription:(NSString *)_syncDescription
{
    if (syncDescription == _syncDescription) {
        return;
    }
    [syncDescription release];
    syncDescription =[_syncDescription retain];
    if (nil != self.displayDelegate) {
        [self.displayDelegate didChangedSyncDescription:syncDescription];
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
    [downloadQueque release];
    [uploadQueque release];
    [errorQueque release];
    [syncData release];
    [restartTimer release];
    [super dealloc];
}
- (void) loadServerUrl
{
    self.serverUrl = [WizGlobals wizServerUrl];
}
- (void) automicSyncData
{
    NSLog(@"************start automic sync****************");
    if ([[WizSettings defaultSettings] isAutomicSync]) {
        [self startSyncInfo];
    }
}
- (id) init
{
    self = [super init];
    if (self) {
        
        syncData = [[NSMutableDictionary alloc] init];
        uploadQueque = [[NSMutableArray alloc] init];
        downloadQueque = [[NSMutableArray alloc] init];
        errorQueque = [[NSMutableArray alloc] init];
        [WizNotificationCenter addObserverForTokenUnactiveError:self selector:@selector(refreshToken)];
        [WizNotificationCenter addObserverForUploadDone:self selector:@selector(startUpload)];
        [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(startDownload)];
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
        [self addSyncToken:each];
        [each start];
    }
    [errorQueque removeAllObjects];
}

- (void) didRefreshToken:(NSNotification*)nc
{
    [WizNotificationCenter removeObserverForRefreshToken:self];
    [syncData removeObjectForKey:SyncDataOfRefreshToken];
    isRefreshToken = NO;
    NSDictionary* keys = [WizNotificationCenter getRefreshTokenDicFromNc:nc];
    NSString* _token = [keys valueForKey:@"token"];
    NSString* _kbGuid = [keys valueForKey:@"kb_guid"];
    NSURL* urlAPI = [[NSURL alloc] initWithString:[keys valueForKey:@"kapi_url"]];
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
        if ([each isKindOfClass:[WizApi class]]) {
            [errorQueque addObjectUnique:each];        }
    }
}
- (void) refreshToken
{
    WizRefreshToken* re = [syncData shareRefreshTokener];
    if (isRefreshToken) {
        return;
    }
    isRefreshToken = YES;
    [WizNotificationCenter addObserverForRefreshToken:self selector:@selector(didRefreshToken:)];
    [self pauseAllSync];
    [re start];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    return YES;
}
- (BOOL) startUpload
{
    [self isSyncing];
    WizUploadObjet* uploader = [syncData shareUploader];
    if (uploader.busy) {
        return NO;
    }
    if ([uploadQueque count] == 0) {
        [syncData removeObjectForKey:SyncDataOfUploader];
        return YES;
    }
    [self addSyncToken:uploader];
    WizObject* obj = [uploadQueque objectAtIndex:0];
    [uploader uploadWizObject:obj];
    [uploadQueque removeObjectAtIndex:0];
    return YES;
}
- (BOOL) isUploadingWizObject:(WizObject*)wizobject
{
    return [uploadQueque hasWizObject:wizobject];
}
- (BOOL) uploadWizObject:(WizObject*)object
{
    [uploadQueque addWizObjectUnique:object];
    return [self startUpload];
}
- (void) startDownload
{
    WizDownloadObject* downloader = [syncData shareDownloader];
    if (downloader.busy) {
        return ;
    }
    [self addSyncToken:downloader];
    if ([downloadQueque count] == 0) {
        [syncData removeObjectForKey:SyncDataOfDownloader];
        return ;
    }
    WizObject* object = [downloadQueque lastObject];
    [downloader downloadWizObject:object];
    [downloadQueque removeObjectAtIndex:0];
}
- (BOOL) isDownloadingWizobject:(WizObject*)object
{
    return [downloadQueque hasWizObject:object];
}
- (void) downloadWizObject:(WizObject*)object
{
    [downloadQueque addWizObjectUnique:object];
    [self startDownload];
}
//
- (BOOL) startSyncInfo
{
    WizSyncInfo* syncInfo = [syncData shareSyncInfo];
    [self addSyncToken:syncInfo];
    return [syncInfo start];
}
//
- (void) resignActive
{
    [downloadQueque removeAllObjects];
    [errorQueque removeAllObjects];
    [uploadQueque removeAllObjects];
}
@end
