//
//  WizDownloadObject.m
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizDownloadObject.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizSync.h"
#import "WizDocumentsByLocation.h"
#import "WizSyncByTag.h"
#import "WizSyncByLocation.h"
#import "WizSyncByKey.h"
#import "WizGlobalDictionaryKey.h"
#import "Reachability.h"
#import "WizNotification.h"

NSString* SyncMethod_DownloadProcessPartBeginWithGuid = @"DownloadProcessPartBegin";
NSString* SyncMethod_DownloadProcessPartEndWithGuid   = @"DownloadProcessPartEnd";

@implementation WizDownloadObject
@synthesize objGuid;
@synthesize objType;
@synthesize busy;
@synthesize currentPos;
@synthesize fileHandle;
-(void) dealloc {
    self.objType = nil;
    self.objGuid = nil;
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    [super dealloc];
}
-(void) onError: (id)retObject
{
	busy = NO;
    [super onError:retObject];
}
- (void) downloadOver:(BOOL)unzipIsSucceed
{
    self.busy = NO;
}
-(void) onDownloadObject:(id)retObject
{
	NSDictionary* obj = retObject;
    NSData* data = [obj valueForKey:@"data"];
    NSNumber* eofPre = [obj valueForKey:@"eof"];
    BOOL eof = [eofPre intValue]==1? YES:NO;
    NSString* serverMd5 = [obj valueForKey:@"part_md5"];
    NSString* localMd5 = [WizGlobals md5:data];
    NSNumber* succeed = [NSNumber numberWithInt:[serverMd5 isEqualToString:localMd5]?1:0];
    if([succeed intValue])
    {
        if(eof) {
            [self.fileHandle writeData:data];
            [self.fileHandle closeFile];
            [WizGlobals unzipToPath:[WizIndex downloadObjectTempFilePath:objGuid] targetPath:[WizIndex objectDirectoryPath:objGuid]];
            [self downloadOver:YES];
        }
        else {
            [self callDownloadObject:objGuid startPos:[self.fileHandle offsetInFile] objType:objType];
        }
    }
    else
    {
        [self callDownloadObject:objGuid startPos:[self.fileHandle offsetInFile] objType:objType];
    }
}

- (BOOL) downloadObject
{
    NSString* objectPath = [WizIndex downloadObjectTempFilePath:objGuid];
    if([[NSFileManager defaultManager] fileExistsAtPath:objectPath])
       [WizGlobals deleteFile:objectPath];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:objectPath];
}
@end

@implementation WizDownloadDocument

- (void) downloadOver:(BOOL)unzipIsSucceed
{
    [super downloadOver:unzipIsSucceed];
    if (unzipIsSucceed) {
        [index setDocumentServerChanged:self.objGuid changed:NO]; 
    }
    [WizNotificationCenter postSyncDownloadDocument:self.objGuid current:self.currentPos total:self.currentPos];
}
- (BOOL) downloadDocument:(NSString *)documentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.objType = @"document";
    self.objGuid = documentGUID;
    self.currentPos = 0;
    return [self downloadObject];
}
- (BOOL) downloadWithoutLogin:(NSURL *)apiUrl kbguid:(NSString *)kbGuid token:(NSString*)token_ documentGUID:(NSString *)documentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.apiURL = apiUrl;
    self.kbguid  =kbGuid;
    self.token = token_;
    self.objType = @"document";
    self.objGuid = documentGUID;
    self.currentPos = 0;
    self.isLogin = YES;
    return [self downloadObject];
}
@end
@implementation WizDownloadAttachment
- (void) downloadOver:(BOOL)unzipIsSucceed
{
    [super downloadOver:unzipIsSucceed];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (unzipIsSucceed) {
        [index setAttachmentServerChanged:self.objGuid changed:NO];
    }
    NSDictionary* ret = [[NSDictionary alloc] initWithObjectsAndKeys:self.currentDownloadObjectGUID,  @"document_guid",  nil];
    
    NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:SyncMethod_DownloadObject, @"method",ret,@"ret",[NSNumber numberWithBool:YES], @"succeeded", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix] object: nil userInfo: userInfo];
	[userInfo release];
    [ret release];
}

- (BOOL) downloadAttachment:(NSString *)attachmentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.objType = @"attachment";
    self.objGuid = attachmentGUID;
    self.currentPos = 0;
    self.isLogin = NO;
    return [self downloadObject];
}
- (BOOL) downloadWithoutLogin:(NSURL *)apiUrl kbguid:(NSString *)kbGuid token:(NSString*)token_ downloadAttachment:(NSString *)attachmentGUID
{
    if (self.busy)
		return NO;
	busy = YES;
    self.apiURL = apiUrl;
    self.kbguid  =kbGuid;
    self.token = token_;
    self.objType = @"attachment";
    self.objGuid = attachmentGUID;
    self.currentPos = 0;
    self.isLogin = YES;
    return [self downloadObject];
}
@end