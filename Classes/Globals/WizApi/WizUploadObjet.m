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
    BOOL        busy;
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
@property       (readonly)           BOOL        busy;
@property       (nonatomic, retain) NSFileHandle* uploadFildHandel;
- (void) onUploadObjectSucceedAndCleanTemp;

@end

@implementation WizUploadObjet 

@synthesize currentUploadIndex;
@synthesize sumUploadPartCount;
@synthesize uploadObjMd5;
@synthesize busy;
@synthesize objectGUID;
@synthesize objectType;
@synthesize uploadFildHandel;


-(void) initWithObjectGUID:(NSString*)objectIGUID
{
    self.objectGUID = objectIGUID;
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    NSString* zip = [index createZipByGuid:self.objectGUID];
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:zip];
    NSString* md5 = [WizApi fileMD5:zip];
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
}


-(void) dealloc
{
    self.objectGUID = nil;
    self.objectType = nil;
    self.uploadObjMd5 = nil;
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

-(void) onUploadObjectSucceedAndCleanTemp
{
    [WizGlobals deleteFile:self.currentUploadTempFilePath];
	busy = NO;
    self.objectType =nil;
    self.objectGUID = nil;
    self.sumUploadPartCount = -1;
    self.currentUploadIndex = -1;
    self.currentUploadPos = -1;
    self.sumUploadPartCount = -1;
    self.currentUploadTempFilePath = nil;
    self.uploadFileSize = -1;
    [self.uploadFildHandel closeFile];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncXmlRpcUploadDoneNotificationPrefix] object: nil userInfo: nil];
}

-(void) onError: (id)retObject
{
    busy = NO;
    [super onError:retObject];
}
@end


@implementation WizUploadDocument
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid  documentGUID:(NSString *)documentGUID
{
    [super initWithObjectGUID:documentGUID];
    self.apiURL = apiUrl;
    self.token = token_;
    self.kbguid = kbGuid;
    self.objectType = @"document";
}
- (void) onDocumentPostSimpleData:(id)retObject
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index setDocumentLocalChanged:self.objectGUID changed:NO];
    [self onUploadObjectSucceedAndCleanTemp];
}
-(void) onUploadObjectDataDone
{
    [self callDocumentPostSimpleData:self.objectGUID withZipMD5:self.uploadObjMd5];
}
@end

@implementation WizUploadAttachment
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid attachmentGUID:(NSString *)attachmentIGUID
{
    [super initWithObjectGUID:attachmentIGUID];
    self.apiURL = apiUrl;
    self.token = token_;
    self.kbguid = kbGuid;
    self.objectType = @"attachment";
}
- (void) onUploadObjectDataDone
{
    [self callAttachmentPostSimpleData:self.objectGUID];
}
- (void) onAttachmentPostSimpleData:(id)retObject
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index setAttachmentLocalChanged:self.objectGUID changed:NO];
    [self onUploadObjectSucceedAndCleanTemp];
}
-(void) onUploadObjectSucceedAndCleanTemp
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
//    if (!) {
//        if (![[NSFileManager defaultManager] fileExistsAtPath:[[WizIndex documentFilePath:self.accountUserId documentGUID:self.objectGUID] stringByAppendingPathComponent:[[index attachmentFromGUID:self.objectGUID] attachmentName]]]) {
//            [index deleteAttachment:self.objectGUID];
//            [index addDeletedGUIDRecord:self.objectGUID type:[WizGlobals attachmentKeyString]];
//            [super onUploadObjectSucceedAndCleanTemp];
//            return;
//        }
//    }
    [index setAttachmentLocalChanged:self.objectGUID changed:NO];
    [super onUploadObjectSucceedAndCleanTemp];

}
@end
