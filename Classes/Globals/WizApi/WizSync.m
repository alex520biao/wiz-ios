//
//  WizSync.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizSync.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizDownloadObject.h"
#import "WizUploadObjet.h"
#import "WizDownloadPool.h"
#import "Reachability.h"
#import "WizSyncManager.h"
#define READPARTSIZE 100*1024



@implementation WizSync

@synthesize busy;
@synthesize documentsForUpdated;
@synthesize attachmentsForUpdated;
@synthesize isStopByUser;
//wiz-dzpqzb test
@synthesize download;
- (void) dealloc
{
	[documentsForUpdated release];
    [attachmentsForUpdated release];
    [download release];
	[super dealloc];
}
- (BOOL) isSyncingg
{
    return self.busy;
}
-(void) onError: (id)retObject
{
    self.busy = NO;
	[super onError:retObject];
}
-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
	busy = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncEndNotificationPrefix] object: nil];
}


-(void) downAllDocument
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    WizDownloadPool* pool = [[WizGlobalData sharedData] globalDownloadPool:self.accountUserId];
    BOOL willDownload = YES;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if ([index connectOnlyViaWifi]) {
        Reachability* rech = [Reachability reachabilityForInternetConnection];
        NetworkStatus netStatus = [rech currentReachabilityStatus];
        if (netStatus != ReachableViaWiFi) {
            willDownload = NO;
        }
    }
    if([self.download count] == 0 || [index durationForDownloadDocument] == 0) 
    {
        [self callClientLogout];
        return;
    }
    if (!willDownload) {
        [self callClientLogout];
        return;
    }
    WizDocument* each = [self.download lastObject];
    WizDownloadDocument* downloader = [pool getDownloadProcess:each.guid type:[WizGlobals documentKeyString]];
    downloader.owner = self;
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    //
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
    NSString* notificationName = [downloader notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix];
    [nc addObserver:self selector:@selector(downAllDocument) name:notificationName object:nil];
    [downloader downloadWithoutLogin:self.apiURL kbguid:self.kbguid token:self.token documentGUID:each.guid];
    [self.download removeLastObject];
}

-(BOOL) uploadAllAttachments
{
//    if (isStopByUser) {
//        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//        [nc removeObserver:self];
//        [self callClientLogout];
//        return NO;
//    }
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    if(self.attachmentsForUpdated == nil || [self.attachmentsForUpdated count] == 0)
//    {
//        if ([index downloadDocumentData]) {
//            WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//            self.download  = [NSMutableArray arrayWithArray:[index documentForDownload]];
//            [self downAllDocument];
//            return YES;
//        }
//        else {
//            [self callClientLogout];
//            return YES;
//        }
//    }
//    WizDocumentAttach* attach = [self.attachmentsForUpdated lastObject];
//    WizUploadAttachment* upload = [[WizGlobalData sharedData] uploadAttachmentData:self.accountUserId attachmentGUID:attach.attachmentGuid owner:self];
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
//    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
//    NSString* notificationName = [self notificationName:WizSyncXmlRpcUploadDoneNotificationPrefix];
//    [nc addObserver:self selector:@selector(uploadAllAttachments) name:notificationName object:nil];
//    [upload uploadObjectData];
//    [self.attachmentsForUpdated removeLastObject];
    return YES;
}


-(BOOL) uploadAllObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return NO;
    }
    
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	//
//    if(nil == self.documentsForUpdated )
    
    self.documentsForUpdated = [[[index documentForUpload] mutableCopy] autorelease];
    for (WizDocument* each in self.documentsForUpdated) {
        WizSyncManager* share = [WizSyncManager shareManager];
        share.accountUserId = self.accountUserId;
        [[WizSyncManager shareManager] uploadDocument:each.guid];
    }
    NSArray* attachments = [index attachmentsForUpload];
    for (WizDocumentAttach* each in attachments) {
        [[WizSyncManager shareManager] uploadAttachment:each.attachmentGuid];
    }
    self.busy = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncEndNotificationPrefix] object: nil];
//    if([self.documentsForUpdated count] == 0)
//    {
//        NSArray* arr = [index documentForUpload];
//        if(0 == [arr count])
//        {
//            self.attachmentsForUpdated = [NSMutableArray arrayWithArray:[index attachmentsForUpload]];
//            [self uploadAllAttachments];
//            return YES;
//        } else
//        {
//            self.documentsForUpdated = nil;
//            self.documentsForUpdated = [[arr mutableCopy] autorelease];
//        }
//    }
//    WizDocument* doc = [self.documentsForUpdated lastObject];
//    
//
//    if (!doc)   return NO;
//    
//    WizUploadDocument* upload = [[WizGlobalData sharedData] uploadDocumentData:self.accountUserId documentGUID:doc.guid owner:self];
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
//    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
//    NSString* notificationName = [self notificationName:WizSyncXmlRpcUploadDoneNotificationPrefix];
//    [nc addObserver:self selector:@selector(uploadAllObject) name:notificationName object:nil];
//    [upload uploadObjectData];
//    [self.documentsForUpdated removeLastObject];
    return YES;
}


-(void) onAllCategories: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
	[super onAllCategories:retObject];
	[self uploadAllObject];
	
}
-(void) onDownloadAttachmentList:(id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer = [index attachmentVersion];
    [super onDownloadAttachmentList:retObject];
    int64_t newVer = [index attachmentVersion];
    NSArray* arr = retObject;
    BOOL continueSync = newVer > oldVer ? YES: NO;
    if ([arr count] < [self listCount] || !continueSync) {
        [self callAllCategories];
    }
    else {
        [self callDownloadAttachmentList];
    } 
}
-(void) onDownloadDocumentList: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    int64_t oldVer = [index documentVersion];
    [super onDownloadDocumentList:retObject];
    int64_t newVer = [index documentVersion];
    if ([index downloadAllList]) {
        NSArray* arr = retObject;
        BOOL continueSync = newVer > oldVer ? YES: NO;
        if ([arr count] < [self listCount] || !continueSync) {
            [self callDownloadAttachmentList];
        }
        else {
            [self callDownloadDocumentList];
        }
    }
    else {
        [self callDownloadAttachmentList];
    }
}

- (void) onPostTagList:(id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    [super onPostTagList:retObject];
    [self callDownloadDocumentList];
}
-(void) onAllTags: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
	[super onAllTags:retObject];
    
	[self callPostTagList];
}

-(void) onUploadDeletedGUIDs: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
	[super onUploadDeletedGUIDs:retObject];
	//
	[self callAllTags];
}

-(void) onDownloadDeletedList: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
	[super onDownloadDeletedList:retObject];
	//
	NSArray* arr = retObject;
	if ([arr count] < [self listCount])
	{
		[self callUploadDeletedGUIDs];
	}
	else 
	{
		[self callDownloadDeletedList];
	}
}

-(void) onCallGetUserInfo:(id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    [super onCallGetUserInfo:retObject];
    [self callDownloadDeletedList];
}
-(void) onClientLogin: (id)retObject
{
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
	[super onClientLogin:retObject];
    [self callGetUserInfo];
}
-(void) stopSync
{
    self.isStopByUser = YES;
}

- (BOOL) startSync
{
	if (self.busy)
		return NO;
	//
	busy = YES;
    self.isStopByUser = NO;
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncBeginNotificationPrefix] object: nil];
	return [self callClientLogin];
}

-(void) cancel
{
    [self stopSync];
    self.busy = NO;
}
@end
