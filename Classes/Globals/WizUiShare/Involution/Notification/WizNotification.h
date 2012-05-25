//
//  WizNotification.h
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizNotificationMessageType.h"
@interface WizNotificationCenter : NSObject
//
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey;
//
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
+ (void) addObserverForIphoneSetupAccount:(id)observer  selector:(SEL)selector;
+ (void) postIphoneSetupAccount;
//
+ (void) addObserverForDeleteDocument:(id) observer selector:(SEL)selector;
+ (void) removeObserverForDeleteDocument:(id)observer;
+ (WizDocument*) getWizDocumentFromNc:(NSNotification*)nc;
+ (void) postDeleteDocumentMassage:(WizDocument*)document;
+ (NSString*) getDeleteDocumentGUIDFromNc:(NSNotification*)nc;
//
+ (void) addObserverForUpdateDocument:(id) observer selector:(SEL)selector;
+ (void) postUpdateDocument:(NSString*)documentGUID;
+ (void) removeObserverForUpdateDocument:(id) observer;
+ (NSString*) getDocumentGUIDFromNc:(NSNotification*)nc;

//
+ (void) postUpdateFolder:(NSString*)folderKey;
+ (void) addObserverForUpdateFolder:(id)observer    selector:(SEL)selector;
+ (void) removeObserverForUpdateFolder:(id)observer;
+ (NSString*) getFolderKeyFromNc:(NSNotification*)nc;

//
+ (void) addObserverForUploadDone:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForUploadDone:(id)observer;
+ (void) postMessageUploadDone:(NSString*)guid;
+ (NSString*) uploadGuidFromNc:(NSNotification*)nc;

//
+ (void) addObserverForRefreshToken:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForRefreshToken:(id)observer;
+ (void) postMessageRefreshToken:(NSDictionary*)dic;
+ (NSDictionary*) getRefreshTokenDicFromNc:(NSNotification*)nc;
//
+ (void) addObserverForTokenUnactiveError:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForTokenUnactiveError:(id)observer;
+ (void) postMessageTokenUnactiveError;
//
+ (void) addObserverForDownloadDone:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForDownloadDone:(id)observer;
+ (void) postMessageDownloadDone:(NSString*)guid;
+ (NSString*) downloadGuidFromNc:(NSNotification*)nc;
//
+ (void) addObserverForAccountOperation:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForAccountOperation:(id)observer;
+ (void) postMessageAccountOperation:(BOOL)secceed;
+ (BOOL) isAccountOperationSucceedFromNc:(NSNotification*)nc;
//
+ (void) addObserverForUpdateCache:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForUpdateCache:(id)observer;
+ (void) postMessageUpdateCache:(NSString*)documentGuid;
//
+ (void) addObserverForChangeUser:(id)observer  selector:(SEL)selector;
+ (void) removeObserverForChangUser:(id)observer;
+ (void) postMessageChangedUser;
//
+ (void) postupdateDocumentListMessage;
+ (void) addObserverForUpdateDocumentList:(id)observer selector:(SEL)selector;
+ (void) removeObserverForUpdateDocumentList:(id)observer;
//
+ (void) postSimpleMessageWithName:(NSString*)messageName;
@end
