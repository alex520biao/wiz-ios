//
//  WizNoticationMessageType.h
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



#define WizSyncBeginNotificationPrefix                  @"WizSyncBeginNotification"  
#define WizSyncEndNotificationPrefix                    @"WizSyncEndNotification"  
#define WizSyncXmlRpcErrorNotificationPrefix            @"WizSyncXmlRpcErrorNotificationPrefix"  
#define WizSyncXmlRpcDoneNotificationPrefix             @"WizSyncXmlRpcDoneNotification"  
#define WizSyncXmlRpcDonlowadDoneNotificationPrefix     @"WizSyncXmlRpcDonlowadDoneNotificationPrefix"  
#define WizSyncXmlRpcUploadDoneNotificationPrefix       @"WizSyncXmlRpcUploadDoneNotificationPrefix"  
#define WizGlobalSyncProcessInfo                        @"wiz_global_sync_process_info" 




#define MessageTypeSyncMethodName                       @"sync_method_name"
#define MessageTypeSyncProcessTotal                     @"sync_method_total"
#define MessageTypeSyncProcessCurrent                   @"sync_method_current"

#define MessageTypeSyncLogin                            @"MessageTypeSyncLogin"
#define MessageTypeSyncLogOut                           @"MessageTypeSyncLogOut"
#define MessageTypeSyncGetUserInfo                      @"MessageTypeSyncGetUserInfo"
#define MessageTypeSyncSyncFolders                      @"MessageTypeSyncSyncFolders"
#define MessageTypeSyncUploadTags                         @"MessageTypeSyncSyncUploadTags"
#define MessageTypeSyncDownloadTags                         @"MessageTypeSyncSyncDownloadTags"
#define MessageTypeSyncDownloadDocument                 @"MessageTypeSyncDownloadDocument"
#define MessageTypeSyncDownloadAttachment               @"MessageTypeSyncDownloadAttachment"
#define MessageTypeSyncUploadDocument                   @"MessageTypeSyncUploadDocument"
#define MessageTypeSyncUploadAttachment                 @"MessageTypeSyncUploadAttachment"
#define MessageTypeSyncUploadAttachmentInfo @"MessageTypeSyncUploadAttachmentInfo"
#define MessageTypeSyncUploadDocumentInfo @"MessageTypeSyncUploadDocumentInfo"
#define MessageTypeSyncDocumentList         @"MessageTypeSyncDocumentList"
#define MessageTypeSyncDownloadDeletedList  @"MessageTypeSyncDownloadDeletedList"
#define MessageTypeSyncUploadDeletedList    @"MessageTypeSyncUploadDeletedList"
#define MessageTypeSyncGetDocumentListByFolder @"MessageTypeSyncGetDocumentListByFolder"
#define MessageTypeSyncGetDocumentListByTag @"MessageTypeSyncGetDocumentListByTag"
#define MessageTypeSyncGetDocumentListByKey @"MessageTypeSyncGetDocumentListByKey"