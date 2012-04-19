//
//  WizGlobalData.h
//  Wiz
//
//  Created by Wei Shijun on 3/9/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonString.h"

@class WizSync;
@class WizIndex;
@class WizCreateAccount;
@class WizVerifyAccount;
@class WizApi;
@class WizDocumentsByLocation;
@class WizDocumentsByTag;
@class WizDocumentsByKey;
@class WizDownloadRecentDocuments;
@class WizDocumentsByLocation;
@class WizSyncByTag;
@class WizSyncByKey;
@class WizSyncByLocation;
@class WizDownloadPool;
@class WizChangePassword;
@class WizSyncManager;
@class WizAccountManager;
@interface WizGlobalData : NSObject 

- (id) dataOfAccount: (NSString*) userId dataType: (NSString *) dataType;
- (void) setDataOfAccount: (NSString*) userId dataType: (NSString *) dataType data: (id) data;
- (WizSync *) syncData:(NSString*) userId;
- (WizCreateAccount *) createAccountData:(NSString*) userId;
- (WizVerifyAccount *) verifyAccountData:(NSString*) userId;
- (WizDocumentsByLocation *) documentsByLocationData:(NSString*) userId;
- (WizDocumentsByKey *) documentsByKeyData:(NSString*) userId;
- (WizDocumentsByTag *) documentsByTagData:(NSString*) userId;
- (WizDownloadRecentDocuments*) downloadRecentDocumentsData: (NSString*) userId;
- (WizIndex *) indexData:(NSString*) userId;
- (WizSyncByTag*) syncByTagData:(NSString*) userId;
- (void) removeShareObjectData:(NSString*) dataType   userId:(NSString*) userId;
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
//2012-4-16
- (WizSyncManager*) syncManger;
+ (NSString*) keyOfAccount:(NSString*) userId dataType: (NSString *) dataType;

//2012-3-2
- (void) stopSyncing;

- (WizAccountManager*)defaultAccountManager;
@end
