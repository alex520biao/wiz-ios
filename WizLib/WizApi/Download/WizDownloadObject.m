//
//  WizDownloadObject.m
//  WizLib
//
//  Created by 朝 董 on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDownloadObject.h"
#import "WizFileManager.h"


@interface WizDownloadObject()
{
    NSFileHandle* tempFile;
    NSString* guid;
    NSString* type;
}
@property (retain) NSFileHandle* tempFile;
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* type;
@end
@implementation WizDownloadObject
@synthesize guid;
@synthesize type;
@synthesize tempFile;
- (void) dealloc
{
    [self.tempFile closeFile];
    [self.tempFile release];
    self.tempFile = nil;
    [self.guid release];
    self.guid = nil;
    [self.type release];
    self.type = nil;
    [super dealloc];
}
- (void) downloadObject
{
    if (self.busy) {
        return;
    }
    self.busy = YES;
    NSString* downloadFilePath = [WizFileManager downloadTempFilePath:self.guid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadFilePath]) {
        NSError* error= nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:&error]) {
            [WizGlobals reportError:error];
        }
    }
    [WizFileManager ensureFileIsExist:downloadFilePath];
    self.tempFile = [NSFileHandle fileHandleForWritingAtPath:downloadFilePath];
    
    int64_t currentPos = [self.tempFile offsetInFile];
    [self callDownloadObject:self.guid startPos:currentPos objType:self.type];
}
- (void) onDowloadObject:(id)retObject
{
    NSDictionary* obj = retObject;
    NSData* data = [obj valueForKey:@"data"];
    NSNumber* eofPre = [obj valueForKey:@"eof"];
    BOOL eof = [eofPre intValue]? YES:NO;
    NSString* serverMd5 = [obj valueForKey:@"part_md5"];
    NSString* localMd5 = [WizGlobals md5:data];
    BOOL succeed = [serverMd5 isEqualToString:localMd5]?YES:NO;
    if (succeed) {
        [self.tempFile writeData:data];
        [self.tempFile closeFile];
        if (eof) {
            [WizFileManager updateObjectLocalData:self.guid];
            [WizFileManager deleteDownloadTempFile:self.guid];
            self.busy = NO;
            [WizNotificationCenter postDownloadDoneMassage:self.guid];
        }
        else {
            [self callDownloadObject:self.guid startPos:[self.tempFile offsetInFile] objType:self.type];
        }
    }
    else {
        [self callDownloadObject:self.guid startPos:[self.tempFile offsetInFile] objType:self.type];
    }
}

- (void) downloadDocument:(NSString*)documentGUID
{
    self.guid = documentGUID;
    self.type = WizDocumentKeyString;
    [self downloadObject];
}
- (void) downloadAttachment:(NSString*)attachmentGUID
{
    self.guid = attachmentGUID;
    self.type = WizAttachmentKeyString;
    [self downloadObject];
}
@end
