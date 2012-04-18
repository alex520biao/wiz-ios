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
//
#define SyncDataOfUploader      @"SyncDataOfUploader"
#define SyncDataOfDownloader    @"SyncDataOfDownloader"
#define SyncDataOfRefreshToken  @"SyncDataOfRefreshToken"
//
#define SyncDataOfObjectGUID        @"SyncDataOfObjectGUID"
#define SyncDataOfObjectType        @"SyncDataOfObjectType"
//
#define SyncDataOfToken         @"SyncDataOfToken"
#define SyncDataOfKbGuid        @"SyncDataOfKbGuid"
#define SyncDataOfWizApi        @"SyncDataOfWizApi"
//
@interface WizSyncManager ()
{
    NSMutableArray* downloadQueque;
    NSMutableArray* uploadQueque;
    NSMutableArray* errorQueque;
    NSMutableDictionary* syncData;
    NSTimer* restartTimer;
    BOOL isRefreshToken;
}
- (void) refreshToken;
- (void) downloadNext:(NSNotification*)nc;
- (BOOL) uploadNext:(NSNotification*)nc;
- (void) startDownload;
@end
@implementation WizSyncManager
@synthesize accountUserId;
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
    [downloadQueque release];
    [uploadQueque release];
    [errorQueque release];
    [syncData release];
    [restartTimer release];
    [super dealloc];
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
    }
    return self;
}
- (WizUploadObjet*) shareUploader
{
    id data = [syncData valueForKey:SyncDataOfUploader];
    NSLog(@"upload calss is %@",[data class]);
    if (nil == data || ![data isKindOfClass:[WizUploadObjet class]]) {
        data = [[WizUploadObjet alloc] initWithAccount:self.accountUserId password:nil];
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
        data = [[WizDownloadObject alloc] initWithAccount:self.accountUserId password:nil];
        [syncData setObject:data forKey:SyncDataOfDownloader];
        NSLog(@"downloader is %@",data);
        [data release];
    }
    return data;
}
- (WizRefreshToken*) shareRefreshTokener
{
    id data = [syncData valueForKey:SyncDataOfRefreshToken];
    if (nil == nil || [data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] initWithAccount:self.accountUserId password:nil];
        [syncData setObject:data forKey:SyncDataOfRefreshToken];
        [data release];
    }
    return data;
}
- (void) removeSyncDataFromArray:(NSString*)_guid   array:(NSMutableArray*)array
{
    NSDictionary* dic = nil;
    for (NSDictionary* each in array) {
        NSString* guid = [each valueForKey:SyncDataOfObjectGUID];
        if (nil != guid && [guid isEqualToString:_guid]) {
            dic = each;
            break;
        }
    }
    if (nil != dic) {
        [array removeObject:dic];
    }
}
- (void) removeUploadObject:(NSString*)_guid
{
    [self removeSyncDataFromArray:_guid array:uploadQueque];
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
    }
    [errorQueque removeAllObjects];
}
- (void) didRefreshToken:(NSNotification*)nc
{
    [WizNotificationCenter removeObserverForRefreshToken:self];
    isRefreshToken = NO;
    NSDictionary* keys = [WizNotificationCenter getRefreshTokenDicFromNc:nc];
    NSString* token = [keys valueForKey:@"token"];
    NSString* kbGuid = [keys valueForKey:@"kb_guid"];
    NSURL* urlAPI = [[NSURL alloc] initWithString:[keys valueForKey:@"kapi_url"]];
    [syncData setObject:token forKey:SyncDataOfToken];
    [syncData setObject:kbGuid forKey:SyncDataOfKbGuid];
    [syncData setObject:urlAPI forKey:SyncDataOfWizApi];
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
    NSString* token = [syncData valueForKey:SyncDataOfToken];
    if (nil == token || [token isEqualToString:@""]) {
        [errorQueque addObjectUnique:api];
        [self refreshToken];
        return NO;
    }
    NSString* kbGuid = [syncData valueForKey:SyncDataOfKbGuid];
    api.token = token;
    api.kbguid = kbGuid;
    api.apiURL = [syncData valueForKey:SyncDataOfWizApi];
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
        ret = [uploader uploadDocument:guid];
    }
    else if ([type isEqualToString:WizAttachmentKeyString])
    {
        ret =  [uploader uploadAttachment:guid];
    }
    else {
        ret = NO;
    }
    return ret;
} 
- (BOOL) uploadNext:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter uploadGuidFromNc:nc];
    [self removeUploadObject:guid];
    return [self startUpload];
}
- (void) addSyncDataToArray:(NSDictionary*)obj    array:(NSMutableArray*)array
{
    NSString* objGuid = [obj valueForKey:SyncDataOfObjectGUID];
    for (NSDictionary* dic in array) {
        NSString* guid = [dic valueForKey:SyncDataOfObjectGUID];
        if ([guid isEqualToString:objGuid]) {
            return;
        }
    }
    [array insertObject:obj atIndex:0];
}
- (NSDictionary*) documentSyncData:(NSString*)documentGUID
{
    return [NSDictionary dictionaryWithObjectsAndKeys:documentGUID,SyncDataOfObjectGUID,WizDocumentKeyString, SyncDataOfObjectType, nil];
}
- (NSDictionary*) attachmentSyncData:(NSString*)attachmentGUID
{
    return [NSDictionary dictionaryWithObjectsAndKeys:attachmentGUID,SyncDataOfObjectGUID,WizAttachmentKeyString, SyncDataOfObjectType, nil];
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
@end
