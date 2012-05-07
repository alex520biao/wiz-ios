//
//  WizGlobalData.h
//  Wiz
//
//  Created by Wei Shijun on 3/9/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonString.h"

@class WizCreateAccount;
@class WizVerifyAccount;
@class WizChangePassword;
@class WizSyncManager;
@class WizAccountManager;
@interface WizGlobalData : NSObject 
- (id) dataOfAccount: (NSString*) userId dataType: (NSString *) dataType;
- (void) setDataOfAccount: (NSString*) userId dataType: (NSString *) dataType data: (id) data;
- (WizCreateAccount *) createAccountData;
- (WizVerifyAccount *) verifyAccountData:(NSString*) userId;
- (void) removeShareObjectData:(NSString*) dataType   userId:(NSString*) userId;
- (UIImage*) documentIconWithoutData;
- (void) removeAccountData:(NSString*)userId;
- (NSDictionary*) attributesForDocumentListName;
- (NSDictionary*) attributesForAbstractViewParagraphPad;
- (NSNotificationCenter*) wizNotificationCenter;
+ (WizGlobalData*) sharedData;
+ (void) deleteShareData;
- (WizSyncManager*) syncManger;
+ (NSString*) keyOfAccount:(NSString*) userId dataType: (NSString *) dataType;
- (WizAccountManager*)defaultAccountManager;
- (WizChangePassword*) changePasswordData;
@end
