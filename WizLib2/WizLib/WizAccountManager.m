//
//  WizAccountManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountManager.h"
#import "WizFileManager.h"

//settings file
#define SettingsFileName @"settings.plist"
#define DataTypeOfActiveAccountUserId   @"DataTypeOfActiveAccountUserId"
#define DataTypeOfAccounts              @"accountsArray"
#define DataTypeOfAccountUserId @"DataTypeOfAccountUserId"
#define DataTypeOfAccountPassword @"DataTypeOfAccountPassword"
@interface WizAccountManager()
{
    NSMutableDictionary* data;
}
- (void) writeSettings:(id)setting  key:(NSString*)key;
- (id) readSetting:(NSString*)key;
- (NSArray*) accounts;
@end
@implementation WizAccountManager
static WizAccountManager* shareAccountManager = nil;
+(NSString*) settingsFileName
{
	NSString* filename = [[WizFileManager wizAppPath] stringByAppendingPathComponent:SettingsFileName];
	return filename;
}

- (id) init
{
    self = [super init];
    if (self) {
        NSString* file = [WizAccountManager settingsFileName];
        data = [NSMutableDictionary dictionaryWithContentsOfFile:file];
        if (!data) {
            data = [[NSMutableDictionary alloc] init];
        }
        [data retain];
        
    }
    return self;
}
- (void) writeSettings:(id)setting  key:(NSString*)key
{
    [data setObject:setting forKey:key];
    [data writeToFile:[WizAccountManager settingsFileName] atomically:NO];
}
- (id) readSetting:(NSString*)key
{
    return [data valueForKey:key];
}
- (NSArray*) accounts
{
    NSArray* accounts = [self readSetting:DataTypeOfAccounts];
    if (!accounts) {
        accounts = [NSArray array];
    }
    return accounts;
}
+(NSString*) passwordForAccount:(NSString*)accountUserId
{
    NSArray* accounts = [[WizAccountManager shareAccountManager] accounts];
    for (NSDictionary* each in accounts) {
        NSString* password = [each valueForKey:DataTypeOfAccountPassword];
        NSString* account = [each valueForKey:DataTypeOfAccountUserId];
        if (password!=nil && account!=nil) {
            if ([account isEqualToString:accountUserId]) {
                return password;
            }
        }
    }
    return WizNullString;
}
+ (BOOL) checkAccountIsExist:(NSString*)userId
{
    NSString* a = [WizAccountManager passwordForAccount:userId];
    if ([a isEqualToString:WizNullString]) {
        return NO;
    }
    return YES;

}
+ (BOOL) addAccount:(NSString*)userId   password:(NSString*)password
{
    if ([WizAccountManager checkAccountIsExist:userId]) {
        return NO;
    }
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:userId,DataTypeOfAccountUserId,password,DataTypeOfAccountPassword, nil];
    WizAccountManager* share = [WizAccountManager shareAccountManager];
    NSMutableArray* accounts = [NSMutableArray arrayWithArray:[share accounts]];
    [accounts addObject:dic];
    [share writeSettings:accounts key:DataTypeOfAccounts];
    return YES;
}

+ (id) shareAccountManager
{
    @synchronized(shareAccountManager)
    {
        if (shareAccountManager == nil) {
            shareAccountManager = [[super allocWithZone:NULL] init];
        }
        return shareAccountManager;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareAccountManager] retain];
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
+ (NSString*)activeAccountUserId
{
    NSString* userId = [[WizAccountManager shareAccountManager] readSetting:DataTypeOfActiveAccountUserId];
    return userId;
}
+ (void) registerActiveAccount:(NSString*)userId
{
    [[WizAccountManager shareAccountManager] writeSettings:userId key:DataTypeOfActiveAccountUserId];
    [WizNotificationCenter postResisterActiveAccount];
}
// over
@end
