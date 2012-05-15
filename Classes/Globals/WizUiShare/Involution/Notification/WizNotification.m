//
//  WizNotification.m
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizNotification.h"
#import "WizGlobalData.h"
@implementation WizNotificationCenter

+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    [nc addObserver:observer selector:selector name:name object:nil];
}
+ (void) removeObserver:(id) observer
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    [nc removeObserver:observer];
}
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    [nc removeObserver:observer name:name object:nil];
}
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    if (infoKey == nil || infoObject == nil) {
        [nc  postNotificationName:messageName object:nil userInfo:nil];
    }
    else {
        [nc postNotificationName:messageName object:nil userInfo:[NSDictionary dictionaryWithObject:infoObject forKey:infoKey]];
    }
}
+ (void) postSimpleMessageWithName:(NSString*)messageName
{
    [WizNotificationCenter postMessageWithName:messageName userInfoObject:nil userInfoKey:nil];
}
+ (id) getMessgeInfoForKey:(NSString*)key   notification:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    return [userInfo objectForKey:key];
}
+ (void) postNewDocumentMessage:(NSString*)documentGUID
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfNewDocument userInfoObject:documentGUID userInfoKey:UserInfoTypeOfDocumentGUID];
}
+ (NSString*) getNewDocumentGUIDFromMessage:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfDocumentGUID notification:nc];
}
+ (void) addObserverForNewDocument:(id) observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfNewDocument];
}
+ (void) postDidSelectedAccountMessage:(NSString*)accountUserId
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfDidSelectedAccount userInfoObject:accountUserId userInfoKey:MessageTypeOfDidSelectedAccount];
}
+ (NSString*) getDidSelectedAccountUserId:(NSNotification*)nc
{
    id accountUserId = [WizNotificationCenter getMessgeInfoForKey:MessageTypeOfDidSelectedAccount notification:nc];
    if ([accountUserId isKindOfClass:[NSString class]]) {
        return accountUserId;
    }
    else {
        return nil;
    }
    
}
+ (void) postChangeAccountMessage
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfChangeAccount userInfoObject:nil userInfoKey:nil];
}
+ (void) addObserverForChangeAccount:(id)observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfChangeAccount];
}
+ (void) postPadSelectedAccountMessge:(NSString*)accountUserId
{
   [WizNotificationCenter postMessageWithName:MessageTypeOfPadSendSelectedAccountMessage userInfoObject:accountUserId userInfoKey:MessageTypeOfDidSelectedAccount];
}
+ (void) addObserverForPadSelectedAccount:(id)observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfPadSendSelectedAccountMessage];
}
+ (void) addObserverForIphoneSetupAccount:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfIphoneSetupAccount];
}

+ (void) postIphoneSetupAccount
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfIphoneSetupAccount userInfoObject:nil userInfoKey:nil];
}
//
+ (void) addObserverForDeleteDocument:(id) observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfDeleteDocument];
}
+ (void) removeObserverForDeleteDocument:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfDeleteDocument];
}
+ (void) postDeleteDocumentMassage:(NSString*)documentGUID
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfDeleteDocument userInfoObject:documentGUID userInfoKey:UserInfoTypeOfDocumentGUID];
}
+ (NSString*) getDeleteDocumentGUIDFromNc:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfDocumentGUID notification:nc];
}
+ (void) addObserverForUpdateDocument:(id) observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfUpdateDocument];
}
+ (void) postUpdateDocument:(NSString*)documentGUID
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfUpdateDocument userInfoObject:documentGUID userInfoKey:UserInfoTypeOfDocumentGUID];
}
+ (void) removeObserverForUpdateDocument:(id) observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfUpdateDocument];
}
+ (NSString*) getDocumentGUIDFromNc:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfDocumentGUID notification:nc];
}
+ (void) postUpdateFolder:(NSString*)folderKey
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfUpdateFolder userInfoObject:folderKey userInfoKey:UserInfoTypeOfFolder];
}
+ (void) addObserverForUpdateFolder:(id)observer    selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfUpdateFolder];
}
+ (void) removeObserverForUpdateFolder:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfUpdateFolder];
}
+ (NSString*) getFolderKeyFromNc:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfFolder notification:nc];
}
//
+ (void) addObserverForUploadDone:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfUploadDone];
}
+ (void) removeObserverForUploadDone:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfUploadDone];
}
+ (void) postMessageUploadDone:(NSString*)guid
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfUploadDone userInfoObject:guid userInfoKey:UserInfoTypeOfGuid];
}
+ (NSString*) uploadGuidFromNc:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfGuid notification:nc];
}
//
+ (void) addObserverForRefreshToken:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfRefreshToken];
}
+ (void) removeObserverForRefreshToken:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfRefreshToken];
}
+ (void) postMessageRefreshToken:(NSDictionary*)dic
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfRefreshToken userInfoObject:dic userInfoKey:UserInfoTypeOfRefreshToken];
}
+ (NSDictionary*) getRefreshTokenDicFromNc:(NSNotification*)nc
{
    return  [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfRefreshToken notification:nc];
}
//
+ (void) addObserverForTokenUnactiveError:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfTokenUnactive];
}
+ (void) removeObserverForTokenUnactiveError:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfTokenUnactive];
}
+ (void) postMessageTokenUnactiveError
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfTokenUnactive userInfoObject:nil userInfoKey:nil];
}
//
+ (void) addObserverForDownloadDone:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfDownloadDone];
}
+ (void) removeObserverForDownloadDone:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfDownloadDone];
}
+ (void) postMessageDownloadDone:(NSString*)guid
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfDownloadDone userInfoObject:guid userInfoKey:UserInfoTypeOfGuid];
}
+ (NSString*) downloadGuidFromNc:(NSNotification*)nc
{
    return [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfGuid notification:nc];
}
+ (void) addObserverForAccountOperation:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfLoginDone];
}
+ (void) removeObserverForAccountOperation:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfLoginDone];
}
+ (void) postMessageAccountOperation:(BOOL)secceed
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfLoginDone userInfoObject:[NSNumber numberWithBool:secceed] userInfoKey:UserInfoTypeOfLoginSucceed];
}
+ (BOOL) isAccountOperationSucceedFromNc:(NSNotification*)nc
{
    NSNumber* ret = [WizNotificationCenter getMessgeInfoForKey:UserInfoTypeOfLoginSucceed notification:nc];
    if (ret == nil) {
        return NO;
    }
    return [ret boolValue];
}
+ (void) addObserverForUpdateCache:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfUpdateCache];
}
+ (void) removeObserverForUpdateCache:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfUpdateCache];
}
+ (void) postMessageUpdateCache:(NSString*)documentGuid
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfUpdateCache userInfoObject:documentGuid userInfoKey:UserInfoTypeOfDocumentGUID];
}
+ (void) addObserverForChangeUser:(id)observer  selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfChangedUser];
}
+ (void) removeObserverForChangUser:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfChangedUser];
}
+ (void) postMessageChangedUser
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfChangedUser userInfoObject:nil userInfoKey:nil];
}

//
+ (void) postupdateDocumentListMessage
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfUpdateDocumentList userInfoObject:nil userInfoKey:nil];
}

+ (void) addObserverForUpdateDocumentList:(id)observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfUpdateDocumentList];
}

+ (void) removeObserverForUpdateDocumentList:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfUpdateDocumentList];
}
@end
