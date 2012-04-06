//
//  WizNotificationCenter.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizNotificationCenter.h"
#import "WizNotificationMessageType.h"
#import "WizApi.h"
@implementation WizNotificationCenter
//single object
static WizNotificationCenter* shareCenter = nil;
+ (id) shareCenter
{
    @synchronized(shareCenter)
    {
        if (shareCenter == nil) {
            shareCenter = [[super allocWithZone:NULL] init];
        }
        return shareCenter;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareCenter] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}
- (oneway void) release
{
    return;
}
// over
+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareCenter];
    [nc addObserver:observer selector:selector name:name object:nil];
}
+ (void) removeObserver:(id) observer
{
    NSNotificationCenter* nc = [WizNotificationCenter shareCenter];
    [nc removeObserver:observer];
}
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareCenter];
    [nc removeObserver:observer name:name object:nil];
}
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey
{
    NSNotificationCenter* nc = [WizNotificationCenter shareCenter];
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
+ (void) addObserverForRegisterActiveAccount:(id)observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfRegisterActiveAccount];
}
+ (void) removeObserverForRegisterActiveAccount:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfRegisterActiveAccount];
}
+ (void) postResisterActiveAccount
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfRegisterActiveAccount userInfoObject:nil userInfoKey:nil];
}

+ (void) addObserverForTokenUnactive:(id)observer selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfTokenUnactive];
}

+ (void) postTokenUnaciveWithErrorWizApi:(WizApi*)api
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfTokenUnactive userInfoObject:api userInfoKey:UserInfoTypeOfWizApi];
}
+ (WizApi*) getErrorWizApiFromNc:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    @try {
        return  [userInfo valueForKey:UserInfoTypeOfWizApi];
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }
    
}
//
+ (void) addObserverForRefreshToken:(id)observer     selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MesageTypeOfRefrshToken];
}
+ (void) removeObserverForReshreshToken:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MesageTypeOfRefrshToken];
}

+ (void) postRefreshLogKeys:(NSDictionary*)dic
{
    [WizNotificationCenter postMessageWithName:MesageTypeOfRefrshToken userInfoObject:dic userInfoKey:UserInfoTypeOfLogKeys];
}
+ (NSDictionary*) getRefrshLogKeys:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    return [userInfo valueForKey:UserInfoTypeOfLogKeys];
}
//
+ (void) addObserverForDownloadDone:(id)observer    selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfDonwloadDone];
}
+ (void) removeObserverForDownloadDone:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfDonwloadDone];
}

+ (void) postDownloadDoneMassage:(NSString*)guid
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfDonwloadDone userInfoObject:guid userInfoKey:UserInfoTypeOfDownloadGUID];
}
+ (NSString*) getDownloadGUID:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    return [userInfo valueForKey:UserInfoTypeOfDownloadGUID];
}
//

+ (void) addObserverForServerError:(id)observer   selector:(SEL)selector
{
    [WizNotificationCenter addObserverWithKey:observer selector:selector name:MessageTypeOfServerError];
}

+ (void) removeObserverForServerError:(id)observer
{
    [WizNotificationCenter removeObserverWithKey:observer name:MessageTypeOfServerError];
}

+ (void) postServerErrorMessageWithErrorApi:(WizApi*)api
{
    [WizNotificationCenter postMessageWithName:MessageTypeOfServerError userInfoObject:api userInfoKey:UserInfoTypeOfWizApi];
}

@end