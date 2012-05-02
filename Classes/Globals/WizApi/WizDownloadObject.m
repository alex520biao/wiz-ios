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
#import "WizSync.h"
#import "WizGlobalDictionaryKey.h"
#import "Reachability.h"
#import "WizNotification.h"
#import "WizFileManager.h"
#import "WizDocumentEdit.h"
#import "WizDbManager.h"

NSString* SyncMethod_DownloadProcessPartBeginWithGuid = @"DownloadProcessPartBegin";
NSString* SyncMethod_DownloadProcessPartEndWithGuid   = @"DownloadProcessPartEnd";
//
#define DownloadPartSize      256*1024
@interface WizDownloadObject ()
{
    NSString* objType;
    NSString* objGuid;
    NSFileHandle* fileHandle;
}
@property (nonatomic, retain) NSString* objType;
@property (nonatomic, retain) NSString* objGuid;
@property (nonatomic, retain) NSFileHandle* fileHandle;
@end

@implementation WizDownloadObject
@synthesize objGuid;
@synthesize objType;
@synthesize busy;
@synthesize fileHandle;
-(void) dealloc {
    if (nil != fileHandle) {
        [fileHandle closeFile];
        [fileHandle release];
    }
    [objType release];
    [objGuid release];
    [super dealloc];
}

-(void) onError: (id)retObject
{
	busy = NO;
    [super onError:retObject];
}

- (void) downloadNext
{
    int64_t currentPos = [self.fileHandle offsetInFile];
    [self callDownloadObject:self.objGuid startPos:currentPos objType:self.objType partSize:DownloadPartSize];
}
- (void) downloadObject
{
    if (self.busy) {
        return;
    }
    busy = YES;
    NSString* fileNamePath = [[WizFileManager shareManager] downloadObjectTempFilePath:self.objGuid];
    if([[NSFileManager defaultManager] fileExistsAtPath:fileNamePath])
        [[WizFileManager shareManager]  deleteFile:fileNamePath];
    if (![[NSFileManager defaultManager] createFileAtPath:fileNamePath contents:nil attributes:nil]) {
        
    }
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:fileNamePath];
    [self.fileHandle seekToFileOffset:0];
    [self downloadNext];
}

- (void) downloadDone
{
    if ([self.objType isEqualToString:WizDocumentKeyString]) {
        WizDocument* document = [WizDocument documentFromDb:self.objGuid];
        document.serverChanged = NO;
        [document saveInfo];
    }
    else if ([self.objType isEqualToString:WizAttachmentKeyString])
    {
        NSLog(@"download attachment %@ done",self.objGuid);
        [WizAttachment setAttachServerChanged:self.objGuid changed:NO];
    }
    //
    busy = NO;
    NSLog(@"download done!***************************");
    [WizNotificationCenter postMessageDownloadDone:self.objGuid];
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
            [[WizFileManager shareManager] updateObjectDataByPath:[[WizFileManager shareManager] downloadObjectTempFilePath:self.objGuid] objectGuid:self.objGuid];
            [self downloadDone];
        }
    }
}
- (void) downloadDocument:(NSString*)documentGUID
{
    if (self.busy) {
        return ;
    }
    self.objGuid = documentGUID;
    self.objType = WizDocumentKeyString;
    return [self downloadObject];
}
- (void) downloadAttachment:(NSString*) attachmentGUID
{
    if (self.busy) {
        return ;
    }
    self.objGuid = attachmentGUID;
    self.objType = WizAttachmentKeyString;
    return [self downloadObject];
}
@end