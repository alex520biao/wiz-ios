//
//  WizSyncInfo.m
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncInfo.h"
#import "WizDbManager.h"
#import "WizGlobalData.h"
#import "WizSyncManager.h"
#import "WizNotification.h"
#import "WizSettings.h"

static NSString* WizSyncVersionDocument     = @"document_version";
static NSString* WizSyncVersionAttachment   = @"attachment_version";
static NSString* WizSyncVersionTag          = @"tag_version";
static NSString* WizSyncVersionDeleted      = @"deleted_version";

@interface WizSyncInfo ()
{
    NSInteger  documentVersion;
    NSInteger attachmentVersion;
    NSInteger deletedVersion;
    NSInteger tagVersion;
}
@end

@implementation WizSyncInfo
@synthesize dbDelegate;

- (void) dealloc
{
    [dbDelegate release];
    [super dealloc];
}

- (void) onCallGetUserInfo:(id)retObject
{

}
- (int64_t) newVersion:(NSArray*)array
{
    int64_t newVer = 0;
    for (NSDictionary* dict in array)
    {
        NSString* verString = [dict valueForKey:@"version"];
        
        int64_t ver = [verString longLongValue];
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    return newVer;
}
- (NSArray*) getArrayFromResponse:(id)retObject
{
    NSArray* obj = nil;
    if (![retObject isKindOfClass:[NSArray class]]) {
        return nil;
    }
    obj = (NSArray*)retObject;
    if (0 == [obj count]) {
        return nil;
    }
    return obj;
}
-(void) onDocumentsByCategory: (id)retObject
{
	NSArray* obj = retObject;
	[[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
}
//
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
	[[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
}
//
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
	[[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
}

- (void) syncEnd
{
     busy = NO;
    [self.apiManagerDelegate didApiSyncDone:self];
    [self didChangeSyncStatue:WizSyncStatueEndSyncInfo];
    [[WizSettings defaultSettings] setLastSynchronizedDate:[NSDate date]];
}
-(void) onDownloadAttachmentList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    self.syncMessage = WizStrSyncingattachmentlist;
    NSArray* attachArr = [self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] attachmentVersion];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
         [[[WizDbManager shareDbManager] shareDataBase] updateAttachments:attachArr];
    });
    int64_t newVer = [self newVersion:attachArr];
    if (newVer >= oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setAttachmentVersion:newVer+1];
        [self callDownloadAttachmentList:newVer+1];
    }
    else
    {
        if (newVer == 0 && attachmentVersion !=0) {
            [[[WizDbManager shareDbManager] shareDataBase] setAttachmentVersion:attachmentVersion];
        }
        [self uploadAllDocumentsAndAttachments];
    }
   
    
}
- (void) uploadAllDocumentsAndAttachments
{
    [self syncEnd];
    NSArray* ups = [WizDocument documentForUpload];
    for (WizDocument* each in ups) {
        [each upload];
    }
    NSArray* documents = [WizDocument documentsForCache];
    if ([documents count] > 30) {
        documents = [documents subarrayWithRange:NSMakeRange(0, 30)];
    }
    for (WizDocument * each in documents) {
        [each download];
    }
}
- (BOOL) callDownloadAttachmentList:(int64_t)version
{
    NSLog(@"server attachment %d local %lld",attachmentVersion, version);
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
    [WizNotificationCenter postMessageWithName:MessageTypeOfPadTableViewListChangedOrder userInfoObject:nil userInfoKey:nil];
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfPadSyncInfoEnd];
    [self didChangeSyncStatue:WizSyncStatueDownloadAttachmentList];
    if (version < attachmentVersion) {
        return [super callDownloadAttachmentList:version];
    }
    else
    {
        [self uploadAllDocumentsAndAttachments];
        return YES;
    }
}

-(void) onDownloadDocumentList: (id)retObject
{
    if (!self.busy) {
        return ;
    }
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer =[[[WizDbManager shareDbManager] shareDataBase] documentVersion];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
    });
	
    int64_t newVer = [self newVersion:obj];
    if (newVer >= oldVer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[[WizDbManager shareDbManager] shareDataBase] setDocumentVersion:newVer+1];
        });
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        if (newVer == 0 && documentVersion!=0) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [[[WizDbManager shareDbManager] shareDataBase] setDocumentVersion:documentVersion];
            });
        }
        [self callDownloadAttachmentList:[[[WizDbManager shareDbManager] shareDataBase] attachmentVersion]];

    }
}

- (BOOL) callDownloadDocumentList:(int64_t)version
{
    NSLog(@"server document %d local %lld",documentVersion, version);

    if (version < documentVersion) {
        [self didChangeSyncStatue:WizSyncStatueDownloadDocumentList];
        return [super callDownloadDocumentList:version];
    }
    else
    {
        return [self callDownloadAttachmentList:[[[WizDbManager shareDbManager] shareDataBase] attachmentVersion]];
    }
}
- (void) onPostTagList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (WizTag* tag in [[[WizDbManager shareDbManager] shareDataBase] tagsForUpload]) {
            tag.localChanged = 0;
            [tag save];
        }
    });
    [self callDownloadDocumentList:[[[WizDbManager shareDbManager] shareDataBase] documentVersion]];
}
-(void) onAllTags: (id)retObject
{
    if (!self.busy) {
        return ;
    }
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] tagVersion];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[[WizDbManager shareDbManager] shareDataBase] updateTags:obj];
    });
    int64_t newVer = [self newVersion:obj];
    NSLog(@"tag version is  %lld",newVer);
    if (newVer >= oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setTagVersion:newVer+1];
        [self callAllTags:newVer+1];
    }
    else {
        if (newVer == 0 && tagVersion!=0) {
            [[[WizDbManager shareDbManager] shareDataBase] setTagVersion:tagVersion];
        }
        [self uploadAllTags];
    }
}
- (BOOL) uploadAllTags
{
    NSArray* tagsForUpload = [[[WizDbManager shareDbManager] shareDataBase] tagsForUpload];
    if ([tagsForUpload count]) {
        [self didChangeSyncStatue:WizSyncStatueUploadTags];
        return [self callPostTagList:tagsForUpload];
    }
    else
    {
        return  [self callDownloadDocumentList:[[[WizDbManager shareDbManager] shareDataBase] documentVersion]];
    }
}

- (BOOL) callAllTags:(int64_t)version
{
    NSLog(@"server tag is %d  local %lld",tagVersion, version);
    if (version < tagVersion) {
         [self didChangeSyncStatue:WizSyncStatueDownloadTags];
        return [super callAllTags:version];
    }
    else
    {
        return [self uploadAllTags];
    }
}

-(void) onUploadDeletedGUIDs: (id)retObjec
{
    if (!self.busy) {
        return ;
    }
	[[[WizDbManager shareDbManager] shareDataBase] clearDeletedGUIDs];
    [self callAllTags:[[[WizDbManager shareDbManager] shareDataBase] tagVersion]];
}

-(void) onDownloadDeletedList: (id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSArray* arr =[self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] deletedGUIDVersion];
	int64_t newVer = [self newVersion:arr];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (NSDictionary* dict in arr)
        {
            NSString* guid = [dict valueForKey:@"deleted_guid"];
            NSString* type = [dict valueForKey:@"guid_type"];
            
            if ([type isEqualToString:@"document"])
            {
                WizDocument* doc = [WizDocument documentFromDb:guid];
                if (nil == doc) {
                    continue;
                }
                [WizDocument deleteDocument:doc];
            }
            else if ([type isEqualToString:@"tag"])
            {
                [WizTag deleteTag:guid];
            }
            if ([type isEqualToString:@"attachment"])
            {
                [WizAttachment deleteAttachment:guid];
            }
        }
    });
	
    if (newVer >= oldVer)
    {
        [[[WizDbManager shareDbManager] shareDataBase] setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        [self uploadDeletedGuids];
    }
}

- (BOOL) uploadDeletedGuids
{
    if (!self.busy) {
        return NO;
    }
    [self didChangeSyncStatue:WizSyncStatueUploadloadDeletedItems];
    NSArray* array = [[[WizDbManager shareDbManager] shareDataBase] deletedGUIDsForUpload];
    if ([array count]) {
        return [self callUploadDeletedGUIDs:array];
    }
    else
    {
        return [self callAllTags:[[[WizDbManager shareDbManager] shareDataBase] tagVersion]];
    }
}

- (BOOL) callDownloadDeletedList:(int64_t)version
{
    if (!self.busy) {
        return NO;
    }
    NSLog(@"server deleted Version is %d  local is %lld",deletedVersion, version);
    if (version <  deletedVersion)
    {
        [self didChangeSyncStatue:WizSyncStatueDownloadDeletedItems];
        return [super callDownloadDeletedList:version];
    }
    else
    {
        return [self uploadDeletedGuids];
    }
}
- (void) onGetAllObjectVersion:(id)retObject
{
    if ([retObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* versionDic = (NSDictionary*)retObject;
        //local version is always plus 1
        documentVersion     = [[versionDic valueForKey:WizSyncVersionDocument]      integerValue]+1;
        attachmentVersion   = [[versionDic valueForKey:WizSyncVersionAttachment]    integerValue]+1;
        tagVersion          = [[versionDic valueForKey:WizSyncVersionTag]           integerValue]+1;
        deletedVersion      = [[versionDic valueForKey:WizSyncVersionDeleted]       integerValue]+1;
    }
    NSLog(@"%d %d %d %d",documentVersion, attachmentVersion, tagVersion, deletedVersion);
    [self callDownloadDeletedList:[[[WizDbManager shareDbManager] shareDataBase] deletedGUIDVersion]];
}
- (BOOL) start
{
    if (self.busy)
    {
        return NO;
    }
    busy = YES;

    return [self callGetAllObjectVersion];
}
- (void) onError:(id)retObject
{
    [self didChangeSyncStatue:WizSyncStatueError];
    busy = NO;
    if (attempts) {
        attempts--;
        [super onError:retObject];
    }
    else {
        attempts = WizNetWorkMaxAttempts;
        NSError* error = (NSError*) retObject;
        if ([error.domain isEqualToString:WizErrorDomain] && error.code == NSUserCancelError) {
            return;
        }
        [WizGlobals reportError:retObject];
    }
}
- (void) cancel
{
    [super cancel];
    busy = NO;
}
@end
