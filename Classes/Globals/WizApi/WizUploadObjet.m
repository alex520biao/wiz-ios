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
#import "WizSyncManager.h"
#define UploadPartSize  (262144)

@protocol WizUploadObjectDelegate
@optional
- (void) onUploadObjectDataDone;
@end

@interface WizUploadObjet ()<WizUploadObjectDelegate>
{
    NSInteger       sumUploadPartCount;
    NSString*       uploadObjMd5;
    NSString*       currentUploadTempFilePath;
    NSFileHandle*   uploadFildHandel;
    WizObject*      uploadObject;
    NSInteger       uploadFileSize;
    
    NSMutableArray* uploadQueque;
}
@property                           NSInteger         sumUploadPartCount;
@property                           NSInteger           uploadFileSize;
@property       (nonatomic, retain) NSString*   uploadObjMd5;
@property       (nonatomic, retain) NSFileHandle* uploadFildHandel;
@property       (nonatomic, retain) NSString* currentUploadTempFilePath;
@property       (nonatomic, retain) WizObject* uploadObject;
@property       (nonatomic, retain) NSMutableArray* uploadQueque;
- (void) onUploadObjectSucceedAndCleanTemp;
- (BOOL) startUpload;
@end
@implementation WizUploadObjet
@synthesize currentUploadTempFilePath;
@synthesize sumUploadPartCount;
@synthesize uploadObjMd5;
@synthesize uploadFildHandel;
@synthesize uploadObject;
@synthesize uploadQueque;
@synthesize uploadFileSize;
-(void) dealloc
{
    if (nil != uploadFildHandel) {
        [uploadFildHandel closeFile];
        [uploadFildHandel release];
    }
    [uploadObjMd5 release];
    [uploadObject release];
    [currentUploadTempFilePath release];
    [uploadQueque release];
    uploadQueque = nil;
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self) {
        uploadQueque = [[NSMutableArray alloc] init];
    }
    return self;
}

- (BOOL) uploadNextPart
{
    NSInteger currentOffSet = [self.uploadFildHandel offsetInFile];
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    NSLog(@"current count is %d",currentPartCount);
    NSData* data = [self.uploadFildHandel readDataOfLength:UploadPartSize];
    return [self callUploadObjectData:self.uploadObject data:data objectSize:self.uploadFileSize count:currentPartCount sumMD5:self.uploadObjMd5 sumPartCount:self.sumUploadPartCount];
}

- (void) setOffSetToPreviousPart
{
    NSInteger currentOffSet = [self.uploadFildHandel offsetInFile];
    NSInteger currentPartCount =currentOffSet/UploadPartSize;
    if (self.uploadFileSize/UploadPartSize >0) {
        if (self.sumUploadPartCount >1 || currentPartCount >0) {
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
    if (nil == self.uploadObject) {
        busy = NO;
        return NO;
    }
    self.syncMessage = WizStrUploadingnotes;
    if ([self.uploadObject isKindOfClass:[WizDocument class]]) {
        WizDocument* doc = (WizDocument*)self.uploadObject;
        if (doc.localChanged == WizEditDocumentTypeInfoChanged) {
            return [self callDocumentPostSimpleData:doc withZipMD5:[doc localDataMd5] isWithData:NO];
        }
    }
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
    NSLog(@"upload sum count is %@ %d",self.uploadObject.guid,self.sumUploadPartCount);
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
        if (currentOffSet == self.uploadFileSize)
        {
            [self onUploadObjectDataDone];
        }
        else
        {
            [self uploadNextPart];
        }
    }
}
- (void) onUploadObjectDataDone
{
    [[WizFileManager shareManager] deleteFile:self.currentUploadTempFilePath];
    self.sumUploadPartCount = -1;
    self.sumUploadPartCount = -1;
    self.currentUploadTempFilePath = nil;
    self.uploadFileSize = -1;
    [self.uploadFildHandel closeFile];
    if ([self.uploadObject isKindOfClass:[WizDocument class]]) {
        [self callDocumentPostSimpleData:(WizDocument*)self.uploadObject  withZipMD5:self.uploadObjMd5 isWithData:YES];
    }
    else if ([self.uploadObject isKindOfClass:[WizAttachment class]])
    {
        [self callAttachmentPostSimpleData:(WizAttachment*)self.uploadObject dataMd5:self.uploadObjMd5 ziwMd5:self.uploadObjMd5];
    }
}


- (void) onDocumentPostSimpleData:(id)retObject
{
    WizDocument* eidt = (WizDocument*)self.uploadObject;
    eidt.localChanged = WizEditDocumentTypeNoChanged;
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
//
-(void) onUploadObjectSucceedAndCleanTemp
{
    self.uploadObject = nil;
    busy = NO;
    self.syncMessage = WizSyncEndMessage;
    [self startUpload];
}

- (BOOL) isUploadWizObject:(WizObject*)object
{
    if (nil != self.uploadObject) {
        if ([self.uploadObject.guid isEqualToString:object.guid]) {
            return YES;
        }
    }
    if ([uploadQueque hasWizObject:object]) {
        return YES;
    }
    return NO;
}
- (BOOL) startUpload
{
    if (self.busy) {
        return NO;
    }
    if (0 == [uploadQueque count])
    {
        return NO;
    }
    self.uploadObject = [uploadQueque objectAtIndex:0];
    [uploadQueque removeObjectAtIndex:0];
    return [self start];
}

- (BOOL) uploadWizObject:(WizObject *)wizobject
{
    if ([self isUploadWizObject:wizobject]) {
        return YES;
    }
    [uploadQueque addWizObjectUnique:wizobject];
    NSLog(@"uploadQueue count is %d",[uploadQueque count]);
    return  [self startUpload];
}
- (void) stopUpload
{
    [self cancel];
    [uploadQueque removeAllObjects];
    [self onUploadObjectSucceedAndCleanTemp];
}
@end  