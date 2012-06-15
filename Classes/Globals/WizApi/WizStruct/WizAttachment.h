//
//  WizAttachment.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
#define DataTypeUpdateAttachmentDescription     @"attachment_description"
#define DataTypeUpdateAttachmentDocumentGuid    @"attachment_document_guid"
#define DataTypeUpdateAttachmentGuid            @"attachment_guid"
#define DataTypeUpdateAttachmentTitle           @"attachment_name"
#define DataTypeUpdateAttachmentDataMd5         @"data_md5"
#define DataTypeUpdateAttachmentDateModified    @"dt_data_modified"
#define DataTypeUpdateAttachmentServerChanged   @"sever_changed"
#define DataTypeUpdateAttachmentLocalChanged    @"local_changed"

typedef NSInteger WizAttachmentEditType;
enum {
    WizAttachmentEditTypeTempChanged = -1,
    WizAttachmentEditTypeNoChanged  = 0,
    WizAttachmentEditTypeChanged    = 1,
};

@interface WizAttachment : WizObject
{
    NSString* type;
    NSString* dataMd5;
    NSString* description;
    NSDate*     dateModified;
    NSString* documentGuid;
    BOOL      serverChanged;
    WizAttachmentEditType      localChanged;
}
@property (nonatomic, retain)     NSString* type;
@property (nonatomic, retain)     NSString* dataMd5;
@property (nonatomic, retain)     NSString* description;
@property (nonatomic, retain)     NSDate*     dateModified;
@property (nonatomic, retain)     NSString* documentGuid;
@property (assign) BOOL      serverChanged;
@property (assign) WizAttachmentEditType      localChanged;
- (NSString*) attachmentFilePath;
- (BOOL) saveData:(NSString*)filePath;
+ (void) deleteAttachment:(NSString*)attachmentGuid;
+ (WizAttachment*) attachmentFromDb:(NSString*)attachmentGuid;
+ (void) setAttachmentLocalChanged:(NSString*)attachmentGuid changed:(BOOL)changed;
+ (void) setAttachServerChanged:(NSString*)attachmentGUID changed:(BOOL)changed;
- (void) upload;
- (void) download;
- (NSDictionary*) dataBaseModelData;
@end
