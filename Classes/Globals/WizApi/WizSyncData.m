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
#import "WizNotification.h"
@interface WizSyncData ()
{
    NSMutableDictionary* syncApiData;
    NSMutableArray*      workQueque;
    NSMutableArray*      errorQueque;
}
@end
@implementation WizSyncData

- (void) clearNotWorkingSyncDataFromArray:(NSMutableArray*)array
{
    NSArray* temp = [NSArray arrayWithArray:array];
    for (WizApi* each in temp) {
        if (![self isApiWorking:each]) {
            [array removeObject:each];
        }
    }
}

- (void) clearSyncData
{
    NSArray* syncDatas = [syncApiData allValues];
    for (NSMutableArray* each in syncDatas) {
        [self clearNotWorkingSyncDataFromArray:each];
    }
    NSLog(@"download object count is %d",[[self syncDownloadArray] count]);
    
}
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
    return [self syncApiDataMutableArrayFor:[[WizSyncInfo class] description]] ;
}

- (NSMutableArray*) syncDownloadArray
{
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
        [WizNotificationCenter addObserverWithKey:self selector:@selector(clearSyncData) name:MessageTypeOfMemeoryWarning];
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
- (BOOL) isWizApiWoring:(WizApi*)api
{
    if (NO == api.busy && ![self isApiOnErroring:api]) {
        return NO;
    }
    else
    {
        return YES;
    }
}
- (WizApi*) getCanWorkApiFromArray:(NSMutableArray*)array
{
    for (WizApi*  each in array) {
        if (![self isWizApiWoring:each]) {
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
    NSLog(@"download object count is %d",[[self syncDownloadArray] count]);
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
    NSLog(@"work count %d",[workQueque count]);
    NSLog(@"error count %d",[errorQueque count]);
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

- (NSArray*) errorArrayForGroup:(NSString*)kbguid
{
    NSMutableArray* array = [NSMutableArray array];
    for (WizApi* each in errorQueque) {
        if (each.kbguid != nil && [each.kbguid isEqualToString:kbguid]) {
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
