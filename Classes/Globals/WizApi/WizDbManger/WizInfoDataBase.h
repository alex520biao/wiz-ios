//
//  WizInfoDataBase.h
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizDataBaseBase.h"
#import "WizDbDelegate.h"

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
#define DataTypeUpdateDocumentGPS_LATITUDE      @"gps_latitude"
#define DataTypeUpdateDocumentGPS_LONGTITUDE    @"gps_longitude"
#define DataTypeUpdateDocumentGPS_ALTITUDE      @"GPS_ALTITUDE"
#define DataTypeUpdateDocumentGPS_DOP           @"GPS_DOP"
#define DataTypeUpdateDocumentGPS_ADDRESS       @"GPS_ADDRESS"
#define DataTypeUpdateDocumentGPS_COUNTRY       @"GPS_COUNTRY"
#define DataTypeUpdateDocumentGPS_LEVEL1        @"GPS_LEVEL1"
#define DataTypeUpdateDocumentGPS_LEVEL2        @"GPS_LEVEL2"
#define DataTypeUpdateDocumentGPS_LEVEL3        @"GPS_LEVEL3"
#define DataTypeUpdateDocumentGPS_DESCRIPTION   @"GPS_DESCRIPTION"
#define DataTypeUpdateDocumentREADCOUNT         @"READCOUNT"


@interface WizInfoDataBase : WizDataBaseBase <WizDbDelegate>

@end
