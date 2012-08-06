//
//  WizShareSyncObjectCache.m
//  Wiz
//
//  Created by wiz on 12-7-25.
//
//

#import "WizShareSyncObjectCache.h"

#import "WizSetting.h"
#import "WizSettings.h"
#define SyncDataOfUploader      @"SyncDataOfUploader"
#define SyncDataOfDownloader    @"SyncDataOfDownloader"
#define SyncDataOfRefreshToken  @"SyncDataOfRefreshToken"
#define SyncDataOfSyncInfo      @"SyncDataOfSyncInfo"
#define SyncDataOfSyncSearch    @"SyncDataOfSyncSearch"

#define MaxSyncUploaderCount    1
#define MaxSyncDownloadCount    4

@interface WizShareSyncObjectCache ()
{
    NSMutableDictionary*  shareSyncTools;
    NSMutableArray*     workQueque;
    NSMutableArray*     errorQueque;
    NSMutableArray*     uploadObjectsQueque;
    NSMutableArray*     downadObjectsQueque;
}
@end

@implementation WizShareSyncObjectCache

+ (WizShareSyncObjectCache*) shareSyncObjectCache
{
    @synchronized(self)
    {
        static WizShareSyncObjectCache* shareCache = nil;
        if (shareCache == nil) {
            shareCache = [[WizShareSyncObjectCache alloc] init];
        }
        return shareCache;
    }
}

- (void) dealloc
{
    [shareSyncTools release];
    [workQueque release];
    [errorQueque release];
    [uploadObjectsQueque release];
    [downadObjectsQueque release];
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
        shareSyncTools      = [[NSMutableDictionary dictionary] retain];
        workQueque          = [[NSMutableArray array] retain];
        errorQueque         = [[NSMutableArray array] retain];
        uploadObjectsQueque = [[NSMutableArray array] retain];
        downadObjectsQueque = [[NSMutableArray array] retain];
    }
    return self;
}
- (NSMutableArray*) allUploadTools
{
    NSMutableArray* array = [shareSyncTools valueForKey:SyncDataOfUploader];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:MaxSyncUploaderCount];
        [shareSyncTools setObject:array forKey:SyncDataOfUploader];
    }
    return array;
}

- (NSMutableArray*) allDownloadTools
{
    NSMutableArray* array = [shareSyncTools valueForKey:SyncDataOfDownloader];
    if (array == nil) {
        array = [NSMutableArray arrayWithCapacity:MaxSyncDownloadCount];
        [shareSyncTools setObject:array forKey:SyncDataOfDownloader];
    }
    return array;
}

- (BOOL) isSyncToolOnError:(WizApi*)api
{
    for (WizApi* each in errorQueque) {
        if ([each isEqual:api]) {
            return YES;
        }
    }
    return NO;
}

- (WizUploadObjet*) shareUploadTool
{
    NSMutableArray* allUploadTools = [self allUploadTools];
    for (WizUploadObjet* uploader in allUploadTools) {
        if (!uploader.busy && ![self isSyncToolOnError:uploader]) {
            return uploader;
        }
    }
    if ([allUploadTools count] == MaxSyncUploaderCount) {
        return nil;
    }
    WizUploadObjet* uploadObject = [[WizUploadObjet alloc] init];
    [allUploadTools addObject:uploadObject];
    uploadObject.sourceDelegate = self;
    [uploadObject release];
    return uploadObject;
}

- (WizDownloadObject*) shareDownloadTool
{
    NSMutableArray* allDownloadTools = [self allDownloadTools];
    for (WizDownloadObject* downloader in allDownloadTools)
    {
        for (WizApi* each in errorQueque) {
            NSLog(@"error %@",each);
        }
        if (!downloader.busy && ![self isSyncToolOnError:downloader]) {
          
            downloader.sourceDelegate = self;
            return downloader;
        }
    }
    if ([allDownloadTools count] == MaxSyncDownloadCount) {
        return nil;
    }
    WizDownloadObject* downloader = [[WizDownloadObject alloc] init];
    downloader.sourceDelegate = self;
    [allDownloadTools addObject:downloader];
    [downloader release];
    return  downloader;
}
- (WizRefreshToken*) shareRefreshTokener
{
    WizRefreshToken* data = [shareSyncTools valueForKey:SyncDataOfRefreshToken];
    if (nil == nil || ![data isKindOfClass:[WizRefreshToken class]]) {
        data = [[WizRefreshToken alloc] init];
        [data setAccountURL:[[WizSettings defaultSettings] wizServerUrl]];
        [shareSyncTools setObject:data forKey:SyncDataOfRefreshToken];
        [data release];
    }
    return data;
}
- (WizSyncSearch*) shareSearch
{
    WizSyncSearch* data = [shareSyncTools valueForKey:SyncDataOfSyncSearch];
    NSLog(@"SyncInfo data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizSyncSearch class]]) {
        data = [[WizSyncSearch alloc] init];
        [shareSyncTools setObject:data forKey:SyncDataOfSyncSearch];
        [data release];
    }
    return data;
}
- (WizSyncInfo*) shareSyncInfo
{
    WizSyncInfo* data = [shareSyncTools valueForKey:SyncDataOfSyncInfo];
    NSLog(@"SyncInfo data %@",data);
    if (nil == nil || ![data isKindOfClass:[WizSyncInfo class]]) {
        data = [[WizSyncInfo alloc] init];
        [shareSyncTools setObject:data forKey:SyncDataOfSyncInfo];
        [data release];
    }
    return data;
}

- (BOOL) isDownloadingWizObject:(WizObject*)obj
{
    for (WizDownloadObject* each in [self allDownloadTools]) {
        if ([each isDownloadWizObject:obj]) {
            return YES;
        }
    }
    for (WizObject* each in downadObjectsQueque) {
        if ([each.guid isEqualToString:obj.guid]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isUploadingWizObject:(WizObject*)obj
{
    for (WizUploadObjet* each in [self allUploadTools]) {
        if ([each isUploadWizObject:obj]) {
            return YES;
        }
    }
    for (WizObject* each in uploadObjectsQueque) {
        if ([each.guid isEqualToString:obj.guid]) {
            return YES;
        }
    }
    return NO;
}

- (void) removeSyncingWizObject:(WizObject*)obj
{
    @try {
        NSInteger index = NSNotFound;
        for (int i = 0; i < [downadObjectsQueque count]; i++) {
            WizObject* downloadingObject = [downadObjectsQueque objectAtIndex:i];
            if ([downloadingObject.guid isEqualToString:obj.guid]) {
                index = i ;
                break;
            }
        }
        if (index != NSNotFound) {
            [downadObjectsQueque removeObjectAtIndex:index];
        }
        index = NSNotFound;
        for (int i = 0; i < [uploadObjectsQueque count]; i++) {
            WizObject* uploadingObject = [uploadObjectsQueque objectAtIndex:i];
            if ([uploadingObject.guid isEqualToString:obj.guid]) {
                index = i ;
                break;
            }
        }
        if (index != NSNotFound) {
            [downadObjectsQueque removeObjectAtIndex:index];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

- (void) addShouldDownloadWizObject:(WizObject*)obj
{
    if ([self isDownloadingWizObject:obj]) {
        return;
    } ;
    [downadObjectsQueque addWizObjectUnique:obj];
}

- (void) addShouldUploadWizObject:(WizObject*)obj
{
    if ([self isUploadingWizObject:obj]) {
        return;
    }
    [uploadObjectsQueque addWizObjectUnique:obj];
}
- (WizObject*) nextWizObjectForDownload
{
    if ([downadObjectsQueque count]) {
        WizObject* object = [[downadObjectsQueque lastObject] retain];
        [downadObjectsQueque removeLastObject];
        return [object autorelease];
    }
    return nil;
}

- (BOOL) willDownloandNext
{
    if ([downadObjectsQueque count]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (WizObject*) nextWizObjectForUpload
{
    if ([uploadObjectsQueque count]) {
        WizObject* shouldUploadObject = [[uploadObjectsQueque lastObject] retain];
        [uploadObjectsQueque removeLastObject];
        return [shouldUploadObject autorelease];
    }
    return nil;
}




- (BOOL) willUploadNext
{
    if ([uploadObjectsQueque count])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSArray*) allErrorWizApi
{
    return [[errorQueque copy] autorelease];
}


- (NSArray*) allWorkWizApi
{
    return [[workQueque copy] autorelease];
}

- (void) addErrorWizApi:(WizApi*)errorApi
{
    [errorQueque addObjectUnique:errorApi];
}

- (void) addWorkWizApi:(WizApi*)workApi
{
    [workQueque addObjectUnique:workApi];
}

- (void) clearWorkWizApi:(WizApi*)workApi
{
    WizApi* shouldClearApi = nil;;
    for (WizApi* each in workQueque) {
        if ([each isEqual:workApi]) {
            shouldClearApi = each;
            break;
        }
    }
    if (shouldClearApi) {
        [workQueque removeObject:shouldClearApi];
    }
}

- (void) clearErrorWizApi:(WizApi*)errorApi
{
    WizApi* shouldClearApi = nil;;
    for (WizApi* each in errorQueque) {
        if ([each isEqual:errorQueque]) {
            shouldClearApi = each;
            break;
        }
    }
    if (shouldClearApi) {
        [errorQueque removeObject:shouldClearApi];
    }
}
- (void) clearAllErrorWizApi
{
    [errorQueque removeAllObjects];
}
- (void) clearAllWorkWizApi
{
    [workQueque removeAllObjects];
}
- (void) stopAllWizApi
{
    [workQueque removeAllObjects];
    [errorQueque removeAllObjects];
    [uploadObjectsQueque removeAllObjects];
    [downadObjectsQueque removeAllObjects];
    for (WizUploadObjet* uploader in [self allUploadTools])
    {
        [uploader stopUpload];
    }
    for (WizDownloadObject* downloader in [self allDownloadTools])
    {
        [downloader stopDownload];
    }
    [[self shareSearch] cancel];
    [[self shareRefreshTokener] cancel];
    [self shareRefreshTokener].apiManagerDelegate = nil;
    [[self shareSyncInfo] cancel];
}
@end
