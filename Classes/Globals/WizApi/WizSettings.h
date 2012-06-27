//
//  WizSettings.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizSettingsDbDelegate.h"


@interface WizSettings : NSObject 
{
    id<WizSettingsDbDelegate> settingsDbDelegate;
}
@property (nonatomic, retain) id<WizSettingsDbDelegate> settingsDbDelegate;

+ (id) defaultSettings;
- (int64_t) wizDataBaseVersion;
- (BOOL) setWizDataBaseVersion:(int64_t)ver;
//settings
- (int64_t) imageQualityValue;
- (BOOL) setImageQualityValue:(int64_t)value;
//
- (BOOL) connectOnlyViaWifi;
- (BOOL) setConnectOnlyViaWifi:(BOOL)wifi;
//
- (BOOL) setUserTableListViewOption:(int64_t)option;
- (int64_t) userTablelistViewOption;
//
- (int) webFontSize;
- (BOOL) setWebFontSize:(int)fontsize;
//
- (NSString*) wizUpgradeAppVersion;
- (BOOL) setWizUpgradeAppVersion:(NSString*)ver;
- (int64_t) durationForDownloadDocument;
- (NSString*) durationForDownloadDocumentString;
- (BOOL) setDurationForDownloadDocument:(int64_t)duration;
- (BOOL) isMoblieView;
- (BOOL) isFirstLog;
- (BOOL) setFirstLog:(BOOL)first;
- (BOOL) setDocumentMoblleView:(BOOL)mobileView;
- (int64_t) userTrafficLimit;
- (BOOL) setUserTrafficLimit:(int64_t)ver;
- (NSString*) userTrafficLimitString;
//
- (int64_t) userTrafficUsage;
- (NSString*) userTrafficUsageString;
- (BOOL) setuserTrafficUsage:(int64_t)ver;
//
- (BOOL) setUserLevel:(int)ver;
- (int) userLevel;
//
- (BOOL) setUserLevelName:(NSString*)levelName;
- (NSString*) userLevelName;
//
- (BOOL) setUserType:(NSString*)userType;
- (NSString*) userType;
//
- (BOOL) setUserPoints:(int64_t)ver;
- (int64_t) userPoints;
- (NSString*) userPointsString;
//
- (NSURL*) wizServerUrl;
//
- (BOOL) isAutomicSync;
- (BOOL) setAutomicSync:(BOOL)automic;
//
- (void) setPasscode:(NSString*)passcode;
- (NSString*) passCode;
- (void) setPasscodeEnable:(BOOL) enable;
- (BOOL) isPasscodeEnable;
- (void) setEraseDataEnable:(BOOL)enable;
- (BOOL) isEraseDataEnable;
//
- (BOOL) setLastSynchronizedDate:(NSDate*)lastDate;
- (NSDate*) lastSynchronizeDate;
//

- (BOOL) setGroupLastSyncDate:(NSString*)kbGuid;
- (NSDate*) groupLastSyncDate:(NSString*)kbGuid;
//
- (BOOL) setGroupAutoDownload:(NSString*)kb isAuto:(BOOL)isAuto;
- (BOOL) isGroupAutoDownload:(NSString*)kb;
@end
