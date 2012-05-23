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
    self.syncMessage = WizStrSyncingattachmentlist;
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
            [each upload];
        }
        NSArray* documents = [WizDocument documentsForCache];
        for (WizDocument * each in documents) {
            [each download];
        }
    }
    busy = NO;
    self.syncMessage = WizSyncEndMessage;
}
-(void) onDownloadDocumentList: (id)retObject
{
    self.syncMessage = WizStrSyncingnoteslist;
	NSArray* obj = [self getArrayFromResponse:retObject];
    int64_t oldVer =[self.dbDelegate documentVersion];
	[self.dbDelegate updateDocuments:obj];
    int64_t newVer = [self newVersion:obj];
    if (newVer > oldVer) {
        [self.dbDelegate setDocumentVersion:newVer+1];
        [self callDownloadDocumentList:newVer+1];
    }
    else {
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
        [self callDownloadAttachmentList:[self.dbDelegate attachmentVersion]];
    }
}
- (void) onAllCategories: (id)retObject
{
    self.syncMessage = WizStrSyncingfolders;
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
    self.syncMessage = WizStrSyncingtags;

    for (WizTag* tag in [self.dbDelegate tagsForUpload]) {
        tag.localChanged = 0;
        [tag save];
    }
    [self callAllCategories];
}
-(void) onAllTags: (id)retObject
{
    self.syncMessage = WizStrSyncingtags;
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
    self.syncMessage = WizStrSyncingdeletednotes;
	[self.dbDelegate clearDeletedGUIDs];
    [self callAllTags:[self.dbDelegate tagVersion]];
}
-(void) onDownloadDeletedList: (id)retObject
{
    self.syncMessage = WizStrSyncingdeletednotes;
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
        [self.dbDelegate setDeletedGUIDVersion:newVer+1];
        [self callDownloadDeletedList:newVer+1];
    }
    else {
        NSArray* array = [self.dbDelegate deletedGUIDsForUpload];
        [self callUploadDeletedGUIDs:array];
    }
}
- (BOOL) start
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    self.syncMessage = NSLocalizedString(@"Start Sync", nil);
    return [self callDownloadDeletedList:[self.dbDelegate deletedGUIDVersion]];
}
- (void) onError:(id)retObject
{
    busy = NO;
    if (attempts) {
        attempts--;
        [super onError:retObject];
    }
    else {
        attempts = WizNetWorkMaxAttempts;
        [WizGlobals reportError:retObject];
    }
    
}
@end
