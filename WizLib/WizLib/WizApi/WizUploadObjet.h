//
//  WizUploadObjet.h
//  Wiz
//
//  Created by dong zhao on 11-11-1.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@interface WizUploadObjet : WizApi {
    long        currentUploadPos;
    int         currentUploadIndex;
    int         sumUploadPartCount;
    long        uploadPartSize;
    long        uploadFileSize;
    NSString*   uploadObjMd5;
    BOOL        busy;
    NSString*   objectGUID;
    NSString*   objectType;
    NSFileHandle* uploadFildHandel;
    id owner;
}
@property                           int         currentUploadIndex;
@property                           int         sumUploadPartCount;
@property                           long        currentUploadPos;
@property                           long        uploadPartSize;
@property                           long        uploadFileSize;
@property       (nonatomic, retain) NSString*   uploadObjMd5;
@property       (nonatomic, retain) NSString*   objectGUID;
@property       (nonatomic, retain) NSString*   objectType;
@property       (assign )           BOOL        busy;
@property       (nonatomic, retain) NSFileHandle* uploadFildHandel;
@property       (nonatomic, retain) id owner;
-(void) onError: (id)retObject;
-(BOOL) onUploadObjectData:(id)retObject;
-(BOOL) uploadObjectData;
-(void) onUploadObjectSucceedAndCleanTemp;
-(void) initWithObjectGUID:(NSString*)objectIGUID;

@end

@interface WizUploadDocument : WizUploadObjet {
}
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid  documentGUID:(NSString *)documentIGUID;
-(void) onUploadObjectSucceedAndCleanTemp;
@end

@interface WizUploadAttachment : WizUploadObjet {
}
-(void) initWithObjectGUID:(NSURL*)apiUrl token:(NSString*)token_ kbguid:(NSString*)kbGuid attachmentGUID:(NSString *)attachmentIGUID;
-(void) onUploadObjectSucceedAndCleanTemp;
@end