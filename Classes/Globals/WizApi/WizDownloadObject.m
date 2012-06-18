//
//  WizDownloadObject.m
//  Wiz
//
//  Created by dong zhao on 11-10-31.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizDownloadObject.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizGlobalDictionaryKey.h"
#import "WizNotification.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
#import "WizAccountManager.h"

//
#define DownloadPartSize      256*1024
@interface WizDownloadObject ()
{
    WizObject* object;
    NSFileHandle* fileHandle;
}
@property (nonatomic, retain) WizObject* object;
@property (nonatomic, retain) NSFileHandle* fileHandle;
@end

@implementation WizDownloadObject
@synthesize object;
@synthesize fileHandle;
@synthesize sourceDelegate;
-(void) dealloc {
    if (nil != fileHandle) {
        [fileHandle closeFile];
        [fileHandle release];
    }
    [object release];
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (NSString*)currentDownloadObjectGuid
{
    return self.object.guid;
}
-(void) onError: (id)retObject
{
	busy = NO;
    if (attempts > 0) {
        attempts --;
        if ([retObject isKindOfClass:[NSError class]]) {
            NSError* error = (NSError*)retObject;
            if ([error.domain isEqualToString:NSParseErrorDomain] && error.code == NSParseErrorCode) {
                [self start];
            }
            else if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == -1001)
            {
                [self start];
            }
            else {
                [super onError:retObject];
            }
        }
    }
    else {
        if ([retObject isKindOfClass:[NSError class]]) {
            NSError* error = (NSError*)retObject;
            if ([error.domain isEqualToString:WizErrorDomain ] && error.code == NSUserCancelError) {
                attempts = WizNetWorkMaxAttempts;
                return;
            }
        }
        [WizGlobals reportError:retObject];
        attempts = WizNetWorkMaxAttempts;
    }
}
- (BOOL)downloadNext
{
    int64_t currentPos = [self.fileHandle offsetInFile];
    return [self callDownloadObject:self.object startPos:currentPos partSize:DownloadPartSize];
}
- (BOOL) start;
{
    NSLog(@"api url is %@",self.apiURL);
    busy = YES;
    if (self.object == nil) {
        busy = NO;
        return NO;
    }
    [self didChangeSyncStatue:WizSyncStatueDownloadBegin];
    NSString* fileNamePath = [[WizFileManager shareManager] downloadObjectTempFilePath:self.object.guid];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath])
        [[WizFileManager shareManager]  deleteFile:fileNamePath];
    if (![[NSFileManager defaultManager] createFileAtPath:fileNamePath contents:nil attributes:nil]) {
        
    }
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileNamePath];
    [self.fileHandle seekToFileOffset:0];
    return [self downloadNext];
}

- (void) downloadDone
{
    id<WizDbDelegate> dataBase = [[WizDbManager shareDbManager] getWizDataBase:[[WizAccountManager defaultManager] activeAccountUserId] groupId:self.kbguid];
    if ([self.object isKindOfClass:[WizDocument class]]) {
        WizDocument* doc = (WizDocument*)self.object;
        doc.serverChanged = NO;
        [doc saveInfo:dataBase];
    }
    else if ([self.object isKindOfClass:[WizAttachment class]])
    {
        [dataBase setAttachmentServerChanged:self.object.guid changed:NO];
    }
    //
    busy = NO;
    attempts = WizNetWorkMaxAttempts;
    NSLog(@"download done!***************************");
    self.syncMessage = WizSyncEndMessage;
    NSString* guid = [NSString stringWithString:self.object.guid];
    NSString* download = NSLocalizedString(@"Download", nil);
    self.syncMessage = [NSString stringWithFormat:@"%@ %@",download,self.object.title];
    self.object = nil;
    [self didChangeSyncStatue:WizSyncStatueDownloadEnd];
    [WizNotificationCenter postMessageDownloadDone:guid];
    if ([self.sourceDelegate willDownloandNext]) {
        [self didChangeSyncStatue:WizSyncStatueDownloadEnd];
        [self startDownload];
    }
    else {
        [self.apiManagerDelegate didApiSyncDone:self];
    }
}
- (BOOL) isDownloadWizObject:(WizObject*)wizObject
{
    if (nil != self.object) {
        if ([self.object.guid isEqualToString:wizObject.guid]) {
            return YES;
        }
    }
    return NO;
}
-(void) onDownloadObject:(id)retObject
{
    NSDictionary* obj = retObject;
    NSData* data = [obj valueForKey:@"data"];
    NSNumber* eofPre = [obj valueForKey:@"eof"];
    BOOL eof = [eofPre intValue]? YES:NO;
    NSString* serverMd5 = [obj valueForKey:@"part_md5"];
     NSNumber* objSize = [obj valueForKey:@"obj_size"];
    NSString* localMd5 = [WizGlobals md5:data];
    BOOL succeed = [serverMd5 isEqualToString:localMd5]?YES:NO;
    if(!succeed) {
        [self downloadNext];
    }
    else
    {
        [self.fileHandle writeData:data];
        if (!eof) {
            [self downloadNext];
        }
        else {
            if ([objSize longLongValue] != [self.fileHandle offsetInFile]) {
                [self.fileHandle seekToFileOffset:0];
                [self downloadNext];
            }
            else
            {
                NSLog(@"download done and will update the data!");
                [[WizFileManager shareManager] updateObjectDataByPath:[[WizFileManager shareManager] downloadObjectTempFilePath:self.object.guid] objectGuid:self.object.guid];
                [self downloadDone];
            }
        }
    }
}
- (BOOL) startDownload
{
    if (busy) {
        return NO;
    }
    WizObject* downlodObject = [self.sourceDelegate nextWizObjectForDownload];
    if (!downlodObject) {
        return NO;
    }
    self.object = downlodObject;
    return [self start];
}
- (void) stopDownload
{
    [self cancel];
    self.object = nil;
    self.sourceDelegate = nil;
    busy = NO;
}
@end