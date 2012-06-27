//
//  WizAccountManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizAccount.h"


#import "WizGlobalData.h"
#import "WizSyncManager.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
#import "WizNotification.h"
#import "WizAbstractCache.h"
#import "WizGroup.h"

#define SettingsFileName            @"settings.plist"
#define KeyOfAccounts               @"accounts"
#define KeyOfUserId                 @"userId"
#define KeyOfPassword               @"password"
#define KeyOfDefaultUserId          @"defaultUserId"
#define KeyOfProtectPassword        @"protectPassword"
#define KeyOfKbguids                @"KeyOfKbguids"



//
@interface WizAccountManager()
{
    WizAccount* activeAccount_;
    WizGroup*  activeGroup;
    NSTimer* timer;
    id<WizSettingsDbDelegate> dataBase;
}
@property (nonatomic, retain) NSTimer* timer;
@property (nonatomic, retain) WizAccount* activeAccount_;
@property (nonatomic, retain) WizGroup*  activeGroup;
@property (assign)  id<WizSettingsDbDelegate> dataBase;
@end

@implementation WizAccountManager
@synthesize timer;
@synthesize activeAccount_;
@synthesize activeGroup;
@synthesize dataBase;

-(id) init
{
	if (self = [super init])
	{
        self.dataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
	}
	return self;
}
-(void)dealloc
{
	[super dealloc];
}

+(WizAccountManager *) defaultManager
{
	return [[WizGlobalData sharedData] defaultAccountManager];
}

- (BOOL) isAccountExist:(NSString *)accountUserId
{
    return [self.dataBase accountFromUserId:accountUserId]?YES:NO;
}

-(BOOL) updateAccount: (NSString*)userId password:(NSString*)password
{
    password = [WizGlobals encryptPassword:password];
   return [self.dataBase updateAccount:userId password:password];
}

- (NSString*) activeAccountPassword
{
    return self.activeAccount_.password;
}
- (NSString*) activeAccountUserId
{
    return self.activeAccount_.userId;
}
- (BOOL) logoutAccount:(NSString *)userId
{
    [[WizSyncManager shareManager] stopSync];
    [[WizDbManager shareDbManager] removeUnactiveDatabase:userId];
    return [self.dataBase setWizDefaultAccountUserId:@""];
}


-(BOOL) removeAccount: (NSString*)userId
{
    if ([self.dataBase deleteAccountByUserId:userId]) {
        [self.dataBase deleteAccountGroups:userId];
        [[WizFileManager shareManager]  removeActiveAccountData];
    }
    return [self logoutAccount:userId];
}

- (NSArray*) accounts
{
     return [self.dataBase allAccounts];
}


- (BOOL) registerActiveAccount:(NSString *)accountUserId
{
    self.activeAccount_ = [self.dataBase accountFromUserId:accountUserId];
    if (![self.dataBase setWizDefaultAccountUserId:self.activeAccount_.userId]) {
        NSLog(@" set default account error %@",accountUserId);
    }
    [self.dataBase setWizDefaultAccountUserId:self.activeAccount_.userId];
//    [[WizSyncManager shareManager] refreshToken];
    return YES;
}

- (BOOL) updateGroups:(NSArray*)groupArray
{
    if ([self.dataBase deleteAccountGroups:self.activeAccount_.userId]) {
        if ([self.dataBase updateGroups:groupArray accountUserId:self.activeAccount_.userId]) {
            [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfRefreshGroupsData];
            return YES;
        }
    };
    return NO;
}
- (NSArray*) activeAccountGroupsWithoutSection
{
    return [self.dataBase groupsByAccountUserId:self.activeAccount_.userId];
}
- (NSArray*) activeAccountGroups
{
    NSArray* allGroups = [self.dataBase groupsByAccountUserId:self.activeAccount_.userId];
    static NSPredicate* personPre = nil;
    static NSPredicate* groupPre = nil;
    if (!personPre) {
        personPre = [[NSPredicate predicateWithFormat:@"kbType == %@",KeyOfKbTypePrivate] retain];
    }
    if (!groupPre) {
        groupPre = [[NSPredicate predicateWithFormat:@"kbType != %@", KeyOfKbTypePrivate] retain];
    }
    return  [NSArray arrayWithObjects:[allGroups filteredArrayUsingPredicate:personPre],[allGroups filteredArrayUsingPredicate:groupPre], nil];
}
- (NSString*) activeAccountGroupKbguid
{
    return self.activeGroup.kbguid;
}
- (BOOL) registerActiveGroup:(NSString *)kbGuid
{
    WizGroup* group = [self.dataBase groupFromGuid:kbGuid accountUserId:self.activeAccount_.userId];
    [[WizSyncManager shareManager] registerAciveGroup:group.kbguid];
    self.activeGroup = group;
    if (group) {
        return YES;
    }
    else
    {
        return NO;
    }
}
- (WizGroup*)activeAccountActiveGroup
{
    return self.activeGroup;
}

- (NSString*)defualtAccountUserId
{
    return [self.dataBase defaultAccountUserId];
}
- (BOOL) updatePrivateGroups:(NSString *)kbguid accountUserId:(NSString *)userId
{
    if (!userId) {
        userId = [NSString stringWithString:self.activeAccount_.userId];
    }
    return [self.dataBase updatePrivateGroup:kbguid accountUserId:self.activeAccount_.userId];
}


@end
