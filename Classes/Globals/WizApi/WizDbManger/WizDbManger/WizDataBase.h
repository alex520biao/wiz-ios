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


//attachment

//tag

//
#define DataTypeUpdateKbGuid                    @"kb_guid"

#define KeyOfSyncVersion               @"SYNC_VERSION"
#define DocumentNameOfSyncVersion      @"DOCUMENT"
#define DeletedGUIDNameOfSyncVersion   @"DELETED_GUID"
#define AttachmentVersion              @"ATTACHMENTVERSION"
#define TagVersion                     @"TAGVERSION"
#define UserTrafficLimit               @"TRAFFICLIMIT"
#define UserTrafficUsage               @"TRAFFUCUSAGE"
#define KeyOfUserInfo                  @"USERINFO"
#define UserLevel                      @"USERLEVEL"
#define UserLevelName                  @"USERLEVELNAME"
#define UserType                       @"USERTYPE"
#define UserPoints                     @"USERPOINTS"
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
+ (id<WizDbDelegate>) shareDataBase;
- (BOOL) initDbWithModel:(NSDictionary*)model;
@end
