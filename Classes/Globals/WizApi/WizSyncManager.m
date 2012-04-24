//
//  WizSyncManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncManager.h"
#import "WizGlobalData.h"
#import "WizUploadObjet.h"
#import "WizNotification.h"
#import "WizRefreshToken.h"
#import "WizDownloadObject.h"

#import "WizSyncInfo.h"
#import "WizDbManager.h"

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
- (void) downloadNext:(NSNotification*)nc;
- (BOOL) uploadNext:(NSNotification*)nc;
- (void) startDownload;
@end
@implementation WizSyncManager
@synthesize serverUrl;
@synthesize apiUrl;
@synthesize token;
@synthesize kbGuid;
@dynamic syncDescription;
@synthesize displayDelegate;
static WizSyncManager* shareManager;

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

- (id) init
{
    self = [super init];
    if (self) {
        
        syncData = [[NSMutableDictionary alloc] init];
        uploadQueque = [[NSMutableArray alloc] init];
        downloadQueque = [[NSMutableArray alloc] init];
        errorQueque = [[NSMutableArray alloc] init];
        restartTimer = [NSTimer timerWithTimeInterval:60 target:self selector:@selector(restartSync) userInfo:nil repeats:YES];
        [restartTimer retain];
        [WizNotificationCenter addObserverForTokenUnactiveError:self selector:@selector(refreshToken)];
        [WizNotificationCenter addObserverForUploadDone:self selector:@selector(uploadNext:)];
        [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(downloadNext:)];
        isRefreshToken = NO;
        [self loadServerUrl];
        self.syncDescription = @"ddddd";
    }
    return self;
}
- (WizUploadObjet*) shareUploader
{
    id data = [syncData valueForKey:SyncDataOfUploader];
    NSLog(@"upload calss is %@",[data class]);
    if (nil == data || ![data isKindOfClass:[WizUploadObjet class]]) {
        data = [[WizUploadObjet alloc] init];
        [syncData setObject:data forKey:SyncDataOfUploader];
        NSLog(@"upload is %@",data);
        [data release];
    }
    return data;
}
- (WizDownloadObject*) shareDownloader
{
    id data = [syncData valueForKey:SyncDataOfDownloader];
    NSLog(@"download calss is %@",[data class]);
    if (nil == data || ![data isKindOfClass:[WizDownloadObject class]]) {
        data = [[WizDownloadObject alloc] init];
        [syncData setObject:data forKey:SyncDataOfDownloader];
        NSLog(@"downloader is %@",data);
        [data release];
    }
    self.syncDescription = @"xxxxxxx";
    return data;
}
- (WizRefreshToken*) shareRefreshTokener
{
    id data = [syncData valueForKey:SyncDataOfRefreshToken];
    if (nil == nil || [data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] init];
        [data setAccountURL:self.serverUrl];
        [syncData setObject:data forKey:SyncDataOfRefreshToken];
        [data release];
    }
    return data;
}
- (WizSyncInfo*) shareSyncInfo
{
    id data = [syncData valueForKey:SyncDataOfSyncInfo];
    if (nil == nil || [data isKindOfClass:[WizSyncInfo class]]) {
        data = [[WizSyncInfo alloc] init];
        [data setDbDelegate:[WizDbManager shareDbManager]];
        [syncData setObject:data forKey:SyncDataOfSyncInfo];
        [data release];
    }
    return data;
}


//
- (NSInteger) findSyncObject:(NSString*)guid     syncArray:(NSArray*)syncArray
{
    for (int i = 0; i < [syncArray count]; i++) {
        NSDictionary* dic = [syncArray objectAtIndex:i];
        NSString* _guid = [dic valueForKey:SyncDataOfObjectGUID];
        if ([_guid isEqualToString:guid]) {
            return i;
        }
    }
    return NSNotFound;
}

- (void) addSyncDataToArray:(NSDictionary*)obj    array:(NSMutableArray*)array
{
    NSString* objGuid = [obj valueForKey:SyncDataOfObjectGUID];
    if ([self findSyncObject:objGuid syncArray:array] == NSNotFound) {
        [array insertObject:obj atIndex:0];
    }
}
- (void) removeSyncDataFromArray:(NSString*)_guid   array:(NSMutableArray*)array
{
    NSInteger index = [self findSyncObject:_guid syncArray:array];
    if (index != NSNotFound) {
        [array removeObjectAtIndex:index];
    }
}

- (void) restartSync
{
    for (id each in errorQueque) {
        if ([each isKindOfClass:[WizUploadObjet class]]) {
            [self startUpload];
        }
        else if ([each isKindOfClass:[WizDownloadObject class]])
        {
            [self startDownload];
        }
        else  if ([each isKindOfClass:[WizSyncInfo class]])
        {
            [self startSyncInfo];
        }
    }
    [errorQueque removeAllObjects];
}

- (void) didRefreshToken:(NSNotification*)nc
{
    [WizNotificationCenter removeObserverForRefreshToken:self];
    isRefreshToken = NO;
    NSDictionary* keys = [WizNotificationCenter getRefreshTokenDicFromNc:nc];
    NSString* _token = [keys valueForKey:@"token"];
    NSString* _kbGuid = [keys valueForKey:@"kb_guid"];
    NSURL* urlAPI = [[NSURL alloc] initWithString:[keys valueForKey:@"kapi_url"]];
    self.token = _token;
    self.apiUrl = urlAPI;
    self.kbGuid = _kbGuid;
    self.syncDescription = @"did sync token";
    NSLog(@"did refresh token");
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
            [errorQueque addObjectUnique:each];
            NSLog(@"error api is %@",each);
        }
    }
}
- (void) refreshToken
{
    WizRefreshToken* re = [self shareRefreshTokener];
    if (isRefreshToken) {
        return;
    }
    isRefreshToken = YES;
    NSLog(@"will refresh token");
    [WizNotificationCenter addObserverForRefreshToken:self selector:@selector(didRefreshToken:)];
    [self pauseAllSync];
    [re refresh];
    
}
- (BOOL) addSyncToken:(WizApi*)api
{
    if (nil == self.token || [self.token isEqualToString:@""]) {
        [self refreshToken];
        return NO;
    }
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    return YES;
}
- (BOOL) startUpload
{
    
    WizUploadObjet* uploader = [self shareUploader];
    if (![self addSyncToken:uploader]) {
        return NO;
    }
    if (uploader.busy) {
        return NO;
    }
    if ([uploadQueque count] == 0) {
        return YES;
    }
    NSDictionary* obj = [uploadQueque objectAtIndex:0];
    NSString* type = [obj valueForKey:SyncDataOfObjectType];
    NSString* guid = [obj valueForKey:SyncDataOfObjectGUID];

    BOOL ret;
    if ([type isEqualToString:WizDocumentKeyString]) {
        ret = [uploader uploadDocument:[WizDocument documentFromDb:guid]];
    }
    else if ([type isEqualToString:WizAttachmentKeyString])
    {
        ret =  [uploader uploadAttachment:[WizAttachment attachmentFromDb:guid]];
    }
    else {
        ret = NO;
    }
    self.syncDescription = [NSString stringWithFormat:@"upload %@",guid];
    return ret;
}
- (void) removeUploadObject:(NSString*)_guid
{
    [self removeSyncDataFromArray:_guid array:uploadQueque];
}
- (BOOL) uploadNext:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter uploadGuidFromNc:nc];
    [self removeUploadObject:guid];
    return [self startUpload];
}

- (NSDictionary*) documentSyncData:(NSString*)documentGUID
{
    return [NSDictionary dictionaryWithObjectsAndKeys:documentGUID,SyncDataOfObjectGUID,WizDocumentKeyString, SyncDataOfObjectType, nil];
}
- (NSDictionary*) attachmentSyncData:(NSString*)attachmentGUID
{
    return [NSDictionary dictionaryWithObjectsAndKeys:attachmentGUID,SyncDataOfObjectGUID,WizAttachmentKeyString, SyncDataOfObjectType, nil];
}

- (BOOL) isSyncingObject:(NSString*)objectGuid  syncArray:(NSArray*)array
{
    if ([self findSyncObject:objectGuid syncArray:array] == NSNotFound) {
        return NO;
    }
    else {
        return YES;
    }
}
- (BOOL) isUploadingDocument:(NSString*)documentGUID
{
    return [self isSyncingObject:documentGUID syncArray:uploadQueque];
}
- (BOOL) isUploadingAttachment:(NSString*)attachmentGUID
{
    return [self isSyncingObject:attachmentGUID syncArray:uploadQueque];
}
- (BOOL) uploadDocument:(NSString*)documentGUID
{
    NSDictionary* doc = [self documentSyncData:documentGUID];
    [self addSyncDataToArray:doc array:uploadQueque];
    return [self startUpload];
}
- (BOOL) uploadAttachment:(NSString*)attachmentGUID
{
    NSDictionary* attach = [self attachmentSyncData:attachmentGUID];
    [self addSyncDataToArray:attach array:uploadQueque];
    return [self startUpload];
}
//

- (void) startDownload
{
    WizDownloadObject* downloader = [self shareDownloader];
    if (![self addSyncToken:downloader]) {
        return ;
    }
    NSLog(@"download busy is %d",downloader.busy);
    if (downloader.busy) {
        return ;
    }
    if ([downloadQueque count] == 0) {
        return ;
    }
    NSDictionary* obj = [downloadQueque objectAtIndex:0];
    NSString* type = [obj valueForKey:SyncDataOfObjectType];
    NSString* guid = [obj valueForKey:SyncDataOfObjectGUID];
    if ([type isEqualToString:WizDocumentKeyString]) {
        [downloader downloadDocument:guid];
    }
    else if ([type isEqualToString:WizAttachmentKeyString])
    {
        [downloader downloadAttachment:guid];
    }
}
- (void) removeDownloadObject:(NSString*)guid
{
    [self removeSyncDataFromArray:guid array:downloadQueque];
}
- (void) downloadNext:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter downloadGuidFromNc:nc];
    [self removeDownloadObject:guid];
    [self startDownload];
}
- (BOOL) isDownloadingDocument:(NSString*)documentGUID
{
    return [self isSyncingObject:documentGUID syncArray:downloadQueque];
}
- (BOOL) isDownloadingAttachment:(NSString*)attachmentGUID
{
    return [self isSyncingObject:attachmentGUID syncArray:downloadQueque];
}


- (void) downloadAttachment:(NSString*)attachmentGUID
{
    NSDictionary* attach = [self attachmentSyncData:attachmentGUID];
    [self addSyncDataToArray:attach array:downloadQueque];
    [self startDownload];
}
- (void) downloadDocument:(NSString*)documentGUID
{
    NSDictionary* doc = [self documentSyncData:documentGUID];
    [self addSyncDataToArray:doc array:downloadQueque];
    [self startDownload];
}
//
- (BOOL) startSyncInfo
{
    WizSyncInfo* syncInfo = [self shareSyncInfo];
    if (![self addSyncToken:syncInfo]) {
        return NO;
    }
    return [syncInfo startSync];
}

//
- (void) resignActive
{
    [downloadQueque removeAllObjects];
    [errorQueque removeAllObjects];
    [uploadQueque removeAllObjects];
}
@end
