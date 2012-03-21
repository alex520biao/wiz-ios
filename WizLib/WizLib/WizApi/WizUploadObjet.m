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
#define READPARTSIZE  100*1024

@implementation WizUploadObjet

@synthesize currentUploadIndex;
@synthesize sumUploadPartCount;
@synthesize currentUploadPos;
@synthesize uploadPartSize;
@synthesize uploadFileSize;
@synthesize uploadObjMd5;
@synthesize busy;
@synthesize objectGUID;
@synthesize objectType;
@synthesize uploadFildHandel;
@synthesize owner;


-(void) initWithObjectGUID:(NSString*)objectIGUID
{
        self.objectGUID = objectIGUID;
        WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
        NSString* zip = [index createZipByGuid:self.objectGUID];
        NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:zip];
        NSString* md5 = [WizApi fileMD5:zip];
        self.uploadObjMd5 = md5;
        self.uploadFildHandel = handle;
        
        self.uploadFileSize = [self.uploadFildHandel seekToEndOfFile];
       
        self.sumUploadPartCount = self.uploadFileSize  /(READPARTSIZE) +1;
        [self.uploadFildHandel seekToFileOffset:0];
        self.currentUploadTempFilePath = zip;
}


-(void) dealloc
{
    self.objectGUID = nil;
    self.objectType = nil;
    self.uploadObjMd5 = nil;
    self.owner = nil;
    [super dealloc];
}

-(BOOL) uploadObjectData
{
    if (self.busy)
		return NO;
	//
	busy = YES;
    NSData* data = [self.uploadFildHandel readDataOfLength:READPARTSIZE];
    self.currentUploadIndex = 0;
    self.currentUploadPos = 0;
    self.uploadPartSize = [data length];
    return [self callUploadObjectData:self.objectGUID objectType:self.objectType data:data objectSize:self.uploadFileSize count:0 sumMD5:self.uploadObjMd5 sumPartCount:self.sumUploadPartCount];
}

-(BOOL) onUploadObjectData:(id)retObject
{
    BOOL succeed = [super onUploadObjectData:retObject];
    if(!succeed)
    {
        [self.uploadFildHandel seekToFileOffset:self.currentUploadPos];
        NSData* data = [self.uploadFildHandel readDataOfLength:READPARTSIZE];
        
        [self postSyncUploadObject:self.uploadFileSize current:READPARTSIZE*self.currentUploadIndex objectGUID:self.objectGUID objectType:self.objectType];
        return [self callUploadObjectData:self.objectGUID objectType:self.objectType data:data objectSize:self.uploadFileSize count:self.currentUploadIndex sumMD5:self.uploadObjMd5 sumPartCount:self.sumUploadPartCount];
    }
    else
    {
        if(self.currentUploadIndex < self.sumUploadPartCount -1 )
        {
            self.currentUploadPos = self.currentUploadPos + self.uploadPartSize;
            NSData* data = [self.uploadFildHandel readDataOfLength:READPARTSIZE];
            self.currentUploadIndex = self.currentUploadIndex + 1;
            self.uploadPartSize = [data length];
            [self postSyncUploadObject:self.uploadFileSize current:READPARTSIZE*self.currentUploadIndex objectGUID:self.objectGUID objectType:self.objectType];
            return [self callUploadObjectData:self.objectGUID  objectType:self.objectType data:data objectSize:self.uploadFileSize count:self.currentUploadIndex sumMD5:self.uploadObjMd5 sumPartCount:self.sumUploadPartCount];
        }
        else
        {
            [self postSyncUploadObject:self.uploadFileSize current:self.uploadFileSize objectGUID:self.objectGUID objectType:self.objectType];
            [self onUploadObjectSucceedAndCleanTemp];
            return YES;
        }
    }
}

-(void) onUploadObjectSucceedAndCleanTemp
{
    [WizGlobals deleteFile:self.currentUploadTempFilePath];
	self.busy = NO;
    self.objectType =nil;
    self.objectGUID = nil;
    self.sumUploadPartCount = -1;
    self.currentUploadIndex = -1;
    self.currentUploadPos = -1;
    self.uploadPartSize = -1;
    self.sumUploadPartCount = -1;
    self.currentUploadTempFilePath = nil;
    self.uploadFileSize = -1;
    [self.uploadFildHandel closeFile];
	[[NSNotificationCenter defaultCenter] postNotificationName:[self notificationName: WizSyncXmlRpcUploadDoneNotificationPrefix] object: nil userInfo: nil];
}

-(void) onError: (id)retObject
{
	
	if (self.owner != nil && [self.owner isKindOfClass:[WizSync class]]) {
        WizSync* sync = (WizSync*)self.owner;
        [sync onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByTag class]])
    {
        WizSyncByTag* sync = (WizSyncByTag*)self.owner;
        [sync onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByLocation class]])
    {
        WizSyncByLocation* sync = (WizSyncByLocation*)self.owner;
        [sync onError:retObject];
    }
    else if (self.owner != nil && [self.owner isKindOfClass:[WizSyncByKey class]])
    {
        WizSyncByKey* sync = (WizSyncByKey*)self.owner;
        [sync onError:retObject];
    }
    else
    {
        [super onError:retObject];
    }
    self.owner = nil;
    busy = NO;
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
-(void) onUploadObjectSucceedAndCleanTemp
{
    [self callDocumentPostSimpleData:self.objectGUID withZipMD5:self.uploadObjMd5];
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index setDocumentLocalChanged:self.objectGUID changed:NO];
    [super onUploadObjectSucceedAndCleanTemp];
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
-(void) onUploadObjectSucceedAndCleanTemp
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    if (![self callAttachmentPostSimpleData:self.objectGUID]) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[WizIndex documentFilePath:self.accountUserId documentGUID:self.objectGUID] stringByAppendingPathComponent:[[index attachmentFromGUID:self.objectGUID] attachmentName]]]) {
            [index deleteAttachment:self.objectGUID];
            [index addDeletedGUIDRecord:self.objectGUID type:[WizGlobals attachmentKeyString]];
            [super onUploadObjectSucceedAndCleanTemp];
            return;
        }
    }
    [index setAttachmentLocalChanged:self.objectGUID changed:NO];
    [super onUploadObjectSucceedAndCleanTemp];

}
@end
