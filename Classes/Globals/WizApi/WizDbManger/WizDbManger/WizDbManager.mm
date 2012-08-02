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
#import "WizSettingsDataBase.h"

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
        dbDataDictionary = [[NSMutableDictionary alloc] init];
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
    return [self getWizDataBase:accountUserId];
}

- (NSString*) dataBaseKeyString:(NSString *)accountUserId
{
    return [NSString stringWithFormat:@"%@-inforDataBase",accountUserId];
}

- (NSString*) abstractBaseKeyString:(NSString*)accountUserId
{
    return [NSString stringWithFormat:@"%@-abstractDataBase",accountUserId];
}

- (id<WizDbDelegate>) getNewWizDataBase:(NSString *)accountUserId 
{
    if (nil == accountUserId || [accountUserId isBlock])
    {
        return nil;
    }
    id<WizDbDelegate> dataBase = [[WizInfoDataBase alloc] initWithAccountUserId:accountUserId modelName:@"WizDataBaseModel"];
    [self.dbDataDictionary setObject:dataBase forKey:[self dataBaseKeyString:accountUserId]];
    return [dataBase autorelease];
}

- (id<WizTemporaryDataBaseDelegate>) getNewWizTempDataBase:(NSString*)accountUserId
{
    if (nil == accountUserId || [accountUserId isBlock]) {
        return nil;
    }
    NSString* dbPath = [[WizFileManager shareManager] abstractDataBatabasePath:accountUserId];
    id<WizTemporaryDataBaseDelegate> database = [[WizTempDataBase alloc] initWithPath:dbPath modelName:@"WizAbstractDataBaseModel"];
    [self.dbDataDictionary setObject:database forKey:[self abstractBaseKeyString:accountUserId]];
    return [database autorelease];
}

- (id<WizSettingsDbDelegate>) getNewWizSettingsDataBase
{
    NSString* dbPath = [[WizFileManager documentsPath] stringByAppendingPathComponent:@"accounts.db"];
    id<WizSettingsDbDelegate> dataBase = [[WizSettingsDataBase alloc] initWithPath:dbPath modelName:@"WizSettingsDataBaseModel"];
    [self.dbDataDictionary setObject:dataBase forKey:WIZ_ACCOUNTS_SETTINGSFILE];
    return [dataBase autorelease];
}

- (id<WizDbDelegate>) getWizDataBase:(NSString *)accountUserId
{
    id<WizDbDelegate> dataBase = [self.dbDataDictionary objectForKey:[self dataBaseKeyString:accountUserId]];
    if (!dataBase) {
        dataBase = [self getNewWizDataBase:accountUserId ];
    }
    return dataBase;
}
- (id<WizTemporaryDataBaseDelegate>) shareAbstractDataBase
{
    return [self getWizTempDataBase:[[WizAccountManager defaultManager] activeAccountUserId]];
}

- (id<WizTemporaryDataBaseDelegate>) getWizTempDataBase:(NSString*)accountUserId
{
    id<WizTemporaryDataBaseDelegate> dataBase = [self.dbDataDictionary objectForKey:[self abstractBaseKeyString:accountUserId]];
    if (!dataBase) {
        dataBase = [self getNewWizTempDataBase:accountUserId];
    }
    return dataBase;
}

- (id<WizSettingsDbDelegate>) getWizSettingsDataBase
{
    id<WizSettingsDbDelegate> dataBase = [self.dbDataDictionary objectForKey:WIZ_ACCOUNTS_SETTINGSFILE];
    if (!dataBase) {
        @synchronized(dataBase)
        {
             dataBase = [self getNewWizSettingsDataBase];
        }
    }
    return dataBase;
}

- (void) removeUnactiveDatabase:(NSString*)userId
{
    NSArray* allDataBaseKeys = [[[self.dbDataDictionary allKeys] copy] autorelease];
    for (NSString* each in allDataBaseKeys) {
        if ([each isEqualToString:WIZ_ACCOUNTS_SETTINGSFILE]) {
            continue;
        }
        if ([each indexOf:userId] != NSNotFound) {
           WizDataBaseBase* dataBase = [self.dbDataDictionary objectForKey:each];
            [dataBase close];
            [self.dbDataDictionary removeObjectForKey:each];
        }
    }
    NSLog(@"%@",self.dbDataDictionary);
}

@end
