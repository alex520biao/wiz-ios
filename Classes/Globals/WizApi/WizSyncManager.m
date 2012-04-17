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
#define SyncDataOfUploader      @"SyncDataOfUploader"
#define SyncDataOfRefreshToken  @"SyncDataOfRefreshToken"
//
#define UploadObjectGUID        @"UploadObjectGUID"
#define UploadObjectType        @"UploadObjectType"
//
#define SyncDataOfToken         @"SyncDataOfToken"
#define SyncDataOfKbGuid        @"SyncDataOfKbGuid"
@interface WizSyncManager ()
{
    NSMutableArray* downloadQueque;
    NSMutableArray* uploadQueque;
    NSMutableArray* errorQueque;
    NSMutableDictionary* syncData;
    BOOL isRefreshToken;
}
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

- (id) init
{
    self = [super init];
    if (self) {
        syncData = [[NSMutableDictionary alloc] init];
        uploadQueque = [[NSMutableArray alloc] init];
        downloadQueque = [[NSMutableArray alloc] init];
        errorQueque = [[NSMutableArray alloc] init];
    }
    return self;
}
- (WizUploadObjet*) shareUploader
{
    id data = [syncData valueForKey:SyncDataOfUploader];
    if (nil == nil || [data isKindOfClass:[WizUploadObjet class]]) {
        data = [[WizUploadObjet alloc] initWithAccount:self.accountUserId password:nil];
        [syncData setObject:data forKey:SyncDataOfUploader];
        [data release];
    }
    return data;
}
- (WizRefreshToken*) shareRefreshTokener
{
    id data = [syncData valueForKey:SyncDataOfRefreshToken];
    if (nil == nil || [data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] initWithAccount:self.accountUserId password:nil];
        [syncData setObject:data forKey:SyncDataOfUploader];
        [data release];
    }
    return data;
}
- (void) removeUploadObject:(NSString*)_guid
{
    NSDictionary* dic = nil;
    for (NSDictionary* each in uploadQueque) {
        NSString* guid = [each valueForKey:UploadObjectGUID];
        if (nil != guid && [guid isEqualToString:_guid]) {
            dic = each;
        }
    }
    if (nil != dic) {
        [uploadQueque removeObject:dic];
    }
}
- (void) restartSync
{
    for (id each in errorQueque) {
        if ([each isKindOfClass:[WizUploadObjet class]]) {
            [self startUpload];
        }
    }
}
- (void) didRefreshToken:(NSNotification*)nc
{
    [WizNotificationCenter removeObserverForRefreshToken:self];
    isRefreshToken = NO;
    NSDictionary* keys = [WizNotificationCenter getRefreshTokenDicFromNc:nc];
    NSString* token = [keys valueForKey:@"token"];
    NSString* kbGuid = [keys valueForKey:@"kb_guid"];
    [syncData setObject:token forKey:SyncDataOfToken];
    [syncData setObject:kbGuid forKey:SyncDataOfKbGuid];
    [self restartSync];
}
- (void) refreshToken
{
    WizRefreshToken* re = [self shareRefreshTokener];
    if (isRefreshToken) {
        return;
    }
    isRefreshToken = YES;
    [WizNotificationCenter addObserverForRefreshToken:self selector:@selector(didRefreshToken:)];
    [re refresh];
}
- (BOOL) addSyncToken:(WizApi*)api
{
    NSString* token = [syncData valueForKey:SyncDataOfToken];
    if (nil == token || [token isEqualToString:@""]) {
        [errorQueque addObject:api];
        [self refreshToken];
        return NO;
    }
    NSString* kbGuid = [syncData valueForKey:SyncDataOfKbGuid];
    api.token = token;
    api.kbguid = kbGuid;
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
    NSString* type = [obj valueForKey:UploadObjectType];
    NSString* guid = [obj valueForKey:UploadObjectGUID];

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
    if (ret) {
        [WizNotificationCenter addObserverForUploadDone:self selector:@selector(uploadNext:)];
    }
    return ret;
}
- (BOOL) uploadNext:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter uploadGuidFromNc:nc];
    [self removeUploadObject:guid];
    [WizNotificationCenter removeObserverForUploadDone:self];
    return [self startUpload];
}

- (BOOL) uploadDocument:(NSString*)documentGUID
{
    NSDictionary* doc = [NSDictionary dictionaryWithObjectsAndKeys:documentGUID,UploadObjectGUID,WizDocumentKeyString, UploadObjectType, nil];
    [uploadQueque addObject:doc];
    return [self startUpload];
}
@end
