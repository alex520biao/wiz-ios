//
//  WizNotification.h
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizNotificationMessageType.h"
@interface WizSyncMessage : NSObject
{
    NSString* methodName;
    NSNumber* current;
    NSNumber* total;
}
@property (nonatomic, retain)   NSString* methodName;
@property (nonatomic, retain)   NSNumber* current;
@property (nonatomic, retain)   NSNumber* total;
-(id) initWithNotification:(NSNotification*)nc;
@end

@interface WizNotificationCenter : NSObject
+ (void) removeObserver:(id) observer;
+ (void) addObserverForSyncProceess:(id)observer     selector:(SEL)selector;
+ (void) removeObserverForSyncProceess:(id) observer;
+ (void) postWizGlobalSyncProcessInfo:(NSString*)typeOfMessage  infoData:(id)infoData;
+ (void) postSyncLoginBegin;
+ (void) postSyncLoginEnd;
+ (void) postSyncLogoutBegin;
+ (void) postSyncLogoutEnd;
+ (void) postSyncGetTagsListBegin:(int)beginVersion requsetCount:(int) requestCount;
+ (void) postSyncGetTagsListEnd:(int) lastVersion;
+ (void) postSyncUploadTagListBegin;
+ (void) postSyncUploadTagListEnd;
+ (void) postSyncGetAllCategoriesBegin;
+ (void) postSyncGetAllCategoriesEnd;
+ (void) postSyncGetAttachmentListBegin:(int)beginVersion requsetCount:(int) requestCount;
+ (void) postSyncGetAttachmentListEnd:(int) lastVersion;
+ (void) postSyncUploadAttachmentInfoBegin;
+ (void) postSyncUploadAttachmentInfoEnd;
+ (void) postSyncGetDocumentListBegin:(int)beginVersion requsetCount:(int) requestCount;
+ (void) postSyncGetDocumentListEnd:(int) lastVersion;
+ (void) postSyncUploadDocumentInfoBegin;
+ (void) postSyncUploadDocumentInfoEnd;
+ (void) postSyncDownloadDeletedListBegin;
+ (void) postSyncDownloadDeletedListEnd;
+ (void) postSyncUploadDeletedListBegin;
+ (void) postSyncUploadDeletedListEnd;
+ (void) postSyncGetDocumentByCategoryBegin;
+ (void) postSyncGetDocumentByCategoryEnd;
+ (void) postSyncGetDocumentByTagBegin;
+ (void) postSyncGetDocumentByTagEnd;
+ (void) postSyncGetDocumentByKeyBegin;
+ (void) postSyncGetDocumentByKeyEnd;
+ (void) postSyncDownloadDocument:(NSString*)guid current:(int)current  total:(int)total;
+ (void) postSyncDownloadAttachment:(NSString*)guid current:(int)current  total:(int)total;
+ (void) postSyncUploadDocument:(NSString*)guid current:(int)current  total:(int)total;
+ (void) postSyncUploadAttachment:(NSString*)guid current:(int)current  total:(int)total;
+ (WizSyncMessage*) getSyncMessage:(NSNotification*)nc;
+ (void) addObserverForDownloadDocument:(id)observer  selector:(SEL)selector  documentGUID:(NSString*)guid;
+ (void) addObserverForDownloadAttachment:(id)observer  selector:(SEL)selector  attachmentGUID:(NSString*)guid;
+ (void) removeObserverForDownloadDocument:(id)observer  selector:(SEL)selector  documentGUID:(NSString*)guid;
+ (void) removeObserverForDownloadAttachment:(id)observer  selector:(SEL)selector  attachmentGUID:(NSString*)guid;
@end
