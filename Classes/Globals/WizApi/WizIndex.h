////
////  WizIndex.h
////  Wiz
////
////  Created by Wei Shijun on 3/8/11.
////  Copyright 2011 WizBrother. All rights reserved.
////
//
//#import <Foundation/Foundation.h>
//#define ConnectServerOnlyByWif      @"ConnectServerOnlyByWif"
//typedef NSUInteger WizTableOrder;
////%2 is reverse
//enum
//{
//     kOrderDate=1,
//     kOrderReverseDate=2,
//     kOrderFirstLetter=3,
//     kOrderReverseFirstLetter=4,
//     kOrderCreatedDate=5,
//     kOrderReverseCreatedDate=6
//};
//
//@class WizIndexData;
//@class ZipArchive;
//@class WizTempIndexData;
//@class WizDocument;
//@interface WizAbstract : NSObject {
//@private
//    UIImage* image;
//    NSString* text;
//}
//@property (nonatomic, retain) UIImage* image;
//@property (nonatomic, retain) NSString* text;
//@end
//
//@interface WizDeletedGUID : NSObject
//{
//	NSString* guid;
//	NSString* type;
//	NSString* dateDeleted;
//}
//
//@property (nonatomic, retain) NSString* guid;
//@property (nonatomic, retain) NSString* type;
//@property (nonatomic, retain) NSString* dateDeleted;
//
//
//@end
//
//@interface WizIndex : NSObject {
//	WizIndexData* _indexData;
//    WizTempIndexData* _tempIndexData;
//	NSString* accountUserId;
//}
//@property (nonatomic, retain) NSString* accountUserId;
//
//+ (id) activeIndex;
//
//- (id) initWithAccount: (NSString*)userId;
//
//- (BOOL) isOpened;
//- (BOOL) open;
//- (void) close;
//- (void) initAccountSetting;
//- (NSArray*) rootLocations;
//- (NSArray*) childLocations: (NSString*)parentLocation;
//- (NSArray*) documentsByLocation: (NSString*)parentLocation;
//- (NSArray*) documentsByTag: (NSString*)tagGUID;
//- (NSArray*) documentsByKey: (NSString*)keywords;
//- (NSArray*) recentDocuments;
//- (NSArray*) documentForUpload;
//- (NSArray*) allDeletedGUIDs;
//- (NSArray*) deletedGUIDsForUpload;
//- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
//- (BOOL) addFolder: (NSString*)parentLocation newFolderName: (NSString*)folderName;
//- (BOOL) addLocation: (NSString*) location;
//- (BOOL) updateLocations:(NSArray*) locations;
//- (BOOL) updateTag: (NSDictionary*) tag;
//- (BOOL) updateTags: (NSArray*) tags;
//- (WizTag*) newTag:(NSString*) name  description:(NSString *)description parentTagGuid:(NSString*)parentTagGuid;
//- (NSArray*) allLocationsForTree;
//- (NSArray*) allTagsForTree;
//- (NSArray*) tagsByDocumentGuid:(NSString*)documentGUID;
//- (void) extractSummary:(NSString*)documentGUID;
//- (BOOL) editDocumentWithGuidAndData:(NSDictionary*)documentData;
//- (BOOL) updateDocument: (NSDictionary*) doc;
//- (BOOL) updateDocuments: (NSArray*) documents;
//- (BOOL) updateDocumentData:(NSData*)data documentGUID:(NSString*)documentGUID;
//- (BOOL) documentServerChanged:(NSString*)documentGUID;
//- (BOOL) documentLocalChanged:(NSString*)documentGUID;
//- (BOOL) updateAttachement:(NSDictionary*) attachment;
//- (BOOL) updateAttachementList:(NSArray*) list;
//- (BOOL) deleteAttachment:(NSString*) attachGuid;
//- (BOOL) setDocumentLocalChanged:(NSString*)documentGUID changed:(BOOL)changed;
//- (BOOL) setDocumentServerChanged:(NSString*)documentGUID changed:(BOOL)changed;
//- (BOOL) setDocumentTags:(NSString*)documentGUID tags:(NSString*)tagsString;
//- (BOOL) setDocumentAttachCount:(NSString*)documentGUID count:(int)count;
//- (BOOL) setDocumentMD5:(NSString*)documentGUID md5:(NSString*)md5;
//- (BOOL) setDocumentLocation:(NSString*)documentGUID location:(NSString*)location;
//- (BOOL) setDocumentModifiedDate:(NSString*)documentGUID modifiedDate:(NSDate*) modifiedDate;
//- (BOOL) setAttachmentLocalChanged:(NSString*)attchmentGUID changed:(BOOL)changed;
//- (BOOL) setAttachmentServerChanged:(NSString*)attchmentGUID changed:(BOOL)changed;
//- (BOOL) newNote:(NSString*)title text:(NSString*)text location:(NSString*)location;
//- (BOOL) newNoteWithGUID:(NSString*) title text:(NSString*)text location:(NSString*)location GUID:(NSString*) guid;
//- (BOOL) newPhoto:(UIImage*)image title:(NSString*)title text:(NSString*)text location:(NSString*)location;
//- (BOOL) editDocument:(NSString*)documentGUID documentText:(NSString*)text documentTitle:(NSString*)title;
//- (BOOL) deleteDocument:(NSString*)documentGUID;
//- (BOOL) deleteTag:(NSString*)tagGUID;
//- (NSString*) meta: (NSString*)name key:(NSString*)key;
//- (BOOL) setMeta: (NSString*)name key:(NSString*)key value:(NSString*)value;
//- (BOOL) boolMetaDef: (NSString*)name key:(NSString*)key def:(BOOL)def;
//- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
//- (BOOL) removeDeletedGUIDRecord: (NSString*)guid;
//- (BOOL) clearDeletedGUIDs;
//- (BOOL) hasDeletedGUIDs;
////wiz-dzpqzb create zip file by object-guid
//- (NSString*) attachmentFileMd5:(NSString*)attachmentGUID;
//- (NSString*) createZipByGuid:(NSString*)objectGUID ;
//- (BOOL) downloadAllList;
//- (BOOL) downloadDocumentData;
//- (BOOL) protect;
//- (void) setDownloadAllList: (BOOL) b;
//- (void) setDownloadDocumentData: (BOOL) b;
//- (void) setProtect: (BOOL) b;
//- (NSString*) nextDocumentForDownload;
//- (int64_t)     documentVersion;
//- (int64_t)     deletedGUIDVersion;
//- (int64_t)     tagVersion;
//- (NSString*)   documentVersionString;
//- (NSString*)   deletedGUIDVersionString;
//- (NSString*)   tagVersionString;
//- (BOOL)        setDocumentVersion:(int64_t)ver;
//- (BOOL)        setDeletedGUIDVersion:(int64_t)ver;
//- (BOOL)        setTageVersion:(int64_t)ver;
//- (BOOL)        updateObjectDataByPath:(NSString*) objectZipFilePath objectGuid:(NSString*)objectGuid;
//- (NSNumber*)   appendObjectDataByPath:(NSString*) objectFilePath data:(NSData*)data;
//- (BOOL)        updateDocumentTags:(NSString*) documentGuid tagGuids:(NSString*) tagGuids;
//- (NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
//- (NSArray*) attachmentsForUpload;
//- (WizDocumentAttach*) attachmentFromGUID:(NSString*) attachmentGUID;
//- (NSArray*) tagsWillPostList;
//- (WizTag*) tagFromGuid:(NSString*)guid;
//- (int) fileCountOfLocation:(NSString*)location;
//- (int) fileCountOfTag:(NSString*)tagGUID;
//- (int) attachmentCountOfDocument:(NSString*) documentGUID;
//- (NSString*) userTrafficLimitString;
//- (NSString*) userTrafficUsageString;
//- (int64_t) userTrafficLimit;
//- (BOOL) setUserTrafficLimit:(int64_t)ver;
//- (int64_t) userTrafficUsage;
//- (BOOL) setuserTrafficUsage:(int64_t)ver;
//- (BOOL) setUserLevel:(int)ver;
//- (int) userLevel;
//- (BOOL) setUserLevelName:(NSString*)levelName;
//- (NSString*) userLevelName;
//- (BOOL) setuserTrafficUsage:(int64_t)ver;
//- (BOOL) setUserType:(NSString*)userType;
//- (NSString*) userType;
//- (BOOL) setUserPoints:(int64_t)ver;
//- (int64_t) userPoints;
//- (NSString*) userPointsString;
//- (int64_t) imageQualityValue;
//- (BOOL) setImageQualityValue:(int64_t)value;
//- (int) webFontSize;
//- (BOOL) setUserTableListViewOption:(int64_t)option;
//- (int64_t) userTablelistViewOption;
//- (BOOL) setWebFontSize:(int)fontsize;
//- (BOOL) attachmentSeverChanged:(NSString*)attachmentGUID;
//- (NSString*) attachmentVersionString;
//- (int64_t) attachmentVersion;
//- (BOOL) setAttachmentVersion:(int64_t)ver;
//- (BOOL) isMoblieView;
//- (BOOL) setDocumentMoblleView:(BOOL)mobileView;
//- (NSString*) documentViewFilename:(NSString*)documentGUID;
//- (int64_t) durationForDownloadDocument;
//- (NSString*) durationForDownloadDocumentString;
//- (BOOL) setDurationForDownloadDocument:(int64_t)duration;
//- (NSArray*) documentForDownload;
//- (BOOL) newNoteWithGuidAndData:(NSDictionary*)documentData;
//- (int64_t) wizDataBaseVersion;
//- (BOOL) setWizDataBaseVersion:(int64_t)ver;
////2011-12-29
//- (WizAbstract*) abstractOfDocument:(NSString*)documentGUID;
//- (void) extractSummary:(NSString *)documentGUID;
//-(NSString*) newAttachment:(NSString*) filePath documentGUID:(NSString*)documentGUID;
//- (NSString*) documentAbstractStringFilePath:(NSString*)documentGUID;
//- (NSString*) documentAbstractImageFilePath:(NSString*) documentGUID;
//- (NSString*) documentAbstractFilePath:(NSString*)documentGUID;
////
////2011-12-30
////2012-1-4
//- (BOOL) abstractExist:(NSString*)documentGUID;
//- (BOOL) deleteAbstractByGUID:(NSString*)documentGUID;
////2012-1-14
//- (BOOL) setFirstLog:(BOOL)first;
//- (BOOL) isFirstLog;
//- (BOOL) setDocumentMoblleView:(BOOL)mobileView;
////2012-2-22
//- (BOOL) clearCache;
////2012-2-24
//- (NSString*) updateObjectDateTempFilePath:(NSString*)objGUID;
////2012-2-18
//- (BOOL) setConnectOnlyViaWifi:(BOOL)wifi;
//- (BOOL) connectOnlyViaWifi;
////2012-3-8
//- (NSString*) newDocumentWithOneAttachment:(NSURL*)fileUrl;
//- (NSString*) wizUpgradeAppVersion;
//- (BOOL) setWizUpgradeAppVersion:(NSString*)ver;
////2012-4-6
//- (BOOL) documentMobileViewExist:(NSString*)documentGUID;
//- (BOOL) checkWebnoteIsNew:(NSString*)filePath;
//- (int) filecountWithChildOfLocation:(NSString*) location;
//+ (NSString*) accountTempFileName:(NSString*)userId;
//+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime;
//+ (NSString*) accountPath: (NSString*)userId;
//+ (NSString*) accountFileName: (NSString*)userId;
//+ (NSString*) documentFileName:(NSString*)userId documentGUID:(NSString*)documentGUID;
//+ (NSString*) documentFilePath:(NSString*)userId documentGUID:(NSString*)documentGUID;
//+ (NSString*) documentOrgFileName:(NSString*)userId documentGUID:(NSString*)documentGUID fileExt:(NSString*)fileExt;
//+ (NSString*) pathName: (NSString*)location;
//+ (int) pathLevel: (NSString*)location;
//-(BOOL) deleteTempFileByGUID:(NSString*)objectGuid;
//+ (NSString*) locationLocaleName:(NSString*)location;
//+ (NSString*) pinyinFirstLetter:(NSString*)string;
//-(BOOL) addToZipFile:(NSString*)directory directoryName:(NSString*)name zipFile:(ZipArchive*) zip;
//+ (NSString*) documentIndexFilesPath:(NSString*)userId documentGUID:(NSString*)documentGUID;
////
//- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid;
//@end
//
//@interface WizIndex (WizOrder)
//+(BOOL) isReverseOrder:(WizTableOrder) order;
//@end
