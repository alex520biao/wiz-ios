//
//  Wizself.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncData.h"
#import "WizSettings.h"
#import "WizDbManager.h"
#define selfOfUploader      @"selfOfUploader"
#define selfOfDownloader    @"selfOfDownloader"
#define selfOfRefreshToken  @"selfOfRefreshToken"
#define selfOfSyncInfo      @"selfOfSyncInfo"

@implementation NSMutableDictionary (Wizself)

- (WizUploadObjet*) shareUploader
{
    id data = [self valueForKey:selfOfUploader];
    if (nil == data || ![data isKindOfClass:[WizUploadObjet class]]) {
        data = [[WizUploadObjet alloc] init];
        [self setObject:data forKey:selfOfUploader];
        [data release];
    }
    return data;
}
- (WizDownloadObject*) shareDownloader
{
    id data = [self valueForKey:selfOfDownloader];
    if (nil == data || ![data isKindOfClass:[WizDownloadObject class]]) {
        data = [[WizDownloadObject alloc] init];
        [self setObject:data forKey:selfOfDownloader];
        [data release];
    }
    return data;
}
- (WizRefreshToken*) shareRefreshTokener
{
    WizRefreshToken* data = [self valueForKey:selfOfRefreshToken];
    NSLog(@"refresh data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] init];
        [data setAccountURL:[[WizSettings defaultSettings] wizServerUrl]];
        [self setObject:data forKey:selfOfRefreshToken];
        [data release];
    }
    return data;
}
- (WizSyncInfo*) shareSyncInfo
{
    WizSyncInfo* data = [self valueForKey:selfOfSyncInfo];
    NSLog(@"SyncInfo data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizSyncInfo class]]) {
        data = [[WizSyncInfo alloc] init];
        [self setObject:data forKey:selfOfSyncInfo];
        [data setDbDelegate:[WizDbManager shareDbManager]];
        [data release];
    }
    return data;
}
- (void) removeShareUploder
{
    [self removeObjectForKey:selfOfUploader];
}
- (void) removeShareDownload
{
    [self removeObjectForKey:selfOfDownloader];
}
- (void) removeShareRefreshTokener
{
    [self removeObjectForKey:selfOfRefreshToken];
}
- (void) removeShareSyncInfo
{
    [self removeObjectForKey:selfOfSyncInfo];
}
@end
