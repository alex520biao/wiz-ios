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
#import "WizFileManager.h"
#import "WizDocument.h"
#import "WizGlobalError.h"
#import "WizTag.h"
#import "WizAccountManager.h"
#import "WizDataBase.h"

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
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	[dataBase updateDocuments:obj];
}
//
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	[dataBase updateDocuments:obj];
}
//
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	[dataBase updateDocuments:obj];
}
-(void) onDownloadAttachmentList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
    self.syncMessage = WizStrSyncingattachmentlist;
    NSArray* attachArr = [self getArrayFromResponse:retObject];
    int64_t oldVer = [dataBase attachmentVersion];
    [dataBase updateAttachments:attachArr];
    int64_t newVer = [self newVersion:attachArr];
    if (newVer > oldVer) {
        [dataBase setAttachmentVersion:newVer+1];
        [self callDownloadAttachmentList:newVer+1];
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
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer =[dataBase documentVersion];
	[dataBase updateDocuments:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [dataBase setDocumentVersion:newVer+1];
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
        [WizNotificationCenter postMessageWithName:MessageTypeOfPadTableViewListChangedOrder userInfoObject:nil userInfoKey:nil];
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfPadSyncInfoEnd];
        [self callDownloadAttachmentList:[dataBase attachmentVersion]];
        [self didChangeSyncStatue:WizSyncStatueDownloadAttachmentList];
    }
}
- (void) onAllCategories: (id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	NSDictionary* obj = retObject;
	//
	// save values returned by getUserInfo into current blog
	NSString* categories = [obj valueForKey:@"categories"];
	categories = [categories stringByAppendingString:@"*/My Mobiles/"];
	//
	NSArray* arrCategory = [categories componentsSeparatedByString:@"*"];
	//
	[dataBase updateLocations:arrCategory];
    [self callDownloadDocumentList:[dataBase documentVersion]];
    [self didChangeSyncStatue:WizSyncStatueDownloadDocumentList];
}
- (void) onPostTagList:(id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
    for (WizTag* tag in [dataBase tagsForUpload]) {
        [dataBase setTagLocalChanged:tag.guid changed:NO];
    }
    [self callAllCategories];
    [self didChangeSyncStatue:WizSyncStatueDownloadFolder];
}
-(void) onAllTags: (id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer = [dataBase tagVersion];
    [dataBase updateTags:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [dataBase setTagVersion:newVer+1];
        [self callAllTags:newVer+1];
    }
    else {
        NSArray* array = [dataBase tagsForUpload];
        if (array == nil || [array count] ==0) {
            [self callAllCategories];
        }
        else
        {
            [self callPostTagList:[dataBase tagsForUpload]];
            [self didChangeSyncStatue:WizSyncStatueUploadTags];
        }
    }
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
	[dataBase clearDeletedGUIDs];
    [self callAllTags:[dataBase tagVersion]];
    [self didChangeSyncStatue:WizSyncStatueDownloadTags];
}
-(void) onDownloadDeletedList: (id)retObject
{
    if (!self.busy) {
        return ;
    }
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
    NSArray* arr =[ self getArrayFromResponse:retObject];
    int64_t oldVer = [dataBase deletedGUIDVersion];
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
            if ([dataBase deleteDocument:guid]) {
                [[WizFileManager shareManager] removeObjectPath:guid];
                [WizNotificationCenter postDeleteDocumentMassage:[[[WizDocument alloc] init] autorelease]];
            }
        }
        
		else if ([type isEqualToString:@"tag"])
		{
            [dataBase deleteTag:guid];
		}
        if ([type isEqualToString:@"attachment"])
        {
            [dataBase deleteAttachment:guid];
        }
	}
    if (newVer > oldVer) {
        [dataBase setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        [self didChangeSyncStatue:WizSyncStatueUploadloadDeletedItems];
        NSArray* array = [dataBase deletedGUIDsForUpload];
        [self callUploadDeletedGUIDs:array];
    }
}
- (BOOL) start
{
    if (self.busy)
    {
        return NO;
    }
    busy = YES;
    [self didChangeSyncStatue:WizSyncStatueDownloadDeletedItems];
    NSString* activeAccountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizDataBase* dataBase = [[WizDbManager shareDbManager] getWizDataBase:activeAccountUserId groupId:self.kbguid];
    return [self callDownloadDeletedList:[dataBase deletedGUIDVersion]];
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
        [self.apiManagerDelegate didApiSyncError:self error:[WizGlobalError canNotResloceError]];
    }
}
- (void) cancel
{
    [super cancel];
    busy = NO;
}
@end
