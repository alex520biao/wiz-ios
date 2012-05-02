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

@implementation WizSyncInfo
@synthesize busy;
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
	[self.dbDelegate updateDocuments:obj];
}
//
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
	[self.dbDelegate updateDocuments:obj];
}
//
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
	[self.dbDelegate updateDocuments:obj];
}
-(void) onDownloadAttachmentList:(id)retObject {
    NSArray* attachArr = [self getArrayFromResponse:retObject];
    int64_t oldVer = [self.dbDelegate attachmentVersion];
    [self.dbDelegate updateAttachments:attachArr];
    int64_t newVer = [self newVersion:attachArr];
    if (newVer > oldVer) {
        [self.dbDelegate setAttachmentVersion:newVer+1];
        [self callDownloadAttachmentList:newVer+1];
    }
    else {
        NSArray* ups = [WizDocument documentForUpload];
        for (WizDocument* each in ups) {
            [[WizSyncManager shareManager] uploadDocument:each.guid];
        }
        NSArray* downs = [WizDocument recentDocuments];
        for (WizDocument* each in downs) {
            NSLog(@"attachments count is %d",each.attachmentCount);
            if (each.attachmentCount > 0) {
                NSArray* attachments = [each attachments];
                NSLog(@"attachments count is %d",[attachments count]);
                for (WizAttachment* attach in attachments) {
                    [[WizSyncManager shareManager] downloadAttachment:attach.guid];
                }
            }
            
        }
    }
}
-(void) onDownloadDocumentList: (id)retObject
{
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer =[self.dbDelegate documentVersion];
	[self.dbDelegate updateDocuments:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [self.dbDelegate setDocumentVersion:newVer+1];
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        [self callDownloadAttachmentList:[self.dbDelegate attachmentVersion]];
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
	[self.dbDelegate updateLocations:arrCategory];
    [self callDownloadDocumentList:[self.dbDelegate documentVersion]];
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
    int64_t oldVer = [self.dbDelegate tagVersion];
    [self.dbDelegate updateTags:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [self.dbDelegate setTageVersion:newVer+1];
        [self callAllTags:newVer+1];
    }
    else {
        [self callPostTagList:[self.dbDelegate tagsForUpload]];
    }
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
	[self.dbDelegate clearDeletedGUIDs];
    [self callAllTags:[self.dbDelegate tagVersion]];
}
-(void) onDownloadDeletedList: (id)retObject
{
    NSArray* arr =[ self getArrayFromResponse:retObject];
    int64_t oldVer = [self.dbDelegate deletedGUIDVersion];
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
            [WizDocument deleteDocument:guid];
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
        [self.dbDelegate setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        NSArray* array = [self.dbDelegate deletedGUIDsForUpload];
        NSLog(@"%@",array);
        [self callUploadDeletedGUIDs:[self.dbDelegate deletedGUIDsForUpload]];
    }
}
- (BOOL) startSync
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    return [self callDownloadDeletedList:[self.dbDelegate deletedGUIDVersion]];
}
@end
