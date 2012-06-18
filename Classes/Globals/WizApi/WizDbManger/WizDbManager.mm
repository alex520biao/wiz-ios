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
    id<WizDbDelegate> dataBase = [[WizInfoDataBase alloc] initWithPath:dbPath modelName:@"WizDataBaseModel"];
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
