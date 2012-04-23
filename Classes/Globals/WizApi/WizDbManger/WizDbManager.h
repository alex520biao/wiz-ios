//
//  WizDbManager.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDbDelegate.h"

// doc data type
#define DataTypeUpdateDocumentGUID              @"document_guid"
#define DataTypeUpdateDocumentTitle             @"document_title"
#define DataTypeUpdateDocumentLocation          @"document_location"
#define DataTypeUpdateDocumentDataMd5           @"data_md5"
#define DataTypeUpdateDocumentUrl               @"document_url"
#define DataTypeUpdateDocumentTagGuids          @"document_tag_guids"
#define DataTypeUpdateDocumentDateCreated       @"dt_created"
#define DataTypeUpdateDocumentDateModified      @"dt_modified"
#define DataTypeUpdateDocumentType              @"document_type"
#define DataTypeUpdateDocumentFileType          @"document_filetype"
#define DataTypeUpdateDocumentAttachmentCount   @"document_attachment_count"
#define DataTypeUpdateDocumentLocalchanged      @"document_localchanged"
#define DataTypeUpdateDocumentServerChanged     @"document_serverchanged"
#define DataTypeUpdateDocumentProtected         @"document_protect"
#define DataTypeUpdateDocumentInfoLocalChanged  @"documentLocalChanged"
//attachment
#define DataTypeUpdateAttachmentDescription     @"attachment_description"
#define DataTypeUpdateAttachmentDocumentGuid    @"attachment_document_guid"
#define DataTypeUpdateAttachmentGuid            @"attachment_guid"
#define DataTypeUpdateAttachmentTitle           @"attachment_name"
#define DataTypeUpdateAttachmentDataMd5         @"data_md5"
#define DataTypeUpdateAttachmentDateModified    @"dt_data_modified"
#define DataTypeUpdateAttachmentServerChanged   @"sever_changed"
#define DataTypeUpdateAttachmentLocalChanged    @"local_changed"
//tag
#define DataTypeUpdateTagTitle                  @"tag_name"
#define DataTypeUpdateTagGuid                   @"tag_guid"
#define DataTypeUpdateTagParentGuid             @"tag_group_guid"
#define DataTypeUpdateTagDescription            @"tag_description"
#define DataTypeUpdateTagVersion                @"version"
#define DataTypeUpdateTagDtInfoModifed          @"dt_info_modified"
#define DataTypeUpdateTagLocalchanged           @"local_changed"
//
#define DataTypeUpdateKbGuid                    @"kb_guid"
@class WizDocument;
@class WizAttachment;
@class WizTag;
@interface WizDbManager : NSObject <WizDbDelegate>
- (void) close;
- (BOOL) isOpen;
- (BOOL) openDb:(NSString*)dbFilePath    tempDbFilePath:(NSString*)tempDbFilePath;
@end