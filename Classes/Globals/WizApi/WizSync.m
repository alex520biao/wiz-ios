//
//  WizSync.m
//  Wiz
//
//  Created by wiz on 12-6-11.
//
//

#import "WizSync.h"
#import "WizSyncData.h"
#import "WizDbManager.h"

@interface WizSync ()
{

    NSMutableArray* downloadArray;
    NSMutableArray* uploadArray;
}
@end

@implementation WizSync
@synthesize apiUrl;
@synthesize token;
@synthesize kbGuid;
- (void) dealloc
{
    [apiUrl release];
    [token release];
    [kbGuid release];
    [downloadArray release];
    [uploadArray release];
    [super dealloc];
}

- (BOOL) isSyncing
{
    for (WizApi* each in [[WizSyncData shareSyncData] workArrayFroGuid:self.kbGuid]) {
        if (each.busy) {
            return YES;
        }
    }
    return NO;
}

- (id) init
{
    self = [super init];
    if (self) {
        downloadArray = [[NSMutableArray alloc] init];
        uploadArray = [[NSMutableArray alloc] init];
        self.token = WizStrName;
        self.kbGuid = WizStrName;
    }
    return self;
}
//

- (BOOL) addSyncToken:(WizApi*)api
{
    api.token = self.token;
    api.kbguid = self.kbGuid;
    api.apiURL = self.apiUrl;
    [[WizSyncData shareSyncData] doWorkBegainApi:api];
    return YES;
}
- (BOOL) isUploadingWizObject:(WizObject*)wizobject
{
    if ([[WizSyncData shareSyncData] isUploadingObject:wizobject]) {
        return YES;
    }
    for (WizObject* each in uploadArray) {
        if ([each.guid isEqualToString:wizobject.guid]) {
            return YES;
        }
    }
    return NO;
}
- (BOOL) uploadWizObject:(WizObject*)object
{
    [uploadArray addObjectUnique:object];
    WizUploadObjet* uploader = [[WizSyncData shareSyncData] uploadData];
    uploader.sourceDelegate = self;
    [self addSyncToken:uploader];
    return [uploader startUpload];
}

- (BOOL) isDownloadingWizobject:(WizObject*)object
{
    if ([[WizSyncData shareSyncData] isDownloadingObject:object]) {
        return YES;
    }
    for (WizObject* each in downloadArray) {
        if ([each.guid isEqualToString:object.guid]) {
            return YES;
        }
    }
    return NO;
 }
- (void) downloadWizObject:(WizObject*)object
{
    [downloadArray addObject:object];
    WizDownloadObject* downloader = [[WizSyncData shareSyncData] downloadData];
    downloader.sourceDelegate = self;
    [self addSyncToken:downloader];
    [downloader startDownload];
}
//
- (BOOL) startSyncInfo
{
    WizSyncInfo* syncInfoer =[[WizSyncData shareSyncData] syncInfoData];
    [self addSyncToken:syncInfoer];
    return [syncInfoer start];
}
//

- (void) resignActive
{
    self.token = @"";
    self.kbGuid = @"";
    [self stopSync];
}
- (WizObject*)nextWizObjectForDownload
{
    WizObject* o = [[downloadArray lastObject] retain];
    [downloadArray removeLastObject];
    return [o autorelease];
}
- (BOOL) willDownloandNext
{
    NSLog(@"download array is %d",[downloadArray count]);
    if ([downloadArray count]) {
        return YES;
    }
    return NO;
}
- (WizObject*)nextWizObjectForUpload
{
    WizObject* o = [[uploadArray lastObject] retain];
    [uploadArray removeLastObject];
    return [o autorelease];
}

- (BOOL) willUploadNext
{
    if ([uploadArray count]) {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void) searchKeywords:(NSString*)keywords  searchDelegate:(id<WizSyncSearchDelegate>)searchDelegate
{
}

- (void) stopSync
{
    [downloadArray removeAllObjects];
    [uploadArray removeAllObjects];
    NSArray* array = [[WizSyncData shareSyncData] workArrayFroGuid:self.kbGuid];
    for (WizApi* each in array) {
        if ([each isKindOfClass:[WizDownloadObject class]]) {
            WizDownloadObject* d = (WizDownloadObject*)each;
            [d stopDownload];
        }
        else if ([each isKindOfClass:[WizUploadObjet class]])
        {
            WizUploadObjet* u = (WizUploadObjet*)each;
            [u startUpload];
        }
    }
}
- (void) uploadAllObject
{
    NSArray* array = [[[WizDbManager shareDbManager] shareDataBase] documentForUpload];
    for (WizDocument* each in array) {
        [each upload];
    }
}
@end
