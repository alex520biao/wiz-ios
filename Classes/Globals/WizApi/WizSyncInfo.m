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
-(void) onDownloadAttachmentList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    self.syncMessage = WizStrSyncingattachmentlist;
    NSArray* attachArr = [self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] attachmentVersion];
    [[[WizDbManager shareDbManager] shareDataBase] updateAttachments:attachArr];
    int64_t newVer = [self newVersion:attachArr];
    if (newVer > oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setAttachmentVersion:newVer+1];
        [self callDownloadAttachmentList:newVer+1];
    }
    else {
        NSArray* ups = [WizDocument documentForUpload];
        for (WizDocument* each in ups) {
            [each upload];
        }
        NSArray* documents = [WizDocument documentsForCache];
        for (WizDocument * each in documents) {
            [each download];
        }
    }
    busy = NO;
    [self.apiManagerDelegate didApiSyncDone:self];
    [self didChangeSyncStatue:WizSyncStatueEndSyncInfo];
    [[WizSettings defaultSettings] setLastSynchronizedDate:[NSDate date]];
}
-(void) onDownloadDocumentList: (id)retObject
{
    if (!self.busy) {
        return ;
    }
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer =[[[WizDbManager shareDbManager] shareDataBase] documentVersion];
	[[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setDocumentVersion:newVer+1];
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
        [WizNotificationCenter postMessageWithName:MessageTypeOfPadTableViewListChangedOrder userInfoObject:nil userInfoKey:nil];
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfPadSyncInfoEnd];
        [self callDownloadAttachmentList:[[[WizDbManager shareDbManager] shareDataBase] attachmentVersion]];
        [self didChangeSyncStatue:WizSyncStatueDownloadAttachmentList];
    }
}
- (void) onAllCategories: (id)retObject
{
    if (!self.busy) {
        return ;
    }
	NSDictionary* obj = retObject;
	//
	// save values returned by getUserInfo into current blog
	NSString* categories = [obj valueForKey:@"categories"];
	categories = [categories stringByAppendingString:@"*/My Mobiles/"];
	//
	NSArray* arrCategory = [categories componentsSeparatedByString:@"*"];
	//
	[[[WizDbManager shareDbManager] shareDataBase] updateLocations:arrCategory];
    [self callDownloadDocumentList:[[[WizDbManager shareDbManager] shareDataBase] documentVersion]];
    [self didChangeSyncStatue:WizSyncStatueDownloadDocumentList];
}
- (void) onPostTagList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    for (WizTag* tag in [[[WizDbManager shareDbManager] shareDataBase] tagsForUpload]) {
        tag.localChanged = 0;
        [tag save];
    }
    [self callAllCategories];
    [self didChangeSyncStatue:WizSyncStatueDownloadFolder];
}
-(void) onAllTags: (id)retObject
{
    if (!self.busy) {
        return ;
    }
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] tagVersion];
    [[[WizDbManager shareDbManager] shareDataBase] updateTags:obj];

    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setTagVersion:newVer+1];
        [self callAllTags:newVer+1];
    }
    else {
        [self callPostTagList:[[[WizDbManager shareDbManager] shareDataBase] tagsForUpload]];
        [self didChangeSyncStatue:WizSyncStatueUploadTags];
    }
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
    if (!self.busy) {
        return ;
    }
	[[[WizDbManager shareDbManager] shareDataBase] clearDeletedGUIDs];
    [self callAllTags:[[[WizDbManager shareDbManager] shareDataBase] tagVersion]];
    [self didChangeSyncStatue:WizSyncStatueDownloadTags];
}
-(void) onDownloadDeletedList: (id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSArray* arr =[ self getArrayFromResponse:retObject];
    int64_t oldVer = [[[WizDbManager shareDbManager] shareDataBase] deletedGUIDVersion];
	int64_t newVer = 0;
	for (NSDictionary* dict in arr)
	{
		NSString* verString = [dict valueForKey:@"version"];
		NSString* guid = [dict valueForKey:@"deleted_guid"];
		NSString* type = [dict valueForKey:@"guid_type"];
		//
		int64_t ver = [verString longLongValue];
		//
		if (ver > newVer)
			newVer = ver;
		//
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
    if (newVer > oldVer) {
        [[[WizDbManager shareDbManager] shareDataBase] setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        [self didChangeSyncStatue:WizSyncStatueUploadloadDeletedItems];
        NSArray* array = [[[WizDbManager shareDbManager] shareDataBase] deletedGUIDsForUpload];
        [self callUploadDeletedGUIDs:array];
    }
}
- (BOOL) start
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    [self didChangeSyncStatue:WizSyncStatueDownloadDeletedItems];
    return [self callDownloadDeletedList:[[[WizDbManager shareDbManager] shareDataBase] deletedGUIDVersion]];
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
