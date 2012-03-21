//
//  WizSyncBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizIndex.h"
#import "WizDownloadObject.h"
#import "WizUploadObjet.h"
@implementation WizSyncBase
@synthesize downloaderDoc;
@synthesize uploaderDocument;
@synthesize uploaderAttachment;
@synthesize busy;
@synthesize isStopByUser;
@synthesize downloadArray;
@synthesize uploadArray;
@synthesize uploadAttachArray;
- (void) dealloc
{
    self.downloadArray = nil;
    self.uploadArray = nil;
    self.downloaderDoc = nil;
    self.uploaderDocument = nil;
    self.uploaderAttachment = nil;
    [super dealloc];
}

-(void) onError: (id)retObject
{
	[super onError:retObject];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
	busy = NO;
}
- (void) addStopNotifacation
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(stopSync) name:[self notificationName:WizGlobalStopSync] object:nil];
}
-(void) stopSync
{
    
    self.isStopByUser = YES;
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncEndNotificationPrefix] object: nil];
	busy = NO;
}

-(void) downAllDocument
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if (isStopByUser) {
        [nc removeObserver:self];
        [self callClientLogout];
        return;
    }
    
    if([self.downloadArray count] == 0) 
    {
        [self callClientLogout];
        [nc removeObserver:self.downloaderDoc];
        return;
    }
    WizDocument* each = [self.downloadArray objectAtIndex:0];
    [self addStopNotifacation];
    NSString* notificationName = [self.downloaderDoc notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix];
    [nc addObserver:self selector:@selector(downAllDocument) name:notificationName object:nil];
    [self.downloaderDoc downloadWithoutLogin:self.apiURL kbguid:self.kbguid token:self.token documentGUID:each.guid];
    [self.downloadArray removeObjectAtIndex:0];
}
-(BOOL) uploadAllAttachments
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if (isStopByUser) {
        [nc removeObserver:self];
        [self callClientLogout];
        return NO;
    }
    if (0 == [self.uploadAttachArray count]) {
        [self addStopNotifacation];
        if ([[[WizGlobalData sharedData] indexData:self.accountUserId] downloadDocumentData]) {
            [self downAllDocument];
        }
        else
        {
            [self callClientLogout];
        }
        return YES;
    }
    WizDocumentAttach* attach = [self.uploadAttachArray objectAtIndex:0];
    if (nil == attach) {
        return NO;
    }
    [self.uploaderAttachment initWithObjectGUID:self.apiURL token:self.token kbguid:self.kbguid attachmentGUID:attach.attachmentGuid];
    self.uploaderAttachment.owner = self;
    [self addStopNotifacation];
    NSString* notificationName = [self.downloaderDoc notificationName:WizSyncXmlRpcUploadDoneNotificationPrefix];
    [nc addObserver:self selector:@selector(uploadAllAttachments) name:notificationName object:nil];
    [self.uploaderAttachment uploadObjectData];
    [self.uploadAttachArray removeObjectAtIndex:0];
    return YES;
}


-(BOOL) uploadAllObject
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if (isStopByUser) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [self callClientLogout];
        return NO;
    }
    if (0 == [self.uploadArray count]) {
        [self addStopNotifacation];
        [self uploadAllAttachments];
        return YES;
    }
    WizDocument* doc = [self.uploadArray lastObject];
    if (nil == doc) {
        return NO;
    }
    [self.uploaderDocument initWithObjectGUID:self.apiURL token:self.token kbguid:self.kbguid documentGUID:doc.guid];
    self.uploaderDocument.owner = self;
    [self addStopNotifacation];
    NSString* notificationName = [self.uploaderDocument notificationName:WizSyncXmlRpcUploadDoneNotificationPrefix];
    [nc addObserver:self selector:@selector(uploadAllObject) name:notificationName object:nil];
    [self.uploaderDocument uploadObjectData];
    [self.uploadArray removeLastObject];
    return YES;
}

-(void) onClientLogin: (id)retObject
{
	[super onClientLogin:retObject];
    [self callSyncMethod];
}
- (BOOL) startSync
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    self.isStopByUser = NO;
    if (self.downloaderDoc == nil) {
        WizDownloadDocument* downloader = [[WizDownloadDocument alloc] initWithAccount:self.accountUserId password:@""];
        self.downloaderDoc = downloader;
        [downloader release];
        self.downloaderDoc.owner = self;
    }
    if (nil == self.uploaderAttachment) {
        WizUploadAttachment* uploadAttachment = [[WizUploadAttachment alloc] initWithAccount:self.accountUserId password:@""];
        self.uploaderAttachment = uploadAttachment;
        [uploadAttachment release];
    }
    if (nil == self.uploaderDocument) {
        WizUploadDocument* uploadDocument = [[WizUploadDocument alloc] initWithAccount:self.accountUserId password:@""];
        self.uploaderDocument = uploadDocument;
        [uploadDocument release];
    }
    [self addStopNotifacation];
    [self prepareSyncArray];
	return [self callClientLogin];
}
- (void) cancel
{
    [super cancel];
    busy = NO;
}
@end
