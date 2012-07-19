//
//  WizDbManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "XMLRPCResponse.h"
#import "WizInfoDataBase.h"
#import "WizTempDataBase.h"
#import "wizSettingsDataBase.h"

#define WIZ_ACCOUNTS_SETTINGSFILE   @"WIZ_ACCOUNTS_SETTINGSFILE"
#define PRIMARAY_KEY    @"PRIMARAY_KEY"

@interface WizDbManager()
{
    NSMutableDictionary* dbDataDictionary;
}
@property (atomic, retain) NSMutableDictionary* dbDataDictionary;
@end

@implementation WizDbManager
@synthesize dbDataDictionary;
- (void) dealloc
{
    [dbDataDictionary release];
    [super dealloc];
}
- (void) clearDataBase
{
    
}


- (WizDbManager*) init
{
    self = [super init];
    if (self) {
        self.dbDataDictionary = [[NSMutableDictionary alloc] init];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(clearDataBase) name:MessageTypeOfMemeoryWarning];
    }
    return self;
}
//single object
static WizDbManager* shareDbManager = nil;
+ (id) shareDbManager
{
    @synchronized(shareDbManager)
    {
        if (shareDbManager == nil) {
            shareDbManager = [[super allocWithZone:NULL] init];
        }
        return shareDbManager;
    }
}
// over
- (id<WizDbDelegate>) shareDataBase
{
    NSString* accountUserId = [[WizAccountManager defaultManager] activeAccountUserId];
    NSString* accountKbguid = [[WizAccountManager defaultManager] activeAccountGroupKbguid];
    return [self getWizDataBase:accountUserId groupId:accountKbguid];
}


- (NSString*) getCurrentThreadId
{
    NSString* des = [NSThread currentThread].description;
    NSInteger end = [des indexOf:@"{"];
    if (NSNotFound == end) {
        return  des;
    }
    else
    {
        return  [des substringToIndex:end];
    }
}

- (NSString*) dataBaseKeyString:(NSString *)accountUserId groupId:(NSString *)groupId
{
    return [NSString stringWithFormat:@"%@%@",accountUserId,groupId];
}

- (id<WizDbDelegate>) getNewWizDataBase:(NSString *)accountUserId groupId:(NSString *)groupId
{
    if (nil == accountUserId || [accountUserId isBlock])
    {
        return nil;
    }
    NSString* dbPath = nil;
    if (!(nil == groupId || [accountUserId isBlock])) {
         dbPath = [[WizFileManager shareManager]dbPathForAccountUserId:accountUserId groupId:groupId];
    }
    else
    {
        return nil;
    }
    id<WizDbDelegate> dataBase = [[WizInfoDataBase alloc] initWithAccountUserId:accountUserId kbGuid:groupId modelName:@"WizDataBaseModel"];
    [self.dbDataDictionary setObject:dataBase forKey:[self dataBaseKeyString:accountUserId groupId:groupId]];
    return [dataBase autorelease];
}

- (id<WizAbstractDbDelegate>) getNewWizTempDataBase:(NSString*)accountUserId
{
    if (nil == accountUserId || [accountUserId isBlock]) {
        return nil;
    }
    NSString* dbPath = [[WizFileManager shareManager] tempDbPathForAccount:accountUserId];
    id<WizAbstractDbDelegate> database = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizAbstractDataBaseModel"];
    [self.dbDataDictionary setObject:database forKey:accountUserId];
    return [database autorelease];
}

- (id<WizSettingsDbDelegate>) getNewWizSettingsDataBase
{
    NSString* dbPath = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"accounts.db"];
    id<WizSettingsDbDelegate> dataBase = [[WizSettingsDataBase alloc] initWithPath:dbPath modelName:@"WizSettingsDataBaseModel"];
    [self.dbDataDictionary setObject:dataBase forKey:WIZ_ACCOUNTS_SETTINGSFILE];
    return [dataBase autorelease];
}

- (id<WizDbDelegate>) getWizDataBase:(NSString *)accountUserId groupId:(NSString *)groupId
{
    id<WizDbDelegate> dataBase = [self.dbDataDictionary objectForKey:[self dataBaseKeyString:accountUserId groupId:groupId]];
    if (!dataBase) {
        dataBase = [self getNewWizDataBase:accountUserId groupId:groupId];
    }
    return dataBase;
}

- (id<WizAbstractDbDelegate>) getWizTempDataBase:(NSString*)accountUserId
{
    id<WizAbstractDbDelegate> dataBase = [self.dbDataDictionary objectForKey:accountUserId];
    if (!dataBase) {
        dataBase = [self getNewWizTempDataBase:accountUserId];
    }
    return dataBase;
}

- (id<WizSettingsDbDelegate>) getWizSettingsDataBase
{
    id<WizSettingsDbDelegate> dataBase = [self.dbDataDictionary objectForKey:WIZ_ACCOUNTS_SETTINGSFILE];
    if (!dataBase) {
        dataBase = [self getNewWizSettingsDataBase];
    }
    return dataBase;
}

- (void) removeUnactiveDatabase:(NSString*)userId
{
    for (NSString* each in [self.dbDataDictionary allKeys]) {
        if ([each isEqualToString:WIZ_ACCOUNTS_SETTINGSFILE]) {
            continue;
        }
        [self.dbDataDictionary removeObjectForKey:each];
    }
    NSLog(@"keys count is %d",[[self.dbDataDictionary allKeys] count]);
    for(NSString* each in [self.dbDataDictionary allKeys])
    {
        NSLog(@"%@",each);
    }
}

@end
