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
    NSString* activeAccountUserId_;
    NSTimer* timer;
}
@property (nonatomic, retain) NSTimer* timer;
@property (atomic, retain) NSString* activeAccountUserId_;
@end

@implementation WizAccountManager
@synthesize timer;
@synthesize activeAccountUserId_;
//upgrade from 3.1.1
- (void) upgradePreDataToNewDbModel
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    
    NSString* accountsFilePath = [[WizFileManager documentsPath] stringByAppendingPathComponent:SettingsFileName];
    if ([fileManager fileExistsAtPath:accountsFilePath]) {
        NSDictionary* accountsData = [NSDictionary dictionaryWithContentsOfFile:accountsFilePath];
        if (accountsData)
        {
            id<WizSettingsDbDelegate> settingDataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
            NSArray* accountsArray = [accountsData valueForKey:KeyOfAccounts];
            for (NSDictionary* account in accountsArray)
            {
                NSString* accountUserId = [account valueForKey:KeyOfUserId];
                NSString* accountPassword = [account valueForKey:KeyOfPassword];
                if (nil != accountUserId && nil != accountPassword) {
                    [settingDataBase updateAccount:accountUserId password:accountPassword];
                }
            }
            NSString* defaultUserId = [accountsData valueForKey:KeyOfDefaultUserId];
            if (defaultUserId) {
                [settingDataBase setWizDefaultAccountUserId:defaultUserId];
            }
        }
        NSError* error = nil;
        if (![fileManager removeItemAtPath:accountsFilePath error:&error]) {
            NSLog(@"error %@",error);
        }
    }
}
//over
-(NSString*) settingsFileName
{
	NSString* filename = [[WizFileManager  documentsPath] stringByAppendingPathComponent:SettingsFileName];
	return filename;
}
-(id) init
{
	if (self = [super init])
	{
        [self upgradePreDataToNewDbModel];
	}
	return self;
}
-(void)dealloc
{
	[activeAccountUserId_ release];
	[super dealloc];
}


+(WizAccountManager *) defaultManager
{
	return [[WizGlobalData sharedData] defaultAccountManager];
}


-(NSArray*) accounts
{
	id<WizSettingsDbDelegate> settingDataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    NSArray* array = [settingDataBase allAccounts];
    NSMutableArray* accountUserIds = [NSMutableArray array];
    for (WizAccount* account in array) {
        [accountUserIds addObject:account.userId];
    }
    return accountUserIds;
}

-(BOOL) findAccount: (NSString*)userId
{
	NSArray* accounts = [self accounts];
	for (NSString* each in accounts) {
        if ([each isEqualToString:userId]) {
            return YES;
        }
    }
	return NO;
}


-(NSString*) accountPasswordByUserId:(NSString *)userID
{
    if (![self findAccount:userID]) {
        return nil;
    }
    id<WizSettingsDbDelegate> settingDataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    WizAccount* account = [settingDataBase accountFromUserId:userID];
    return account.password;
}
- (void) setDefalutAccount:(NSString*)accountUserId;
{
    if (accountUserId == nil) {
        accountUserId = @"";
    }
    id<WizSettingsDbDelegate> settingDataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    [settingDataBase setWizDefaultAccountUserId:accountUserId];
    self.activeAccountUserId_ = accountUserId;
}
- (BOOL) registerActiveAccount:(NSString*)userId
{
    [self setDefalutAccount:userId];
    timer = [NSTimer scheduledTimerWithTimeInterval:600 target:[WizSyncManager shareManager] selector:@selector(automicSyncData) userInfo:nil repeats:YES];
    [timer fire];
    // 避免初始化摘要数据库多线程争抢
    [[WizDbManager shareDbManager] shareAbstractDataBase];
    return YES;
}
- (NSString*) activeAccountUserId
{
    if (nil == self.activeAccountUserId_) {
        id<WizSettingsDbDelegate> settingDB = [[WizDbManager shareDbManager] getWizSettingsDataBase];
        self.activeAccountUserId_ = [settingDB defaultAccountUserId];
    }
    return self.activeAccountUserId_;
}

-(void) addAccount: (NSString*)userId password:(NSString*)password
{
	id<WizSettingsDbDelegate> settingDB = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    [settingDB updateAccount:userId password:password];
}
-(void) changeAccountPassword: (NSString*)userId password:(NSString*)password
{
    id<WizSettingsDbDelegate> settingDB = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    NSLog(@"accountuserid %@ password is %@  md5 is %@",userId,password, [WizGlobals encryptPassword:password]);
    [settingDB updateAccount:userId password:password];
}

- (void) logoutAccount
{
    if (timer) {
        [timer invalidate];
    }
    [[WizDbManager shareDbManager] removeUnactiveDatabase:self.activeAccountUserId_];
    WizSyncManager* sync = [WizSyncManager shareManager];
    [sync resignActive];
    [self setDefalutAccount:@""];
}

-(void) removeAccount: (NSString*)userId
{
    if (![self findAccount:userId]) {
        return;
    }
    [[WizFileManager shareManager] removeItemAtPath:[[WizFileManager shareManager] accountPath] error:nil];
    [[[WizDbManager shareDbManager] shareAbstractDataBase] deleteAbstractsByAccountUserId:userId];
    [self logoutAccount];
    id<WizSettingsDbDelegate> settingDB = [[WizDbManager shareDbManager] getWizSettingsDataBase];
    [settingDB deleteAccountByUserId:userId];
}
@end
