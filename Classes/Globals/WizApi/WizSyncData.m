//
//  WizSyncData.m
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import "WizSyncData.h"
#import "WizSetting.h"
#import "WizSettings.h"
#import "WizDbManager.h"
@interface WizSyncData ()
{
    NSMutableDictionary* syncApiData;
    NSMutableArray*      workQueque;
    NSMutableArray*      errorQueque;
}
@end
@implementation WizSyncData

+ (WizSyncData*) shareSyncData
{
    static WizSyncData* share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[WizSyncData alloc] init];
    });
    return share;
}

- (void) dealloc
{
    [syncApiData release];
    [workQueque release];
    [errorQueque release];
    [super dealloc];
}

- (NSMutableArray*) syncApiDataMutableArrayFor:(NSString*)apiClass
{
    NSMutableArray* array = [syncApiData objectForKey:apiClass];
    if (!array) {
        array = [NSMutableArray array];
        [syncApiData setObject:array forKey:apiClass];
    }
    return array;
}

- (NSMutableArray*) syncInfoArray
{
    NSLog(@"des %@",[[WizSyncInfo class] description]);
    return [self syncApiDataMutableArrayFor:[[WizSyncInfo class] description]] ;
}

- (NSMutableArray*) syncDownloadArray
{
    NSLog(@"des %@",[[WizDownloadObject class] description]);
    return [self syncApiDataMutableArrayFor:[[WizDownloadObject class] description]] ;
}

- (NSMutableArray*) syncUploadArray
{
    return [self syncApiDataMutableArrayFor:[[WizUploadObjet class] description]] ;
}

- (NSMutableArray*) syncRefreshArray
{
    return [self syncApiDataMutableArrayFor:[[WizRefreshToken class] description]] ;
}

- (id) init
{
    self = [super init];
    if (self) {
        syncApiData = [[NSMutableDictionary alloc] init];
        workQueque = [[NSMutableArray alloc] init];
        errorQueque = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL) isApiWorking:(WizApi *)api
{
   NSInteger index = [workQueque indexOfObject:api];
    if (index == NSNotFound) {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL) isApiOnErroring:(WizApi *)api
{
    NSInteger index = [errorQueque indexOfObject:api];
    if (NSNotFound == index) {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (WizApi*) getCanWorkApiFromArray:(NSMutableArray*)array
{
    for (WizSyncInfo*  each in array) {
        if (NO == each.busy && ![self isApiOnErroring:each]) {
            return each;
        }
    }
    return nil;
}
- (WizSyncInfo*) syncInfoData
{
    WizSyncInfo* data = (WizSyncInfo*)[self getCanWorkApiFromArray:[self syncInfoArray]];
    if (!data) {
        data = [[WizSyncInfo alloc] init];
        [[self syncInfoArray] addObject:data];
        data.dbDelegate = [[WizDbManager shareDbManager] shareDataBase];
        [data release];
    }
    return data;
}
- (WizUploadObjet*) uploadData
{
    WizUploadObjet* data = (WizUploadObjet*)[self getCanWorkApiFromArray:[self syncUploadArray]];
    if (!data) {
        data = [[WizUploadObjet alloc] init];
        [[self syncUploadArray] addObject:data];
        [data release];
    }
    return data;
}
- (WizDownloadObject*) downloadData
{
    WizDownloadObject* data = (WizDownloadObject*)[self getCanWorkApiFromArray:[self syncDownloadArray]];
    if (!data) {
        data = [[WizDownloadObject alloc] init];
        [[self syncDownloadArray] addObject:data];
        [data release];
    }
    return data;
}
- (WizRefreshToken*) refreshData
{
    WizRefreshToken* data = (WizRefreshToken*)[self getCanWorkApiFromArray:[self syncRefreshArray]];
    if (!data) {
        data = [[WizRefreshToken alloc] init];
        data.accountURL = [[WizSettings defaultSettings] wizServerUrl];
        [[self syncRefreshArray] addObject:data];
        [data release];
    }
    return data;
}
- (void) doWorkBegainApi:(WizApi *)api
{
    [workQueque addObjectUnique:api];
}
- (void) doWorkEndApi:(WizApi *)api
{
    [workQueque removeObject:api];
}

- (void) doErrorBegainApi:(WizApi *)api
{
    [errorQueque addObjectUnique:api];
}

- (void) doErrorEndApi:(WizApi *)api
{
    [errorQueque removeObject:api];
}
- (NSArray*) workArrayFroGuid:(NSString *)guid
{
    NSMutableArray* array = [NSMutableArray array];
    for (WizApi* each in workQueque) {
        if (each.kbguid != nil && [each.kbguid isEqualToString:guid]) {
            [array addObject:each];
        }
    }
    return array;
}
- (BOOL) isDownloadingObject:(WizObject *)object
{
    for (WizDownloadObject* each in [self syncDownloadArray]) {
        if ([each isDownloadWizObject:object]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isUploadingObject:(WizObject *)object
{
    for (WizUploadObjet* each in [self syncUploadArray]) {
        if ([each isUploadWizObject:object])
        {
            return YES;
        }
    }
    return NO;
}
- (NSArray*)errorQueque
{
    return [[errorQueque copy] autorelease];
}
@end
