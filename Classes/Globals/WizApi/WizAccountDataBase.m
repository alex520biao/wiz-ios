//
//  WizAccountDataBase.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAccountDataBase.h"
#import "WizFileManager.h"
#import "WizSettings.h"
#import "WizSetting.h"
#import "WizDataBase.h"
#import "WizAccountManager.h"

@interface WizAccountDataBase()

@property (readonly, retain, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, retain, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation WizAccountDataBase
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WizModel" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"accounts.sqlite"];
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {

        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}
- (WizAccount*) accountFromDataBase:(NSString*)userId
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WizEntityAccount];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"userId == %@",userId];
    NSError* error = nil;
    [fetchRequest setPredicate:predicate];
    NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return [result lastObject];
}
- (NSArray*) allAccounts
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WizEntityAccount];
    NSSortDescriptor* sort = [NSSortDescriptor sortDescriptorWithKey:@"userId" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSError* error = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return result;
}

- (BOOL) updateAccount:(NSString*)userId    password:(NSString*)password
{
    WizAccount* exist = [self accountFromDataBase:userId];
    if (!exist) {
        exist = [NSEntityDescription insertNewObjectForEntityForName:WizEntityAccount inManagedObjectContext:self.managedObjectContext];
    }
    exist.userId = userId;
    exist.password = password;
    [self saveContext];
    return YES;
}

- (WizGroup*) groupFromDataBase:(NSString*)guid
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WizEntityGroup];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"kbguid == %@",guid];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    
    return [result lastObject];
}

- (BOOL) updateGroup:(NSDictionary*)dic  userId:(NSString*)userId;
{
    NSString* guid = [dic valueForKey:KeyOfKbKbguid];
    WizGroup* exist = [self groupFromDataBase:guid];
    if (!exist) {
        exist = [NSEntityDescription insertNewObjectForEntityForName:WizEntityGroup inManagedObjectContext:self.managedObjectContext];
    }
    [exist getDataFromDic:dic];
    exist.accountUserId = userId;
    [self saveContext];
    return YES;
}
- (NSArray*) allGroupByAccount:(NSString*)userId
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WizEntityGroup];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"accountUserId == %@",userId];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return result;
}

- (WizSetting*) settingByKey:(NSString*)key  accountUserId:(NSString*)userId
{
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:WizEntitySetting];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"accountUserId == %@ && key == %@",userId,key];
    [fetchRequest setPredicate:predicate];
    NSError* error = nil;
    NSArray* result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        return nil;
    }
    return [result lastObject];
}

- (void) updateSetting:(NSString*)key  value:(NSString*)value   accountUserId:(NSString*)userId
{
    WizSetting* exist = [self settingByKey:key accountUserId:userId];
    if (!exist) {
        exist = [NSEntityDescription insertNewObjectForEntityForName:WizEntitySetting inManagedObjectContext:self.managedObjectContext];
    }
    exist.accountUserId = userId;
    exist.value = value;
    exist.key = key;
    [self saveContext];
}

- (NSString*) userInfo:(NSString*)key
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    WizSetting* setting = [self settingByKey:key accountUserId:userId];
    if (setting) {
        return setting.value;
    }
    else {
        return nil;
    }
}
- (BOOL)  setUserInfo:(NSString*)key info:(NSString*)value
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    [self updateSetting:key value:value accountUserId:userId];
    return YES;
}
- (int64_t) imageQualityValue
{
    NSString* str = [self userInfo:ImageQuality];
    if(!str)
        return 0;
    else
        return [str longLongValue];
}
- (BOOL) setImageQualityValue:(int64_t)value
{
    NSString* imageValue = [NSString stringWithFormat:@"%lld",value];
    return [self setUserInfo:ImageQuality info:imageValue];
}
//
- (BOOL) connectOnlyViaWifi
{
    NSString* wifiStr = [self userInfo:ConnectServerOnlyByWif];
    if (wifiStr == nil) {
        [self setConnectOnlyViaWifi:NO];
        return NO;
    }
    BOOL ret = [wifiStr intValue] == 1? YES: NO;
    return ret;
}
- (BOOL) setConnectOnlyViaWifi:(BOOL)wifi
{
    NSString* wifiStr = [NSString stringWithFormat:@"%d",wifi?1:0];
    return [self setUserInfo:ConnectServerOnlyByWif info:wifiStr];
}
//

- (BOOL) setLastSynchronizedDate:(NSDate*)date
{
    NSString* dateStr = [date stringSql];
    return [self setUserInfo:LastSynchronizedDate info:dateStr];
}

- (NSDate*) lastSynchronizedDate
{
    NSString* dataStr = [self userInfo:LastSynchronizedDate];
    if (nil == dataStr || [dataStr isBlock]) {
        return [NSDate date];
    }
    return [dataStr dateFromSqlTimeString];
}
//
-(BOOL) setUserTableListViewOption:(int64_t)option
{
    NSString* info = [NSString stringWithFormat:@"%lld",option];
    return [self setUserInfo:UserTablelistViewOption info:info];
}

- (int64_t) userTablelistViewOption
{
    NSString* str = [self userInfo:UserTablelistViewOption];
    if (str == nil || [str isEqualToString:@""]) {
        return kOrderDate;
    }
    else
        return [str longLongValue];
}
//
- (int) webFontSize
{
    NSString* fontsize = [self userInfo:WebFontSize];
    if(!fontsize)
    {
        return 0;
    }
    else
    {
        return [fontsize intValue];
    }
}

- (BOOL) setWebFontSize:(int)fontsize
{
    NSString* fontString = [NSString stringWithFormat:@"%d",fontsize];
    return [self setUserInfo:WebFontSize info:fontString];
}
//
- (NSString*) wizUpgradeAppVersion
{
    NSString* ver = [self userInfo:WizNoteAppVerSion];
    if (!ver) {
        return @"";
    }
    else {
        return ver;
    }
}
- (BOOL) setWizUpgradeAppVersion:(NSString*)ver
{
    return [self setUserInfo:ver info:WizNoteAppVerSion];
}
- (int64_t) durationForDownloadDocument
{
    NSString* duration = [self userInfo:DurationForDownloadDocument];
    if(duration == nil || [duration isEqualToString:@""])
    {
        [self setDurationForDownloadDocument:1];
        duration = [self userInfo:DurationForDownloadDocument];
    }
    return [duration longLongValue];
}
- (NSString*) durationForDownloadDocumentString
{
    return [self userInfo:DurationForDownloadDocument];
}
-(BOOL) setDurationForDownloadDocument:(int64_t)duration
{
    NSString* durationString = [NSString stringWithFormat:@"%lld",duration];
    return [self setUserInfo:DurationForDownloadDocument info:durationString];
}
- (BOOL) isMoblieView
{
    NSString* ret = [self userInfo:MoblieView];
    if (nil == ret || [ret isEqualToString:@""]) {
        [self setDocumentMoblleView:YES];
        return YES;
    }
    return  [ret isEqualToString:@"1"];
}
- (BOOL) isFirstLog
{
    NSString* first = [self userInfo:FirstLog];
    if (first == nil || [first isEqualToString:@""]) {
        return YES;
    }
    return [first isEqualToString:@"0"];
}
- (BOOL) setFirstLog:(BOOL)first
{
    NSString* firstStr = first?@"1":@"0";
    return [self setUserInfo:FirstLog info:firstStr];
}
- (BOOL) setDocumentMoblleView:(BOOL)mobileView
{
    NSString* mobile = mobileView? @"1": @"0";
    return [self setUserInfo:MoblieView info:mobile];
}

//userInfo
-(int64_t) userTrafficLimit
{
    NSString* str = [self userInfo:UserTrafficLimit];
    if(!str)
        return 0;
    else
        return [str longLongValue];
}
-(BOOL) setUserTrafficLimit:(int64_t)ver
{
    NSString* info = [NSString stringWithFormat:@"%lld",ver];
    return [self setUserInfo:UserTrafficLimit info:info];
}
- (NSString*) userTrafficLimitString
{
    int64_t used = [self userTrafficLimit];
    int64_t kb = used / 1024;
    int64_t mb = kb / 1024;
    if (mb == 0) {
        return [NSString stringWithFormat:@"%lldkb",kb];
    }
    return  [NSString stringWithFormat:@"%lldM",mb];
}
//
-(int64_t) userTrafficUsage
{
    NSString* str = [self userInfo:UserTrafficUsage];
    if(!str)
        return 0;
    else
        return [str longLongValue];
}
-(NSString*) userTrafficUsageString
{
    int64_t used = [self userTrafficUsage];
    int64_t kb = used / 1024;
    int64_t mb = kb / 1024;
    if (mb == 0) {
        return [NSString stringWithFormat:@"%lldkb",kb];
    }
    return  [NSString stringWithFormat:@"%lldM",mb];
}
-(BOOL) setuserTrafficUsage:(int64_t)ver
{
    NSString* info = [NSString stringWithFormat:@"%lld",ver];
    return [self setUserInfo:UserTrafficUsage info:info];
}
//
- (BOOL) setUserLevel:(int)ver
{
    NSString* level = [NSString stringWithFormat:@"%d",ver];
    return [self setUserInfo:UserLevel info:level];
}
- (int) userLevel
{
    NSString* level = [self userInfo:UserLevel];
    if (!level) {
        return 0;
    } else
    {
        return [level intValue];
    }
}
//

- (BOOL) setUserLevelName:(NSString*)levelName
{
    return [self setUserInfo:UserLevelName info:levelName];
}

- (NSString*) userLevelName
{
    return [self userInfo:UserLevelName];
}
//
- (BOOL) setUserType:(NSString*)userType
{
    return [self setUserInfo:UserType info:userType];
}
- (NSString*) userType
{
    return [self userInfo:UserType];
}
//
- (BOOL) setUserPoints:(int64_t)ver
{
    NSString* userPoints = [NSString stringWithFormat:@"%lld",ver];
    return [self setUserInfo:UserPoints info:userPoints];
}
- (int64_t) userPoints
{
    NSString* userPoints = [self userInfo:UserPoints];
    if(!userPoints)
        return 0;
    else
        return [userPoints longLongValue];
}
- (NSString*) userPointsString
{
    return [self userInfo:UserPoints];
}
//
- (BOOL) setAutomicSync:(BOOL)automicSync
{
    NSString* automic = [NSString stringWithFormat:@"%d",automicSync];
    return [self setUserInfo:AutomicSync info:automic];
}
- (BOOL) isAutomicSync
{
    NSString* automic = [self userInfo:AutomicSync];
    if (nil == automic || [automic isBlock]) {
        [self setAutomicSync:YES];
        return YES;
    }
    else {
        return [automic boolValue];
    }
}

//
- (BOOL) setNewNoteDefaultFolder:(NSString *)folder
{
    if (folder == nil) {
        return NO;
    }
    return [self setUserInfo:NewNoteDefaultFolder info:folder];
}
- (NSString*) newNoteDefaultFolder
{
    NSString* folder = [self userInfo:NewNoteDefaultFolder];
    if (folder ==  nil || [folder isBlock]) {
        NSString* defaultFolder = @"/My Notes/";
        [self setNewNoteDefaultFolder:folder];
        return defaultFolder;
    }
    return [folder retain];
}


//
- (BOOL) setGlobalSetting:(NSString*)key  value:(NSString*)value
{
    [self updateSetting:key value:value accountUserId:@"Global"];
    return YES;
}

- (NSString*) globalSetting:(NSString*)key
{
    WizSetting* setting = [self settingByKey:key accountUserId:@"Global"];
    if (setting) {
        return setting.value;
    }
    else {
        return nil;
    }
}
//
- (NSString*) defaultAccountUserId
{
    NSString* userId = [self globalSetting:DefaultAccountUserID];
    if (userId == nil || [userId isBlock]) {
        return @"";
    }
    return userId;
}

- (BOOL) setWizDefaultAccountUserId:(NSString *)userId
{
    if (userId == nil) {
        return NO;
    }
    return [self setGlobalSetting:DefaultAccountUserID value:userId];
}

@end
