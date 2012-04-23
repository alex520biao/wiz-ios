//
//  WizDbDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizDocument;
@class WizAttachment;
@class WizTag;
@protocol WizDbDelegate <NSObject>
// version
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
//
- (BOOL) setDeletedGUIDVersion:(int64_t)ver;
- (int64_t) deletedGUIDVersion;
//
- (int64_t) tagVersion;
- (BOOL) setTageVersion:(int64_t)ver;
//
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
//
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
//userInfo
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
- (BOOL) updateDocuments:(NSArray *)documents;
- (NSArray*) recentDocuments;
- (WizDocument*) documentFromGUID:(NSString *)guid;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
- (BOOL) deleteAttachment:(NSString *)attachGuid;
- (BOOL) deleteTag:(NSString*)tagGuid;
- (BOOL) deleteDocument:(NSString*)documentGUID;




//tag
- (BOOL) updateTag: (NSDictionary*) tag;
- (BOOL) updateTags: (NSArray*) tags;

//attachment
- (BOOL) updateAttachment:(NSDictionary *)attachment;
- (BOOL) updateAttachments:(NSArray *)attachments;

@end
