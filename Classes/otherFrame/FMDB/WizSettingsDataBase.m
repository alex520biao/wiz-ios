//
//  WizSettingsDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-21.
//
//

#import "WizSettingsDataBase.h"
#import "WizSetting.h"
#import "WizAccountManager.h"

#define WizGlobalSetting  @"GLOBAL"
#define WizGlobalAccountUserId  @"WizGlobalAccountUserId"
@implementation WizSettingsDataBase

- (NSString*) settingWithWhereField:(NSString*)whereField  args:(NSArray*)args
{
    __block NSString* ret = [NSString string];
    [queue inDatabase:^(FMDatabase *db) {
        NSString* sql = [NSString stringWithFormat:@"select SETTING_VALUE from WizSetting %@",whereField];
        FMResultSet* result = [db executeQuery:sql withArgumentsInArray:args];
        if ([result next]) {
            ret = [result stringForColumnIndex:0];
        }
        [result close];
    }];
    if ([ret isBlock]) {
        return nil;
    }
    return ret;
}
- (NSString*) settingByKey:(NSString*)userId kbguid:(NSString*)kbguid key:(NSString*)key
{
    NSString* whereFiled = [NSString stringWithFormat:@"where SETTING_USERID = ? and SETTING_KEY = ? and SETTING_KBGUID = ?"];
    return [self settingWithWhereField:whereFiled args:[NSArray arrayWithObjects:userId,key,kbguid, nil]];
}
- (BOOL) updateSetting:(NSString*)userId  kbGuid:(NSString*)kbguid  key:(NSString*)key value:(NSString*)value
{
    __block BOOL ret;
    if ([self settingByKey:userId kbguid:kbguid key:value]) {
        [queue inDatabase:^(FMDatabase *db) {
           ret = [db executeUpdate:@"update WizSetting set SETTING_VALUE=?, SETTING_DATE_MODIFIED=? where SETTING_USERID=? and SETTING_KBGUID=? and SETTING_KEY=?",value, [[NSDate date] stringSql],userId, kbguid, key];
        }];
    }
    else
    {
        [queue inDatabase:^(FMDatabase *db)
        {
            ret= [db executeUpdate:@"insert into WizSetting (SETTING_VALUE,SETTING_DATE_MODIFIED,SETTING_USERID,SETTING_KBGUID,SETTING_KEY) values(?,?,?,?,?)",value,[[NSDate date] stringSql], userId,kbguid,key];
        }];
    }
    return ret;
}
- (NSString*) userInfo:(NSString*)key
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    return [self settingByKey:userId kbguid:WizGlobalSetting key:key];
}
- (BOOL)  setUserInfo:(NSString*)key info:(NSString*)value
{
    NSString* userId = [[WizAccountManager defaultManager] activeAccountUserId];
    return [self updateSetting:userId kbGuid:WizGlobalSetting key:key value:value];
    return YES;
}
- (int64_t) imageQualityValue
{
    NSString* str = [self userInfo:ImageQuality];
    if(!str)
        return 300;
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
        return kOrderReverseDate;
    }
    else
        return [str longLongValue];
}
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
    [self updateSetting:WizGlobalAccountUserId kbGuid:WizGlobalSetting key:key value:value];
    return YES;
}

- (NSString*) globalSetting:(NSString*)key
{
    return [self settingByKey:WizGlobalAccountUserId kbguid:WizGlobalSetting key:key];
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
//- (NSString*) defaultGroupKbGuid
//{
//    NSString* group = [self globalSetting:DefaultGroupKbGuid];
//    if (group == nil || [group isBlock]) {
//        return [self privateGroup].kbguid;
//    }
//    return group;
//}
//
//- (BOOL) setDefaultGroupKbGuid:(NSString*)groupGuid
//{
//    if (groupGuid == nil || [groupGuid isBlock]) {
//        return NO;
//    }
//    return [self setUserInfo:DefaultGroupKbGuid info:groupGuid];
//}
@end
