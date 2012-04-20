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
@class WizChangePassword;
@class WizSyncManager;
@class WizAccountManager;
@interface WizGlobalData : NSObject 

- (id) dataOfAccount: (NSString*) userId dataType: (NSString *) dataType;
- (void) setDataOfAccount: (NSString*) userId dataType: (NSString *) dataType data: (id) data;
- (WizSync *) syncData:(NSString*) userId;
- (WizCreateAccount *) createAccountData:(NSString*) userId;
- (WizVerifyAccount *) verifyAccountData:(NSString*) userId;
- (WizIndex *) indexData:(NSString*) userId;
- (void) removeShareObjectData:(NSString*) dataType   userId:(NSString*) userId;
- (UIImage*) documentIconWithoutData;
- (void) removeAccountData:(NSString*)userId;
- (WizChangePassword*) dataOfChangePassword:(NSString*)userId;
//2012-2-25
- (NSDictionary*) attributesForDocumentListName;
- (NSDictionary*) attributesForAbstractViewParagraphPad;
//2012-3-9
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
