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
	NSMutableDictionary* dict;
    NSTimer* timer;
}
@property (nonatomic, retain) NSTimer* timer;
@end

@implementation WizAccountManager
@synthesize timer;
-(NSString*) settingsFileName
{
	NSString* filename = [[WizFileManager  documentsPath] stringByAppendingPathComponent:SettingsFileName];
	return filename;
}
-(id) init
{
	if (self = [super init])
	{
		NSString* filename = [self settingsFileName];
		dict = [NSMutableDictionary dictionaryWithContentsOfFile:filename];
		if (dict == nil)
		{
			dict = [[NSMutableDictionary alloc] init];
		}
		[dict retain];
	}
	return self;
}
-(void)dealloc
{
	[dict release];
	[super dealloc];
}

-(NSMutableDictionary *)dict
{
	return dict;
}


+(WizAccountManager *) defaultManager
{
	return [[WizGlobalData sharedData] defaultAccountManager];
}


- (NSDictionary*) buildAccountData:(NSString*)userId password:(NSString*)password kbguids:(NSArray*)kbguids
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            userId, KeyOfUserId ,
            password,KeyOfPassword,
            kbguids, KeyOfKbguids
            ,nil];
}
- (NSString*) accountUserIDFromDic:(NSDictionary*)dic
{
    return [dic valueForKey:KeyOfUserId];
}

- (NSString*) accountUserPasswordFromDic:(NSDictionary*)dic
{
    return [dic valueForKey:KeyOfPassword];
}

- (NSString*) accountKbGuidsFromDic:(NSDictionary*)dic
{
    return [dic valueForKey:KeyOfKbguids];
}

-(id) readSettings: (NSString*)key
{
	return [dict objectForKey:key];
}

-(void) writeSettings: (NSString*)key value:(id)value
{
	[dict setValue:value forKey:key];
	NSString* filename = [self settingsFileName];
    [dict writeToFile:filename atomically:YES];
}

-(NSArray*) accounts
{
	id ret = [self readSettings:KeyOfAccounts];
	if ([ret isKindOfClass:[NSArray class]])
	{
        NSMutableArray* arr = [NSMutableArray array];
        for (NSDictionary* each in ret) {
            NSString* userId = [each valueForKey:KeyOfUserId];
            if (nil != userId) {
                [arr addObject:userId];
            }
        }
		 return arr;
	}
	return nil;
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
    id accounts = [self readSettings:KeyOfAccounts];
    if ([accounts isKindOfClass:[NSArray class]])
    {
        for (NSDictionary* each in accounts) {
            NSString* password = [each valueForKey:KeyOfPassword];
            NSString* userId = [each valueForKey:KeyOfUserId];
            if([userID isEqualToString:userId])
            {
                return password;
            }
        }
    }
    return nil;
}
- (void) setDefalutAccount:(NSString*)accountUserId;
{
    [self writeSettings:KeyOfDefaultUserId value:accountUserId];
}
- (BOOL) registerActiveAccount:(NSString*)userId
{
    [self setDefalutAccount:userId];
    timer = [NSTimer scheduledTimerWithTimeInterval:600 target:[WizSyncManager shareManager] selector:@selector(automicSyncData) userInfo:nil repeats:YES];
    [timer fire];
    return YES;
}
- (NSString*) activeAccountUserId
{
    id userId = [self readSettings:KeyOfDefaultUserId];
    if (userId != nil && [userId isKindOfClass:[NSString class]]) {
        return (NSString*)userId;
    }
    else
    {
        return @"";
    }
}
- (NSDictionary*) activeAccountData
{
    NSArray* exitsAccounts = [self readSettings:KeyOfAccounts];
    for (NSDictionary* account in exitsAccounts) {
        NSString* userId = [self accountUserIDFromDic:account];
        if ([userId isEqualToString:[self activeAccountUserId]]) {
            return account;
        }
    }
    return nil;
}
- (void) addKbguidGroup:(NSDictionary*)dic
{
    
}
- (NSInteger) findAccountIndex:(WizAccount*)account
{
    NSArray* exitsAccounts = [self readSettings:KeyOfAccounts];
    NSInteger accountIndex = 0;
    BOOL exist = NO;
    for (accountIndex = 0; accountIndex < [exitsAccounts count]; accountIndex++) {
        NSDictionary* dic = [exitsAccounts objectAtIndex:accountIndex];
        if ([account isEqualToAccountDictionaryData:dic]) {
            exist = YES;
            break;
        }
    }
    if (exist) {
        return accountIndex;
    }
    else {
        return NSNotFound;
    }
}
- (void) updateAccount:(WizAccount*)account
{
    NSInteger accountIndex    = [self findAccountIndex:account];
    NSDictionary* accountData = [account accountDictionaryData];
    NSArray* exitsAccounts    = [self readSettings:KeyOfAccounts];
    NSMutableArray* array     = [NSMutableArray array];
    if (exitsAccounts) {
        [array addObjectsFromArray:exitsAccounts];
    }
    if (accountIndex == NSNotFound) {
        [array addObject:accountData];
    }
    else {
        [array replaceObjectAtIndex:accountIndex withObject:accountData];
    }
    [self writeSettings:KeyOfAccounts value:array];
}

- (WizAccount*) accountFromLoaclData:(NSString*)userId
{
    WizAccount* account = [[WizAccount alloc] init];
    account.userId = userId;
    NSInteger accountIndex    = [self findAccountIndex:account];
    NSArray* exitsAccounts    = [self readSettings:KeyOfAccounts];
    if (accountIndex == NSNotFound) {
        return nil;
    }
    else {
        return [account initAccountFromDic:[exitsAccounts objectAtIndex:accountIndex]];
    }
}
- (WizAccount*) activeAccount
{
    return [self accountFromLoaclData:[self activeAccountUserId]];
}
-(void) addAccount: (NSString*)userId password:(NSString*)password
{
	if ([self findAccount:userId])
	{
		[self changeAccountPassword:userId password:password];
		return;
	}
    NSLog(@"userId is %@",userId);
	NSArray* exitsAccounts = [self readSettings:KeyOfAccounts];
	//
    if (![WizGlobals checkPasswordIsEncrypt:password]) {
        password = [WizGlobals encryptPassword:password];
    }
	NSDictionary* account = [NSDictionary dictionaryWithObjectsAndKeys:userId, KeyOfUserId, password, KeyOfPassword, nil];
	NSMutableArray* newAccounts = [NSMutableArray arrayWithArray:exitsAccounts];
	[newAccounts addObject:account];
    NSLog(@"dic %@",account);
    [self writeSettings:KeyOfAccounts value:newAccounts];
}
- (NSString*) accountProtectPassword
{
    id password = [self readSettings:KeyOfProtectPassword];
    if (password != nil && [password isKindOfClass:[NSString class]]) {
        return password;
    }
    else
    {
        return @"";
    }
}

- (void) setAccountProtectPassword:(NSString*)password
{
    [self writeSettings:KeyOfProtectPassword value:password];
}

-(void) changeAccountPassword: (NSString*)userId password:(NSString*)password
{
    if (![self findAccount:userId]) {
        return;
    }
    //
    if (![WizGlobals checkPasswordIsEncrypt:password]) {
        password = [WizGlobals encryptPassword:password];
    }
	NSDictionary* account = [NSDictionary dictionaryWithObjectsAndKeys:userId, KeyOfUserId, password , KeyOfPassword, nil];
	//
    NSMutableArray* arr = [NSMutableArray arrayWithArray:[self readSettings:KeyOfAccounts]];
    int i = 0;
    for (; i < [arr count] ; i++) {
        NSDictionary* each = [arr objectAtIndex:i];
        NSString* _userId = [each valueForKey:KeyOfUserId];
        if ([_userId isEqualToString:userId]) {
            break;
        }
    }
    [arr replaceObjectAtIndex:i withObject:account];
    [self writeSettings:KeyOfAccounts value:arr];
}

- (NSString*) registerActiveKbguid:(NSString *)kbguid
{
    return nil;
}

- (void) logoutAccount
{
    [timer invalidate];
    WizDbManager* share = [WizDbManager shareDbManager];
    [share close];
    [share closeTempDb];
    WizSyncManager* sync = [WizSyncManager shareManager];
    [sync resignActive];
    [self setDefalutAccount:@""];
}

-(void) removeAccount: (NSString*)userId
{
    if (![self findAccount:userId]) {
        return;
    }
    NSMutableArray* arr = [NSMutableArray arrayWithArray:[self readSettings:KeyOfAccounts]];
    int i = 0;
    for (; i < [arr count] ; i++) {
        NSDictionary* each = [arr objectAtIndex:i];
        NSString* _userId = [each valueForKey:KeyOfUserId];
        if ([_userId isEqualToString:userId]) {
            break;
        }
    }
    [[WizFileManager shareManager] removeItemAtPath:[[WizFileManager shareManager] accountPath] error:nil];
    [arr removeObjectAtIndex:i];
    [self logoutAccount];
    [self writeSettings:KeyOfAccounts value:arr];
}
@end
