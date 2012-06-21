//
//  WizDataBaseBase.m
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizDataBaseBase.h"
#import "FMDatabaseAdditions.h"
#import "WizGlobals.h"
#import "WizFileManager.h"
#define PRIMARAY_KEY    @"PRIMARAY_KEY"
@implementation WizDataBaseBase
@synthesize queue;
@synthesize accountUserId;
@synthesize kbGuid;
- (void) dealloc
{
    [accountUserId release];
    [kbGuid release];
    [queue release];
    [super dealloc];
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
        int lastIndex = [createTableSql  lastIndexOf:@","];
        if (NSNotFound != lastIndex) {
            [createTableSql deleteCharactersInRange:NSMakeRange(lastIndex, 1)];
        }
        [createTableSql appendString:@")"];
    }
    else
    {
        [createTableSql appendFormat:@" primary key (%@));",primaryKey];
    }
    
    [dictionary setObject:createTableSql forKey:tableName];
    return dictionary;
}

- (NSDictionary*) getDataBaseStructFromFile:(NSString*)modelName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:modelName ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    for (NSString* table in [dic allKeys]) {
        [ret setObject:[self createTableModel:[dic valueForKey:table] tableName:table] forKey:table];
    }
    return ret;
}

- (WizDataBaseBase*) initWithAccountUserId:(NSString*)accountUserId_ kbGuid:(NSString*)kbGuid_    modelName:(NSString*)modelName
{
    self = [super init];
    if (self) {
        NSString* dbPath = [[WizFileManager shareManager] dbPathForAccountUserId:accountUserId_ groupId:kbGuid_];
        accountUserId = [accountUserId_ retain];
        kbGuid = [kbGuid_ retain];
        NSDictionary* model = [self getDataBaseStructFromFile:modelName];
        queue = [[FMDatabaseQueue alloc] initWithPath:dbPath withModel:model];
    }
    return self;
}

- (WizDataBaseBase*) initWithPath:(NSString*)dbPath modelName:(NSString*)modelName
{
    self = [super init];
    if (self) {
        NSDictionary* model = [self getDataBaseStructFromFile:modelName];
        queue = [[FMDatabaseQueue alloc] initWithPath:dbPath withModel:model];
    }
    return self;
}


@end
