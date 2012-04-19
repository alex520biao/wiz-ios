//
//  WizSyncInfo.m
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncInfo.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizSyncManager.h"

@implementation WizSyncInfo
- (void) onCallGetUserInfo:(id)retObject
{
    NSDictionary* dic = retObject;
    NSNumber* trafficLimit = [dic objectForKey:@"traffic_limit"];
    NSNumber* trafficUsage = [dic objectForKey:@"traffic_usage"];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setUserTrafficLimit:[trafficLimit intValue]];
    [index setuserTrafficUsage:[trafficUsage intValue]];
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
    //
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
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index updateDocuments:obj];
}
//
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index updateDocuments:obj];
}
//
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index updateDocuments:obj];
}
-(void) onDownloadAttachmentList:(id)retObject {
    NSArray* attachArr = [self getArrayFromResponse:retObject];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer = [index attachmentVersion];
    [index updateAttachementList:attachArr];
    int64_t newVer = [self newVersion:attachArr];
    if (newVer > oldVer) {
        [index setAttachmentVersion:newVer+1];
        [self callDownloadAttachmentList:newVer+1];
    }
else {
    NSArray* array = [index documentForDownload];
    for(WizDocument* each in array)
    {
        [[WizSyncManager shareManager] downloadDocument:each.guid];
    }
    array = [index documentForUpload];
    for(WizDocument* each in array)
    {
        [[WizSyncManager shareManager] uploadDocument:each.guid];
    }}
}
-(void) onDownloadDocumentList: (id)retObject
{
	NSArray* obj = [self getArrayFromResponse:retObject];
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer =[index documentVersion];
	[index updateDocuments:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [index setDocumentVersion:newVer+1];
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        [self callDownloadAttachmentList:[index attachmentVersion]];
    }
}
- (void) onAllCategories: (id)retObject
{
	NSDictionary* obj = retObject;
	//
	// save values returned by getUserInfo into current blog
	NSString* categories = [obj valueForKey:@"categories"];
	categories = [categories stringByAppendingString:@"*/My Mobiles/"];
	//
	NSArray* arrCategory = [categories componentsSeparatedByString:@"*"];
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index updateLocations:arrCategory];
    [self callDownloadDocumentList:[index documentVersion]];
}
- (void) onPostTagList:(id)retObject
{
    //
    //clear
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [self callAllCategories];
}
-(void) onAllTags: (id)retObject
{
	NSArray* obj = [self getArrayFromResponse:retObject];
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer = [index tagVersion];
    [index updateTags:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [index setTageVersion:newVer+1];
        [self callAllTags:newVer+1];
    }
    else {
        [self callPostTagList:[index tagsWillPostList]];
    }
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	[index clearDeletedGUIDs];
    [self callAllTags:[index tagVersion]];
}
-(void) onDownloadDeletedList: (id)retObject
{
    NSArray* arr =[ self getArrayFromResponse:retObject];
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer = [index deletedGUIDVersion];
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
			[index deleteDocument:guid];
		}
		else if ([type isEqualToString:@"tag"])
		{
			[index deleteTag:guid];
		}
        if ([type isEqualToString:@"attachment"])
        {
            [index deleteAttachment:guid];
        }
	}
    if (newVer > oldVer) {
        [index setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        [self callUploadDeletedGUIDs:[index deletedGUIDsForUpload]];
    }
}
- (BOOL) startSync
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    return [self callDownloadDeletedList:[index deletedGUIDVersion]];
}
@end
