//
//  WizAccount.m
//  Wiz
//
//  Created by 朝 董 on 12-6-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccount.h"
#import "WizAccountManager.h"
#import "WizSyncManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"
#define KeyOfKbguids                @"KeyOfKbguids"
@interface WizAccount()
{
    WizGroup* activeKb;
}
@property (atomic, retain) WizGroup* activeKb;
@end

@implementation WizAccount
@synthesize activeKb;
@synthesize userId;
@synthesize password;
@synthesize groups;

- (void) dealloc
{
    [activeKb release];
    [userId release];
    [password release];
    [groups release];
    [super dealloc];
}

- (WizAccount*) initWithUserId:(NSString*)userId_  password:(NSString*)password_  kgguids:(NSArray*)kbguids_
{
    self = [super init];
    if (self) {
        self.userId = userId_;
        self.password = password_;
        if (!kbguids_) {
            self.groups = [NSArray array];
        }
        else {
            NSMutableArray* array  = [NSMutableArray array];
            for (NSDictionary* each in kbguids_) {
                WizGroup* group = [[WizGroup alloc] groupFromDicionary:each];
                if (group.type == WizKbguidPrivateType) {
                    self.activeKb = group;
                }
            [array addObject:group];
            }
        self.groups = array;
        }
    }
    return self;
}

- (WizAccount*) initAccountFromDic:(NSDictionary*)dic
{
    self = [super init];
    if(self)
    {
        self.userId = [dic valueForKey:KeyOfUserId];
        self.password = [dic valueForKey:KeyOfPassword];
        NSArray* array = [dic valueForKey:KeyOfKbguids];
        if (array == nil) {
            self.groups = [NSArray array];
        }
        else {
            NSMutableArray* groupsArray = [NSMutableArray array];
            for (NSDictionary* each in array) {
                WizGroup* group = [[WizGroup alloc] groupFromDicionary:each];
                if (group.type == WizKbguidPrivateType) {
                    self.activeKb = group;
                }
                [groupsArray addObject:group];
            }
            self.groups = groupsArray;
        }
    }
    return self;
}

- (NSDictionary*) accountDictionaryData
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithCapacity:3];
    [dic setObject:self.userId forKey:KeyOfUserId];
    [dic setObject:self.password forKey:KeyOfPassword];
    NSMutableArray* groupData = [NSMutableArray array];
    for (WizGroup* each in self.groups) {
        NSDictionary* groupDic = [each dictionaryWithGropuData];
        [groupData addObject:groupDic];
    }
    [dic setObject:groupData forKey:KeyOfKbguids];
    return dic;
}
- (BOOL) isEqualToAccountDictionaryData:(NSDictionary*)data
{
    NSString* userIDD = [data valueForKey:KeyOfUserId];
    if (!userIDD) {
        return NO;
    }
    if ([userIDD isEqualToString:self.userId]) {
        return YES;
    }
    return NO;
}
- (void) updateWizGroup:(WizGroup*)group
{
    if (!self.groups) {
        self.groups = [NSArray arrayWithObject:group];
    }
    else {
        NSMutableArray* array = [NSMutableArray arrayWithArray:self.groups];
        NSInteger i = 0;
        for (i = 0; i < [array count]; i++) {
            WizGroup* group_ =[array objectAtIndex:i];
            if ([group.guid isEqualToString:group_.guid]) {
                [array replaceObjectAtIndex:i withObject:group];
                break;
            }
        }
        if (i == [array count]) {
            [array addObject:group];
        }
        self.groups = array;
        NSLog(@"group count is %d",[self.groups count]);
    }
    [[WizAccountManager defaultManager] updateAccount:self];
}

- (BOOL) registerActiveKbguid:(WizGroup *)kb
{
    self.activeKb = kb;
    [[WizSyncManager shareManager] stopSync];
    [[[WizDbManager shareDbManager] shareDataBase] reloadDb];
    return YES;
}

- (WizGroup*) activeGroup
{
    return self.activeKb;
}
@end
