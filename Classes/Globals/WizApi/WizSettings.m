//
//  WizSettings.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSettings.h"
#import "WizAccountManager.h"
#import "WizSettingsDbDelegate.h"
#import "WizDbManager.h"

#define WizServerUrlString  @"WizServerUrl"
#define WizPasscode         @"WizPasscode"
#define WizPasscodeEnable   @"WizPasscodeEnable"
#define WizEraseDataEnable  @"WizEraseDataEnable"

@interface WizSettings ()

@end

@implementation WizSettings
@synthesize settingsDbDelegate;
//single object
static WizSettings* defaultSettings = nil;
- (void) dealloc
{
    [super dealloc];
}
+ (id) defaultSettings
{
    @synchronized(defaultSettings)
    {
        if (defaultSettings == nil) {
            defaultSettings = [[super allocWithZone:NULL] init];
        }
        return defaultSettings;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self defaultSettings] retain];
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
// over


- (id) init
{
    self = [super init];
    if (self) {
        id<WizSettingsDbDelegate> dataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
        self.settingsDbDelegate = dataBase;
    }
    return self;
}

- (int64_t) wizDataBaseVersion
{
    return [self.settingsDbDelegate wizDataBaseVersion];
}
- (BOOL) setWizDataBaseVersion:(int64_t)ver
{
    return [self.settingsDbDelegate setWizDataBaseVersion:ver];
}
//settings
- (int64_t) imageQualityValue
{
    return [self.settingsDbDelegate imageQualityValue];
}
- (BOOL) setImageQualityValue:(int64_t)value
{
    return [self.settingsDbDelegate setImageQualityValue:value];
}
//
- (BOOL) connectOnlyViaWifi
{
    return [self.settingsDbDelegate connectOnlyViaWifi];
}
- (BOOL) setConnectOnlyViaWifi:(BOOL)wifi
{
    return [self.settingsDbDelegate setConnectOnlyViaWifi:wifi];
}
//
- (BOOL) setUserTableListViewOption:(int64_t)option
{
    return [self.settingsDbDelegate setUserTableListViewOption:option];
}
- (int64_t) userTablelistViewOption
{
    int64_t ret = [self.settingsDbDelegate userTablelistViewOption];
    if (ret < 1) {
        [self setUserTableListViewOption:2];
    }
    return [self.settingsDbDelegate userTablelistViewOption];
}
//
- (int) webFontSize
{
    return [self.settingsDbDelegate webFontSize];
}
- (BOOL) setWebFontSize:(int)fontsize
{
    return [self.settingsDbDelegate setWebFontSize:fontsize];
}
//
- (NSString*) wizUpgradeAppVersion
{
    return [self.settingsDbDelegate wizUpgradeAppVersion];
}
- (BOOL) setWizUpgradeAppVersion:(NSString*)ver
{
    return [self.settingsDbDelegate setWizUpgradeAppVersion:ver];
}
- (int64_t) durationForDownloadDocument
{
    return [self.settingsDbDelegate durationForDownloadDocument];
}
- (NSString*) durationForDownloadDocumentString
{
    return [self.settingsDbDelegate durationForDownloadDocumentString];
}
- (BOOL) setDurationForDownloadDocument:(int64_t)duration
{
    return [self.settingsDbDelegate setDurationForDownloadDocument:duration];
}
- (BOOL) isMoblieView
{
    return [self.settingsDbDelegate isMoblieView];
}
- (BOOL) isFirstLog
{
    return [self.settingsDbDelegate isFirstLog];
}
- (BOOL) setFirstLog:(BOOL)first
{
    return [self.settingsDbDelegate setFirstLog:first];
}
- (BOOL) setDocumentMoblleView:(BOOL)mobileView
{
    return [self.settingsDbDelegate setDocumentMoblleView:mobileView];
}
- (int64_t) userTrafficLimit
{
    return [self.settingsDbDelegate userTrafficLimit];
}
- (BOOL) setUserTrafficLimit:(int64_t)ver
{
    return [self.settingsDbDelegate setUserTrafficLimit:ver];
}
- (NSString*) userTrafficLimitString
{
    return [self.settingsDbDelegate userTrafficLimitString];
}
//
- (int64_t) userTrafficUsage
{
    return [self.settingsDbDelegate userTrafficUsage];
}
- (NSString*) userTrafficUsageString
{
    return [self.settingsDbDelegate userTrafficUsageString];
}
- (BOOL) setuserTrafficUsage:(int64_t)ver
{
    return [self.settingsDbDelegate setuserTrafficUsage:ver];
}
//
- (BOOL) setUserLevel:(int)ver
{
    return [self.settingsDbDelegate setUserLevel:ver];
}
- (int) userLevel
{
    return [self.settingsDbDelegate userLevel];
}
//
- (BOOL) setUserLevelName:(NSString*)levelName
{
    return [self.settingsDbDelegate setUserLevelName:levelName];
}
- (NSString*) userLevelName
{
    return [self.settingsDbDelegate userLevelName];
}
//
- (BOOL) setUserType:(NSString*)userType
{
    return [self.settingsDbDelegate setUserType:userType];
}
- (NSString*) userType
{
    return [self.settingsDbDelegate userType];
}
//
- (BOOL) setUserPoints:(int64_t)ver
{
    return [self.settingsDbDelegate setUserPoints:ver];
}
- (int64_t) userPoints
{
    return [self.settingsDbDelegate userPoints];
}
- (NSString*) userPointsString
{
    return [self.settingsDbDelegate userPointsString];
}
- (NSURL*) wizServerUrl
{
    static NSURL* url = nil;
    if (!url) {
        url = [[NSURL alloc] initWithString:@"http://service.wiz.cn/wizkm/xmlrpc"];
    }
    return url;
    //    return [[NSURL alloc] initWithString:@"http://192.168.1.155:8800/wiz/xmlrpc"];
}
//
- (BOOL) setAutomicSync:(BOOL)automic
{
    return [self.settingsDbDelegate setAutomicSync:automic];
}
- (BOOL) isAutomicSync
{
    return [self.settingsDbDelegate isAutomicSync];
}
//
- (void) setPasscode:(NSString*)passcode
{
    [[NSUserDefaults standardUserDefaults] setObject:passcode forKey:WizPasscode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) passCode
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:WizPasscode];
}

- (void) setPasscodeEnable:(BOOL) enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:WizPasscodeEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) isPasscodeEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:WizPasscodeEnable];
}

- (void) setEraseDataEnable:(BOOL)enable
{
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:WizEraseDataEnable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL) isEraseDataEnable
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:WizEraseDataEnable];
}
//
- (BOOL) setLastSynchronizedDate:(NSDate*)lastDate
{
    return [self.settingsDbDelegate setLastSynchronizedDate:lastDate];
}
- (NSDate*) lastSynchronizeDate
{
    return [self.settingsDbDelegate lastSynchronizedDate];
}
//
- (BOOL) setNewNoteDefaultFolder:(NSString*)folder
{
    return [self.settingsDbDelegate setNewNoteDefaultFolder:folder];
}
- (NSString*) newNoteDefaultFolder
{
    return [self.settingsDbDelegate newNoteDefaultFolder];
}
//
- (BOOL) setGroupLastSyncDate:(NSString *)kbGuid
{
    return [self.settingsDbDelegate setGroupLastSyncDate:kbGuid];
}
- (NSDate*) groupLastSyncDate:(NSString *)kbGuid
{
    return [self.settingsDbDelegate groupLastSyncDate:kbGuid];
}
- (BOOL) setGroupAutoDownload:(NSString*)kb isAuto:(BOOL)isAuto
{
    return [self.settingsDbDelegate setGroupAutoDownload:kb isAuto:isAuto];
}
- (BOOL) isGroupAutoDownload:(NSString*)kb
{
    return [self.settingsDbDelegate isGroupAutoDownload:kb];
}
//
- (BOOL) deleteAccountSettings:(NSString*)userID
{
    return [self.settingsDbDelegate deleteAccountSettings:userID];
}
@end