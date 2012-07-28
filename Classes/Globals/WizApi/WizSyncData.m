//
//  WizSyncData.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncData.h"
#import "WizSettings.h"
#import "WizDbManager.h"
#import "WizSyncSearch.h"
#define SyncDataOfUploader      @"SyncDataOfUploader"
#define SyncDataOfDownloader    @"SyncDataOfDownloader"
#define SyncDataOfRefreshToken  @"SyncDataOfRefreshToken"
#define SyncDataOfSyncInfo      @"SyncDataOfSyncInfo"
#define SyncDataOfSyncSearch    @"SyncDataOfSyncSearch"

#define MaxSyncUploaderCount    3
#define MaxSyncDownloadCount    4

@implementation NSMutableDictionary (Wizself)
- (NSMutableArray*) allUploaders
{
    NSMutableArray* array = [self valueForKey:SyncDataOfUploader];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:MaxSyncUploaderCount];
        [self setObject:array forKey:SyncDataOfUploader];
    }
    return array;
}
- (WizUploadObjet*) shareUploader
{
    return nil;
}
- (WizDownloadObject*) shareDownloader
{
    id data = [self valueForKey:SyncDataOfDownloader];
    if (nil == data || ![data isKindOfClass:[WizDownloadObject class]]) {
        data = [[WizDownloadObject alloc] init];
        [self setObject:data forKey:SyncDataOfDownloader];
        [data release];
    }
    return data;
}
- (WizRefreshToken*) shareRefreshTokener
{
    WizRefreshToken* data = [self valueForKey:SyncDataOfRefreshToken];
    if (nil == nil || ![data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] init];
        [data setAccountURL:[[WizSettings defaultSettings] wizServerUrl]];
        [self setObject:data forKey:SyncDataOfRefreshToken];
        [data release];
    }
    return data;
}
- (WizSyncSearch*) shareSearch
{
    WizSyncSearch* data = [self valueForKey:SyncDataOfSyncSearch];
    NSLog(@"SyncInfo data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizSyncSearch class]]) {
        data = [[WizSyncSearch alloc] init];
        [self setObject:data forKey:SyncDataOfSyncSearch];
        [data release];
    }
    return data;
}
- (WizSyncInfo*) shareSyncInfo
{
    WizSyncInfo* data = [self valueForKey:SyncDataOfSyncInfo];
    NSLog(@"SyncInfo data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizSyncInfo class]]) {
        data = [[WizSyncInfo alloc] init];
        [self setObject:data forKey:SyncDataOfSyncInfo];
        [data release];
    }
    return data;
}
- (void) removeShareUploder
{
    [self removeObjectForKey:SyncDataOfUploader];
}
- (void) removeShareDownload
{
    [self removeObjectForKey:SyncDataOfDownloader];
}
- (void) removeShareRefreshTokener
{
    [self removeObjectForKey:SyncDataOfRefreshToken];
}
- (void) removeShareSyncInfo
{
    [self removeObjectForKey:SyncDataOfSyncInfo];
}
@end
