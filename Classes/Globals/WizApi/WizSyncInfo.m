//
//  WizSyncInfo.m
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncInfo.h"

@implementation WizSyncInfo
-(void) onCallGetUserInfo:(id)retObject
{
    NSDictionary* dic = retObject;
    NSNumber* trafficLimit = [dic objectForKey:@"traffic_limit"];
    NSNumber* trafficUsage = [dic objectForKey:@"traffic_usage"];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    [index setUserTrafficLimit:[trafficLimit intValue]];
    [index setuserTrafficUsage:[trafficUsage intValue]];
}

-(void) onAllCategories: (id)retObject
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
    [self postSyncGetAllCategoriesEnd];
}
-(void) onDownloadDocumentList: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	[index updateDocuments:obj];
	//
	if ([index downloadAllList])
	{
		int64_t newVer = 0;
		for (NSDictionary* dict in obj)
		{
			NSString* verString = [dict valueForKey:@"version"];
            
			int64_t ver = [verString longLongValue];
			if (ver > newVer)
			{
				newVer = ver;
			}
		}
		//
        if(0 != newVer)
        {
            [index setDocumentVersion:newVer + 1];
            
        }
        [self postSyncGetDocumentListEnd:newVer+1];
	}
}

-(void) onAllTags: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    int64_t newVer = 0;
    for (NSDictionary* dict in obj)
    {
        NSString* verString = [dict valueForKey:@"version"];
        int64_t ver = [verString longLongValue];
        
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    //
    if(0 != newVer)
        [index setTageVersion:newVer + 1];
    [self postSyncGetTagsListEnd:1];
	[index updateTags:obj];
}
-(void) onDownloadAttachmentList:(id)retObject {
    NSArray* dicArray = retObject;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSMutableArray* dicMutableArray = [dicArray mutableCopy];
    for(NSDictionary* each in dicMutableArray )
    {
        [each setValue:[NSNumber numberWithInt:1] forKey:@"sever_changed"];
    }
    
    [index updateAttachementList:dicArray];
    int64_t newVer = 0;
    for (NSDictionary* dict in dicArray)
    {
        NSString* verString = [dict valueForKey:@"version"];
        int64_t ver = [verString longLongValue];
        
        if (ver > newVer)
        {
            newVer = ver;
        }
    }
    //
    if(0 != newVer)
        [index setAttachmentVersion:newVer + 1];
    [dicMutableArray release];
    [self postSyncGetAttachmentListEnd:1];
}
-(void) onDownloadDeletedList: (id)retObject
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	int64_t newVer = 0;
	NSArray* arr = retObject;
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
	
	//
    [self postSyncDeletedListEnd];
	[index setDeletedGUIDVersion:newVer + 1];
}

-(void) onPostTagList:(id)retObject
{
    [self postSyncUploadTagListEnd];
}


//wiz-dzpqzb



-(int) listCount
{
	return 30;
}

-(void) onDocumentsByCategory: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
	[index updateDocuments:obj];
    [self postSyncGetDocumentByCategoryEnd];
}
//
-(void) onDocumentsByTag: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncGetDocumentByTagEnd];
	[index updateDocuments:obj];
}
//
-(void) onDocumentsByKey: (id)retObject
{
	NSArray* obj = retObject;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncGetDocumentByKeyEnd];
	[index updateDocuments:obj];
}

//wiz-dzpqzb
-(void) onUploadObjectData:(id) retObject {
    
}
-(void) onUploadDeletedGUIDs: (id)retObjec
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
    [self postSyncUploadDeletedListEnd];
	[index clearDeletedGUIDs];
}

@end
