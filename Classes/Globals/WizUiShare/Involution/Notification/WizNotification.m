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
        [nc postNotificationName:messageName object:nil userInfo:nil];
    }
    else {
        [nc postNotificationName:messageName object:nil userInfo:[NSDictionary dictionaryWithObject:infoObject forKey:infoKey]];
    }
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
@end
