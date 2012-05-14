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
#import "Reachability.h"
#import "WizNotification.h"
#import "WizFileManager.h"
#import "WizDbManager.h"

NSString* SyncMethod_DownloadProcessPartBeginWithGuid = @"DownloadProcessPartBegin";
NSString* SyncMethod_DownloadProcessPartEndWithGuid   = @"DownloadProcessPartEnd";
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
    busy = YES;
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
    if ([self.object isKindOfClass:[WizDocument class]]) {
        WizDocument* document = (WizDocument*)self.object;
        document.serverChanged = NO;
        [document saveInfo];
    }
    else if ([self.object isKindOfClass:[WizAttachment class]])
    {
        [WizAttachment setAttachServerChanged:self.object.guid changed:NO];
    }
    //
    busy = NO;
    attempts = WizNetWorkMaxAttempts;
    NSLog(@"download done!***************************");
    [WizNotificationCenter postMessageDownloadDone:self.object.guid];
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
            [[WizFileManager shareManager] updateObjectDataByPath:[[WizFileManager shareManager] downloadObjectTempFilePath:self.object.guid] objectGuid:self.object.guid];
            [self downloadDone];
        }
    }
}
- (BOOL) downloadWizObject:(WizObject*)wizObject
{
    if (self.busy) {
        return NO;
    }
    self.object = wizObject;
    return [self start];
}
@end