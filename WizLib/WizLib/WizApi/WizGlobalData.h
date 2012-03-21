//
//  WizGlobalData.h
//  Wiz
//
//  Created by Wei Shijun on 3/9/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
extern  NSString* DataTypeOfSync;
extern NSString* DataTypeOfCreateAccount ;
extern NSString* DataTypeOfVerifyAccount ;

extern NSString* DataTypeOfDocumentsByLocation ;
extern NSString* DataTypeOfDocumentsByTag ;
extern NSString* DataTypeOfDownloadRecentDocuments ;
extern NSString* DataTypeOfDocumentsByKey ;

//wiz-dzpqzb test

extern NSString* DataTypeOfDownloadObject;
extern NSString* DataTypeOfUploadObject;
extern NSString* DataTypeOfUploadDocument;
extern NSString* DataTypeOfUploadAttachment ;

extern NSString* DataTypeOfDownloadDocument ;
extern NSString* DataTypeOfDownloadAttachment ;
extern NSString* DataTypeOfIndex;

extern NSString* DataTypeOfPickerView;
extern NSString* DataTypeOfLoginView ;

extern NSString* DataMainOfWiz;
#define DataOfAttributesForDocumentListName                 @"attributesForDocumentListName"
#define WizGlobalAccount                                    @"DataOfGlobalShareDataWiz"
#define DataOfAttributesForPadAbstractViewParagraph         @"DataOfAttributesForPadAbstractViewParagraph"
#define DataOfActiveAccountUserId                           @"DataOfActiveAccountUserId"
#define DataOfGlobalWizNotification                         @"DataOfGlobalWizNotification"
@class WizSync;
@class WizIndex;
@class WizCreateAccount;
@class WizVerifyAccount;
@class WizApi;
@class WizDocumentsByLocation;
@class WizDocumentsByTag;
@class WizDocumentsByKey;
@class WizDownloadRecentDocuments;
@class WizDownloadObject;
@class WizUploadObjet;
@class WizUploadDocument;
@class WizUploadAttachment;
@class LoginViewController;
@class PickerViewController;
@class WizDownloadAttachment;
@class WizDownloadDocument;
@class WizDocumentsByLocation;
@class WizSyncByTag;
@class WizSyncByKey;
@class WizSyncByLocation;
@class WizDownloadPool;
@class WizChangePassword;
@interface WizGlobalData : NSObject {
	NSMutableDictionary* dict;
}
@property (nonatomic, retain) NSMutableDictionary* dict;

- (id) dataOfAccount: (NSString*) userId dataType: (NSString *) dataType;
- (void) setDataOfAccount: (NSString*) userId dataType: (NSString *) dataType data: (id) data;
- (WizSync *) syncData:(NSString*) userId;
- (WizCreateAccount *) createAccountData:(NSString*) userId;
- (WizVerifyAccount *) verifyAccountData:(NSString*) userId;
- (WizDocumentsByLocation *) documentsByLocationData:(NSString*) userId;
- (WizDocumentsByKey *) documentsByKeyData:(NSString*) userId;
- (WizDocumentsByTag *) documentsByTagData:(NSString*) userId;
- (WizDownloadRecentDocuments*) downloadRecentDocumentsData: (NSString*) userId;
- (WizDownloadObject *) downloadObjectData:(NSString*) userId;
- (WizUploadObjet*) uploadObjectData:(NSString*) userId;
- (WizIndex *) indexData:(NSString*) userId;
- (WizUploadAttachment*) uploadAttachmentData:(NSString*) userId attachmentGUID:(NSString*) attachmentGUID owner:(id)owner;
- (WizUploadDocument*) uploadDocumentData:(NSString*) userId documentGUID:(NSString*) documentGUID owner:(WizApi*) owner;
- (PickerViewController*) wizPickerViewOfUser:(NSString*) userId;
- (LoginViewController*) wizMainLoginView:(NSString*) userId;
- (WizSyncByTag*) syncByTagData:(NSString*) userId;
- (WizDownloadDocument*) downloadDocumentData:(NSString*) userId;
- (void) removeShareObjectData:(NSString*) dataType   userId:(NSString*) userId;
- (WizDownloadAttachment*) downloadAttachmentData:(NSString*) userId;
- (UIImage*) documentIconWithoutData;
- (WizSyncByKey*) syncByKeyData:(NSString*) userId;
- (WizSyncByLocation*) syncByLocationData:(NSString*) userId;
- (void) removeAccountData:(NSString*)userId;
- (WizDownloadPool*) globalDownloadPool:(NSString *)userId;
- (WizChangePassword*) dataOfChangePassword:(NSString*)userId;
//2012-2-25
- (NSDictionary*) attributesForDocumentListName;
- (NSDictionary*) attributesForAbstractViewParagraphPad;
//2012-3-9
- (BOOL) registerActiveAccountUserId:(NSString*)userId;
- (NSString*) activeAccountUserId;
//2012-3-15
- (NSNotificationCenter*) wizNotificationCenter;
+ (WizGlobalData*) sharedData;
+ (void) deleteShareData;

+ (NSString*) keyOfAccount:(NSString*) userId dataType: (NSString *) dataType;

//2012-3-2
- (void) stopSyncing;

@end
