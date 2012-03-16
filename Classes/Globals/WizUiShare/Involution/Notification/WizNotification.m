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
+ (void) removeObserverWithKey:(id) observer name:(NSString*)name
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    [nc removeObserver:observer name:name object:nil];
}

+ (void) postNewDocumentMessage:(NSString*)documentGUID
{
    NSNotificationCenter* nc = [[WizGlobalData sharedData] wizNotificationCenter];
    [nc postNotificationName:MessageTypeOfNewDocument object:nil userInfo:[NSDictionary dictionaryWithObject:documentGUID forKey:UserInfoTypeOfDocumentGUID]];
}
+ (NSString*) getNewDocumentGUIDFromMessage:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    return [userInfo objectForKey:UserInfoTypeOfDocumentGUID];
}
@end
