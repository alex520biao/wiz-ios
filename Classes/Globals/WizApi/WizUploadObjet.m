//
//  WizUploadObjet.m
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizUploadObjet.h"
#import "WizGlobals.h"

#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizNotification.h"
#import "WizFileManager.h"
#define UploadPartSize  (256*1024)

@protocol WizUploadObjectDelegate
@optional
- (void) onUploadObjectDataDone;
@end

@interface WizUploadObjet ()<WizUploadObjectDelegate>
{
    int         sumUploadPartCount;
    NSString*   uploadObjMd5;
    NSString* currentUploadTempFilePath;
    NSFileHandle* uploadFildHandel;
    WizObject*     uploadObject;
}
@property                           int         sumUploadPartCount;
@property                           long        currentUploadPos;
@property                           long        uploadFileSize;
@property       (nonatomic, retain) NSString*   uploadObjMd5;
@property       (nonatomic, retain) NSFileHandle* uploadFildHandel;
@property       (nonatomic, retain) NSString* currentUploadTempFilePath;
@property       (nonatomic, retain) WizObject* uploadObject;
- (void) onUploadObjectSucceedAndCleanTemp;

@end

@implementation WizUploadObjet 
@synthesize currentUploadTempFilePath;
@synthesize sumUploadPartCount;
@synthesize uploadObjMd5;
@synthesize uploadFildHandel;
@synthesize uploadObject;
-(void) dealloc
{
    if (nil != uploadFildHandel) {
        [uploadFildHandel closeFile];
        [uploadFildHandel release];
    }
    [uploadObjMd5 release];
    [uploadObject release];
    [currentUploadTempFilePath release];
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
    return [self callUploadObjectData:self.uploadObject data:data objectSize:self.uploadFileSize count:currentPartCount sumMD5:self.uploadObjMd5 sumPartCount:sumCount];
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
-(BOOL) start
{
    busy = YES;
    NSString* zip = [[WizFileManager shareManager] createZipByGuid:self.uploadObject.guid];
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
    [[WizFileManager shareManager] deleteFile:self.currentUploadTempFilePath];
    self.sumUploadPartCount = -1;
    self.currentUploadPos = -1;
    self.sumUploadPartCount = -1;
    self.currentUploadTempFilePath = nil;
    self.uploadFileSize = -1;
    [self.uploadFildHandel closeFile];
    if ([self.uploadObject isKindOfClass:[WizDocument class]]) {
        [self callDocumentPostSimpleData:(WizDocument*)self.uploadObject  withZipMD5:self.uploadObjMd5];
    }
    else if ([self.uploadObject isKindOfClass:[WizAttachment class]])
    {
        [self callAttachmentPostSimpleData:(WizAttachment*)self.uploadObject dataMd5:self.uploadObjMd5 ziwMd5:self.uploadObjMd5];
    }
}
-(void) onUploadObjectSucceedAndCleanTemp
{
    self.uploadObject = nil;
    busy = NO;
    [WizNotificationCenter postMessageUploadDone:self.uploadObject.guid];
}

- (BOOL) uploadWizObject:(WizObject *)wizobject
{
    if (self.busy) {
        return NO;
    }
    self.uploadObject = wizobject;
    return  [self start];
}
- (void) onDocumentPostSimpleData:(id)retObject
{
    WizDocument* eidt = (WizDocument*)self.uploadObject;
    eidt.localChanged = NO;
    [eidt saveInfo];
    [self onUploadObjectSucceedAndCleanTemp];
}
- (void) onAttachmentPostSimpleData:(id)retObject
{
    [WizAttachment setAttachmentLocalChanged:self.uploadObject.guid changed:NO];
    [self onUploadObjectSucceedAndCleanTemp];
}
-(void) onError: (id)retObject
{
    busy = NO;
    if (attempts>0) {
        [super onError:retObject];
    }
    else {
        attempts = WizNetWorkMaxAttempts;
        [WizGlobals reportError:retObject];
    }
}
@end  