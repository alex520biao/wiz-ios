//
//  WizUploadObjet.m
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizUploadObjet.h"
#import "WizGlobals.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizSync.h"
#import "WizSyncByTag.h"
#import "WizSyncByLocation.h"
#import "WizSyncByKey.h"
#import "WizNotification.h"
#define UploadPartSize  (256*1024)

@protocol WizUploadObjectDelegate
@optional
- (void) onUploadObjectDataDone;
@end

@interface WizUploadObjet ()<WizUploadObjectDelegate>
{
    int         currentUploadIndex;
    int         sumUploadPartCount;
    NSString*   uploadObjMd5;
    NSString* currentUploadTempFilePath;
    NSString*   objectGUID;
    NSString*   objectType;
    NSFileHandle* uploadFildHandel;
}
@property                           int         currentUploadIndex;
@property                           int         sumUploadPartCount;
@property                           long        currentUploadPos;
@property                           long        uploadFileSize;
@property       (nonatomic, retain) NSString*   uploadObjMd5;
@property       (nonatomic, retain) NSString*   objectGUID;
@property       (nonatomic, retain) NSString*   objectType;
@property       (nonatomic, retain) NSFileHandle* uploadFildHandel;
@property       (nonatomic, retain) NSString* currentUploadTempFilePath;
- (void) onUploadObjectSucceedAndCleanTemp;

@end

@implementation WizUploadObjet 
@synthesize currentUploadTempFilePath;
@synthesize currentUploadIndex;
@synthesize sumUploadPartCount;
@synthesize uploadObjMd5;
@synthesize busy;
@synthesize objectGUID;
@synthesize objectType;
@synthesize uploadFildHandel;
-(void) dealloc
{
    if (nil != uploadFildHandel) {
        [uploadFildHandel closeFile];
        [uploadFildHandel release];
    }
    [objectGUID release];
    [objectType release];
    [uploadObjMd5 release];
    [super dealloc];
}

- (BOOL) uploadNextPart
{
    NSInteger currentOffSet = [self.uploadFildHandel offsetInFile];
    NSInteger sumCount = self.uploadFileSize/UploadPartSize;
    if (self.uploadFileSize%UploadPartSize >0) {
        sumCount++;
    }
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    NSData* data = [self.uploadFildHandel readDataOfLength:UploadPartSize];
    return [self callUploadObjectData:self.objectGUID objectType:self.objectType data:data objectSize:self.uploadFileSize count:currentPartCount sumMD5:self.uploadObjMd5 sumPartCount:sumCount];
}

- (void) setOffSetToPreviousPart
{
    NSInteger currentOffSet = [self.uploadFildHandel offsetInFile];
    NSInteger sumCount = self.uploadFileSize/UploadPartSize;
    if (self.uploadFileSize%UploadPartSize >0) {
        sumCount++;
    }
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    if (self.uploadFileSize/UploadPartSize >0) {
        if (sumCount >1 || currentPartCount >0) {
            [self.uploadFildHandel seekToFileOffset:(currentPartCount-1)*UploadPartSize];
        }
        else {
            [self.uploadFildHandel seekToFileOffset:0];
        }
    }
    else {
        [self.uploadFildHandel seekToFileOffset:currentPartCount*UploadPartSize];
    }
    
}
- (void) reUploadCurrentPart
{
    [self setOffSetToPreviousPart];
    [self uploadNextPart];
}
-(BOOL) uploadObjectData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    NSString* zip = [index createZipByGuid:self.objectGUID];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:zip];
    NSString* md5 = [WizGlobals fileMD5:zip];
    self.uploadObjMd5 = md5;
    self.uploadFildHandel = handle;
    self.uploadFileSize = [WizGlobals fileLength:zip];
    self.sumUploadPartCount = self.uploadFileSize  /(UploadPartSize);
    if (self.uploadFileSize%(UploadPartSize) > 0)
    {
        self.sumUploadPartCount++;
    }
    [self.uploadFildHandel seekToFileOffset:0];
    self.currentUploadTempFilePath = zip;
    return [self uploadNextPart];
}

-(void) onUploadObjectData:(id)retObject
{
    NSMutableDictionary* obj = (NSMutableDictionary*)retObject;
    BOOL succeed = ([[obj valueForKey:@"return_code"] isEqualToString:@"200"])? YES:NO;
    if (!succeed) {
        [self reUploadCurrentPart];
    }
    else {
        NSInteger currentOffSet = [self.uploadFildHandel offsetInFile];
        if (currentOffSet == self.uploadFileSize) {
            [self onUploadObjectDataDone];
        }
        else {
            [self uploadNextPart];
        }
    }
}
- (void) onUploadObjectDataDone
{
    if ([self.objectType isEqualToString:WizDocumentKeyString]) {
        [self callDocumentPostSimpleData:self.objectGUID withZipMD5:self.uploadObjMd5];
    }
    else if ([self.objectType isEqualToString:WizAttachmentKeyString])
    {
        [self callAttachmentPostSimpleData:self.objectGUID];
    }
}
-(void) onUploadObjectSucceedAndCleanTemp
{
    [WizGlobals deleteFile:self.currentUploadTempFilePath];
    busy = NO;
    self.objectType = nil;
    self.sumUploadPartCount = -1;
    self.currentUploadIndex = -1;
    self.currentUploadPos = -1;
    self.sumUploadPartCount = -1;
    self.currentUploadTempFilePath = nil;
    self.uploadFileSize = -1;
    [self.uploadFildHandel closeFile];
    [WizNotificationCenter postMessageUploadDone:self.objectGUID];
}

- (BOOL) uploadDocument:(NSString*)documentGUID
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    self.objectGUID = documentGUID;
    self.objectType = WizDocumentKeyString;
    return  [self uploadObjectData];
}
- (BOOL) uploadAttachment:(NSString*)attachmentGUID
{
    if (self.busy) {
        return NO;
    }
    busy = YES;
    self.objectGUID = attachmentGUID;
    self.objectType = WizAttachmentKeyString;
    return [self uploadObjectData];
}

- (void) onDocumentPostSimpleData:(id)retObject
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index setDocumentLocalChanged:self.objectGUID changed:NO];
    [self onUploadObjectSucceedAndCleanTemp];
}
- (void) onAttachmentPostSimpleData:(id)retObject
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index setAttachmentLocalChanged:self.objectGUID changed:NO];
    [self onUploadObjectSucceedAndCleanTemp];
}
-(void) onError: (id)retObject
{
    busy = NO;
    [super onError:retObject];
}
@end

