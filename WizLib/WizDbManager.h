//
//  WizDbManager.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@class WizDocument;
@interface WizDbManager : NSObject
- (BOOL) isOpen;
- (BOOL) openDb;
- (void) close;
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
- (BOOL) updateDocument: (NSDictionary*) doc;
- (BOOL) updateDocuments: (NSArray*) documents;
- (WizDocument*) documentFromGUID:(NSString*)guid;
- (NSArray*) recentDocuments;
+ (id) shareDbManager;
@end
