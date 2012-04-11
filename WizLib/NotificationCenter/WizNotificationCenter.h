//
//  WizNotificationCenter.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizApi;
@interface WizNotificationCenter : NSNotificationCenter
+(void) addObserverWithKey:(id)observer selector:(SEL)selector  name:(NSString*)name;
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name;
+ (void) postNewDocumentMessage:(NSString*)documentGUID;
+ (NSString*) getNewDocumentGUIDFromMessage:(NSNotification*)nc;
+ (void) postDidSelectedAccountMessage:(NSString*)accountUserId;
+ (NSString*) getDidSelectedAccountUserId:(NSNotification*)nc;
+ (void) postChangeAccountMessage;
+ (void) addObserverForChangeAccount:(id)observer selector:(SEL)selector;
+ (void) removeObserver:(id) observer;
+ (void) postPadSelectedAccountMessge:(NSString*)accountUserId;
+ (void) addObserverForPadSelectedAccount:(id)observer selector:(SEL)selector;
+ (void) addObserverForNewDocument:(id) observer selector:(SEL)selector;
+ (void) addObserverForRegisterActiveAccount:(id)observer selector:(SEL)selector;
+ (void) removeObserverForRegisterActiveAccount:(id)observer;
+ (void) postResisterActiveAccount;
//
+ (void) addObserverForTokenUnactive:(id)observer selector:(SEL)selector;
+ (void) postTokenUnaciveWithErrorWizApi:(WizApi*)api;
+ (WizApi*) getErrorWizApiFromNc:(NSNotification*)nc;
+ (void) addObserverForRefreshToken:(id)observer     selector:(SEL)selector;
+ (void) removeObserverForReshreshToken:(id)observer;
+ (void) postRefreshLogKeys:(NSDictionary*)dic;
+ (NSDictionary*) getRefrshLogKeys:(NSNotification*)nc;
//
+ (void) addObserverForDownloadDone:(id)observer    selector:(SEL)selector;
+ (void) removeObserverForDownloadDone:(id)observer;
+ (void) postDownloadDoneMassage:(NSString*)guid;
+ (NSString*) getDownloadGUID:(NSNotification*)nc;
//
+ (void) addObserverForServerError:(id)observer   selector:(SEL)selector;
+ (void) removeObserverForServerError:(id)observer;
+ (void) postServerErrorMessageWithErrorApi:(WizApi*)api;
//
+ (void) addObserverForUploadDone:(id)observer    selector:(SEL)selector;
+ (void) removeObserverForUploadDone:(id)observer;
+ (void) postUploadDoneMassage:(NSString*)guid;
+ (NSString*) getUploaddGUID:(NSNotification*)nc;
@end
