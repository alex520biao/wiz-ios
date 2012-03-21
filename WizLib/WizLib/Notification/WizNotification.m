//
//  WizNotification.m
//  Wiz
//
//  Created by wiz on 12-3-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizNotification.h"
#import "WizGlobalData.h"
@interface WizNotificationCenter()
+ (NSNotificationCenter*) shareNotificationCenter;
+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name;
+ (id) getMessgeInfoForKey:(NSString*)key   notification:(NSNotification*)nc;
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey;
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name;
@end



@implementation WizNotificationCenter
static  NSNotificationCenter* shareNotificationCenter;
+ (NSNotificationCenter*) shareNotificationCenter
{
    if (shareNotificationCenter == nil) {
        shareNotificationCenter = [[NSNotificationCenter alloc] init];
    }
    return shareNotificationCenter;
}
+ (void) addObserverWithKey:(id)observer selector:(SEL)selector name:(NSString *)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    
    [nc addObserver:observer selector:selector name:name object:nil];
}
+ (void) removeObserver:(id) observer
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    [nc removeObserver:observer];
}
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
    [nc removeObserver:observer name:name object:nil];
}
+ (void) postMessageWithName:(NSString*)messageName userInfoObject:(id)infoObject userInfoKey:(NSString*)infoKey
{
    NSNotificationCenter* nc = [WizNotificationCenter shareNotificationCenter];
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

@end
