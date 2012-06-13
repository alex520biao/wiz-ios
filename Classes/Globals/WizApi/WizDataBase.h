//
//  WizDataBase.h
//  Wiz
//
//  Created by 朝 董 on 12-6-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDbDelegate.h"
#import "WizSettingsDbDelegate.h"
#import "WizAbstractDbDelegate.h"

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

#define KeyOfSyncVersion               @"SYNC_VERSION"
#define DocumentNameOfSyncVersion      @"DOCUMENT"
#define DeletedGUIDNameOfSyncVersion   @"DELETED_GUID"
#define TagVersion                     @"TAGVERSION"
#define UserTrafficLimit               @"TRAFFICLIMIT"
#define UserTrafficUsage               @"TRAFFUCUSAGE"
#define KeyOfUserInfo                  @"USERINFO"
#define UserLevel                      @"USERLEVEL"
#define UserLevelName                  @"USERLEVELNAME"
#define UserType                       @"USERTYPE"
#define UserPoints                     @"USERPOINTS"
#define AttachmentVersion              @"ATTACHMENTVERSION"
#define MoblieView                     @"MOBLIEVIEW"
#define DurationForDownloadDocument    @"DURATIONFORDOWLOADDOCUMENT"
#define WebFontSize                    @"WEBFONTSIZE"
#define DatabaseVesion                 @"DATABASE"
#define ImageQuality                   @"IMAGEQUALITY"
#define ProtectPssword                 @"PROTECTPASSWORD"
#define FirstLog                       @"UserFirstLog"
#define UserTablelistViewOption        @"UserTablelistViewOption"
#define WizNoteAppVerSion              @"wizNoteAppVerSion"
#define ConnectServerOnlyByWif         @"ConnectServerOnlyByWif"
#define AutomicSync                     @"AutomicSync"
#define LastSynchronizedDate            @"LastSynchronizedDate"
#define NewNoteDefaultFolder            @"NewNoteDefaultFolder"
#define DefaultAccountUserID            @"DefaultAccountUserID"
#define DefaultGroupKbGuid              @"DefaultGroupKbGuid"

@interface WizDataBase : NSObject<WizDbDelegate, WizSettingsDbDelegate,WizAbstractDbDelegate>
{
    NSString* kbguid;
}
@property (atomic, retain) NSString* kbguid;
+ (WizDataBase*) shareDataBase;
@end
