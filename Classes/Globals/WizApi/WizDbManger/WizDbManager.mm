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


#define PRIMARAY_KEY    @"PRIMARAY_KEY"

@interface WizDbManager()
{
    NSMutableArray* dbDataArray;
    NSMutableDictionary* dbDataDictionary;
}
@property (atomic, retain) NSMutableDictionary* dbDataDictionary;
@end

@implementation WizDbManager
@synthesize dbDataDictionary;
- (void) dealloc
{
    [dbDataDictionary release];
    [dbDataArray release];
    [super dealloc];
}
- (void) clearDataBase
{
    
}

- (NSDictionary*) createTableModel:(NSDictionary*)data  tableName:(NSString*)tableName
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    NSMutableString* createTableSql = [NSMutableString stringWithFormat:@"CREATE TABLE %@ (", tableName];
    for (NSString* column in [data allKeys])
    {
        NSString* columnType = [data valueForKey:column];
        if ([column isEqualToString:PRIMARAY_KEY]) {
            continue;
        }
        NSString* columnSql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@;",tableName ,column, columnType];
        [dictionary setObject:columnSql forKey:column];
        [createTableSql appendFormat:@"%@ %@,", column, columnType];
    }
    NSString* primaryKey = [data valueForKey:PRIMARAY_KEY];
    if (!primaryKey) {
        NSInteger lastIndex = [createTableSql lastIndexOf:@","];
        if (NSNotFound != lastIndex) {
            [createTableSql deleteCharactersInRange:NSMakeRange(lastIndex, createTableSql.length)];
        }
    }
    else
    {
        [createTableSql appendFormat:@" primary key (%@));",primaryKey];
    }
    
    [dictionary setObject:createTableSql forKey:tableName];
    return dictionary;
}

- (NSDictionary*) getDataBaseStruct
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WizDataBaseModel" ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    for (NSString* table in [dic allKeys]) {
       [ret setObject:[self createTableModel:[dic valueForKey:table] tableName:table] forKey:table];
    }
    return ret;
}

- (WizDbManager*) init
{
    self = [super init];
    if (self) {
        dbDataArray = [[NSMutableArray alloc] init];
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
- (WizDataBase*) shareDataBase
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
    return [NSString stringWithFormat:@"%@%@%@",[self getCurrentThreadId],accountUserId,groupId];
}

- (WizDataBase*) getNewWizDataBase:(NSString *)accountUserId groupId:(NSString *)groupId
{
    if (nil == accountUserId || [accountUserId isBlock])
    {
        return nil;
    }
    WizDataBase* dataBase = [[WizDataBase alloc] init];
    if (!(nil == groupId || [accountUserId isBlock])) {
        NSString* dbPath = [[WizFileManager shareManager]dbPathForAccountUserId:accountUserId groupId:groupId];
        [dataBase openDb:dbPath];
    }
    NSString* tempDb = [[WizFileManager shareManager] tempDbPathForAccount:accountUserId];
    [dataBase openTempDb:tempDb];
    [self.dbDataDictionary setObject:dataBase forKey:[self dataBaseKeyString:accountUserId groupId:groupId]];
    dataBase.kbguid = groupId;
    return [dataBase autorelease];
}

- (WizDataBase*) getWizDataBase:(NSString *)accountUserId groupId:(NSString *)groupId
{
    WizDataBase* dataBase = [self.dbDataDictionary objectForKey:[self dataBaseKeyString:accountUserId groupId:groupId]];
    if (!dataBase) {
        dataBase = [self getNewWizDataBase:accountUserId groupId:groupId];
    }
    return dataBase;
}

- (void) removeUnactiveDatabase
{
    NSMutableArray* keys = [NSMutableArray array];
    for (NSString* each in [self.dbDataDictionary allKeys]) {
        if (NSNotFound != [each indexOf:[self getCurrentThreadId]]) {
            [keys addObject:each];
        }
    }
    for (NSString* each in keys) {
        [self.dbDataDictionary removeObjectForKey:each];
    }
}

@end
