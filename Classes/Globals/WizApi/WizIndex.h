//
//  WizIndex.h
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kOrderDate                  1
#define kOrderReverseDate           2
#define kOrderFirstLetter           3
#define kOrderReverseFirstLetter    4
#define kOrderCreatedDate           5
#define kOrderReverseCreatedDate    6

#define WizIosAppVersionKeyString  @"3.0.5"
#define ConnectServerOnlyByWif      @"ConnectServerOnlyByWif"
@class WizIndexData;
@class ZipArchive;
@class WizTempIndexData;
@interface WizAbstract : NSObject {
@private
    UIImage* image;
    NSString* text;
}
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) NSString* text;
@end



@interface WizTag : NSObject
{
	NSString* name;
	NSString* guid;
	NSString* parentGUID;
	NSString* description;
	NSString* namePath;
    int       localChanged;
    NSString*   dtInfoModified;
}

@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* parentGUID;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* namePath;
@property (nonatomic, retain) NSString*   dtInfoModified;
@property int localChanged;

@end

@interface WizDocument : NSObject 
{
	NSString* guid;
	NSString* title;
	NSString* location;
	NSString* url;
	NSString* dateCreated;
	NSString* dateModified;
	NSString* type;
	NSString* fileType;
    NSString* tagGuids;
    BOOL serverChanged;
    BOOL localChanged;
	int attachmentCount;
}

@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* dateCreated;
@property (nonatomic, retain) NSString* dateModified;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* fileType;
@property (nonatomic, retain) NSString* tagGuids;
@property (assign) BOOL serverChanged;
@property (assign) BOOL localChanged;
@property int attachmentCount;
- (NSComparisonResult) compareDate:(WizDocument*) doc;
- (NSComparisonResult) compareReverseDate:(WizDocument*) doc;
- (NSComparisonResult) compareWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc;
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc;
@end

@interface WizDeletedGUID : NSObject
{
	NSString* guid;
	NSString* type;
	NSString* dateDeleted;
}

@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* dateDeleted;


@end

@interface WizDocumentAttach : NSObject {
    NSString* attachmentGuid;
    NSString* attachmentType;
    NSString* attachmentName;
    NSString* attachmentDataMd5;
    NSString* attachmentDescription;
    NSString* attachmentModifiedDate;
    NSString* attachmentDocumentGuid;
    BOOL      serverChanged;
    BOOL      localChanged;
}
@property (nonatomic, retain) NSString* attachmentGuid;
@property (nonatomic, retain) NSString* attachmentType;
@property (nonatomic, retain) NSString* attachmentName;
@property (nonatomic, retain) NSString* attachmentDataMd5;
@property (nonatomic, retain) NSString* attachmentDescription;
@property (nonatomic, retain) NSString* attachmentModifiedDate;
@property (nonatomic, retain) NSString* attachmentDocumentGuid;
@property (assign) BOOL      serverChanged;
@property (assign) BOOL      localChanged;
@end


@interface WizIndex : NSObject {
	WizIndexData* _indexData;
	//
    WizTempIndexData* _tempIndexData;
	NSString* accountUserId;
}
@property (nonatomic, retain) NSString* accountUserId;
- (id) initWithAccount: (NSString*)userId;

- (BOOL) isOpened;
- (BOOL) open;
- (void) close;
- (void) initAccountSetting;
- (NSArray*) rootLocations;
- (NSArray*) childLocations: (NSString*)parentLocation;
- (NSArray*) documentsByLocation: (NSString*)parentLocation;
- (NSArray*) documentsByTag: (NSString*)tagGUID;
- (NSArray*) documentsByKey: (NSString*)keywords;
- (NSArray*) recentDocuments;
- (NSArray*) documentForUpload;
- (NSArray*) allDeletedGUIDs;
- (NSArray*) deletedGUIDsForUpload;
- (WizDocument*) documentFromGUID:(NSString*)documentGUID;
- (BOOL) addFolder: (NSString*)parentLocation newFolderName: (NSString*)folderName;
- (BOOL) addLocation: (NSString*) location;
- (BOOL) updateLocations:(NSArray*) locations;
- (BOOL) updateTag: (NSDictionary*) tag;
- (BOOL) updateTags: (NSArray*) tags;
- (WizTag*) newTag:(NSString*) name  description:(NSString *)description parentTagGuid:(NSString*)parentTagGuid;
- (NSArray*) allLocationsForTree;
- (NSArray*) allTagsForTree;
- (NSArray*) tagsByDocumentGuid:(NSString*)documentGUID;
- (void) extractSummary:(NSString*)documentGUID;
- (BOOL) editDocumentWithGuidAndData:(NSDictionary*)documentData;
- (BOOL) updateDocument: (NSDictionary*) doc;
- (BOOL) updateDocuments: (NSArray*) documents;
- (BOOL) updateDocumentData:(NSData*)data documentGUID:(NSString*)documentGUID;
- (BOOL) documentServerChanged:(NSString*)documentGUID;
- (BOOL) documentLocalChanged:(NSString*)documentGUID;
- (BOOL) updateAttachement:(NSDictionary*) attachment;
- (BOOL) updateAttachementList:(NSArray*) list;
- (BOOL) deleteAttachment:(NSString*) attachGuid;
- (BOOL) setDocumentLocalChanged:(NSString*)documentGUID changed:(BOOL)changed;
- (BOOL) setDocumentServerChanged:(NSString*)documentGUID changed:(BOOL)changed;
- (BOOL) setDocumentTags:(NSString*)documentGUID tags:(NSString*)tagsString;
- (BOOL) setDocumentAttachCount:(NSString*)documentGUID count:(int)count;
- (BOOL) setDocumentMD5:(NSString*)documentGUID md5:(NSString*)md5;
- (BOOL) setDocumentLocation:(NSString*)documentGUID location:(NSString*)location;
- (BOOL) setDocumentModifiedDate:(NSString*)documentGUID modifiedDate:(NSDate*) modifiedDate;
- (BOOL) setAttachmentLocalChanged:(NSString*)attchmentGUID changed:(BOOL)changed;
- (BOOL) setAttachmentServerChanged:(NSString*)attchmentGUID changed:(BOOL)changed;
- (BOOL) newNote:(NSString*)title text:(NSString*)text location:(NSString*)location;
- (BOOL) newNoteWithGUID:(NSString*) title text:(NSString*)text location:(NSString*)location GUID:(NSString*) guid;
- (BOOL) newPhoto:(UIImage*)image title:(NSString*)title text:(NSString*)text location:(NSString*)location;
- (BOOL) editDocument:(NSString*)documentGUID documentText:(NSString*)text documentTitle:(NSString*)title;
- (BOOL) deleteDocument:(NSString*)documentGUID;
- (BOOL) deleteTag:(NSString*)tagGUID;
- (NSString*) meta: (NSString*)name key:(NSString*)key;
- (BOOL) setMeta: (NSString*)name key:(NSString*)key value:(NSString*)value;
- (BOOL) boolMetaDef: (NSString*)name key:(NSString*)key def:(BOOL)def;
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type;
- (BOOL) removeDeletedGUIDRecord: (NSString*)guid;
- (BOOL) clearDeletedGUIDs;
- (BOOL) hasDeletedGUIDs;
//wiz-dzpqzb create zip file by object-guid
- (NSDictionary*) attachmentFileMd5:(NSString*)attachmentGUID;
- (NSString*) createZipByGuid:(NSString*)objectGUID ;
- (BOOL) downloadAllList;
- (BOOL) downloadDocumentData;
- (BOOL) protect;
- (void) setDownloadAllList: (BOOL) b;
- (void) setDownloadDocumentData: (BOOL) b;
- (void) setProtect: (BOOL) b;
- (NSString*) nextDocumentForDownload;
- (int64_t)     documentVersion;
- (int64_t)     deletedGUIDVersion;
- (int64_t)     tagVersion;
- (NSString*)   documentVersionString;
- (NSString*)   deletedGUIDVersionString;
- (NSString*)   tagVersionString;
- (BOOL)        setDocumentVersion:(int64_t)ver;
- (BOOL)        setDeletedGUIDVersion:(int64_t)ver;
- (BOOL)        setTageVersion:(int64_t)ver;
- (BOOL)        updateObjectDataByPath:(NSString*) objectZipFilePath objectGuid:(NSString*)objectGuid;
- (NSNumber*)   appendObjectDataByPath:(NSString*) objectFilePath data:(NSData*)data;
- (BOOL)        updateDocumentTags:(NSString*) documentGuid tagGuids:(NSString*) tagGuids;
- (NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID;
- (NSArray*) attachmentsForUpload;
- (WizDocumentAttach*) attachmentFromGUID:(NSString*) attachmentGUID;
- (NSArray*) tagsWillPostList;
- (WizTag*) tagFromGuid:(NSString*)guid;
- (int) fileCountOfLocation:(NSString*)location;
- (int) fileCountOfTag:(NSString*)tagGUID;
- (int) attachmentCountOfDocument:(NSString*) documentGUID;
- (NSString*) userTrafficLimitString;
- (NSString*) userTrafficUsageString;
- (int64_t) userTrafficLimit;
- (BOOL) setUserTrafficLimit:(int64_t)ver;
- (int64_t) userTrafficUsage;
- (BOOL) setuserTrafficUsage:(int64_t)ver;
- (BOOL) setUserLevel:(int)ver;
- (int) userLevel;
- (BOOL) setUserLevelName:(NSString*)levelName;
- (NSString*) userLevelName;
- (BOOL) setuserTrafficUsage:(int64_t)ver;
- (BOOL) setUserType:(NSString*)userType;
- (NSString*) userType;
- (BOOL) setUserPoints:(int64_t)ver;
- (int64_t) userPoints;
- (NSString*) userPointsString;
- (int64_t) imageQualityValue;
- (BOOL) setImageQualityValue:(int64_t)value;
- (int) webFontSize;
- (BOOL) setUserTableListViewOption:(int64_t)option;
- (int64_t) userTablelistViewOption;
- (BOOL) setWebFontSize:(int)fontsize;
- (BOOL) attachmentSeverChanged:(NSString*)attachmentGUID;
- (NSString*) attachmentVersionString;
- (int64_t) attachmentVersion;
- (BOOL) setAttachmentVersion:(int64_t)ver;
- (BOOL) isMoblieView;
- (BOOL) setDocumentMoblleView:(BOOL)mobileView;
- (NSString*) documentViewFilename:(NSString*)documentGUID;
- (int64_t) durationForDownloadDocument;
- (NSString*) durationForDownloadDocumentString;
- (BOOL) setDurationForDownloadDocument:(int64_t)duration;
- (NSArray*) documentForDownload;
- (BOOL) newNoteWithGuidAndData:(NSDictionary*)documentData;
- (int64_t) wizDataBaseVersion;
- (BOOL) setWizDataBaseVersion:(int64_t)ver;
//2011-12-29
- (WizAbstract*) abstractOfDocument:(NSString*)documentGUID;
- (void) extractSummary:(NSString *)documentGUID;
-(NSString*) newAttachment:(NSString*) filePath documentGUID:(NSString*)documentGUID;
- (NSString*) documentAbstractStringFilePath:(NSString*)documentGUID;
- (NSString*) documentAbstractImageFilePath:(NSString*) documentGUID;
- (NSString*) documentAbstractFilePath:(NSString*)documentGUID;
//
//2011-12-30
//2012-1-4
- (BOOL) abstractExist:(NSString*)documentGUID;
- (BOOL) deleteAbstractByGUID:(NSString*)documentGUID;
//2012-1-14
- (BOOL) setFirstLog:(BOOL)first;
- (BOOL) isFirstLog;
- (BOOL) setDocumentMoblleView:(BOOL)mobileView;
- (BOOL) setWizIosAppVersion:(NSString*)ver;
- (NSString*) wizIosAppVersion;
//2012-2-22
- (BOOL) clearCache;
//2012-2-24
- (NSString*) updateObjectDateTempFilePath:(NSString*)objGUID;
//2012-2-18
- (BOOL) setConnectOnlyViaWifi:(BOOL)wifi;
- (BOOL) connectOnlyViaWifi;
//2012-3-8
- (BOOL) newDocumentWithOneAttachment:(NSString*)fileSourePath;
+ (NSString*) accountTempFileName:(NSString*)userId;
+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime;
+ (NSString*) accountPath: (NSString*)userId;
+ (NSString*) accountFileName: (NSString*)userId;
+ (NSString*) documentFileName:(NSString*)userId documentGUID:(NSString*)documentGUID;
+ (NSString*) documentFilePath:(NSString*)userId documentGUID:(NSString*)documentGUID;
+ (NSString*) documentOrgFileName:(NSString*)userId documentGUID:(NSString*)documentGUID fileExt:(NSString*)fileExt;
+ (NSString*) pathName: (NSString*)location;
+ (int) pathLevel: (NSString*)location;
-(BOOL) deleteTempFileByGUID:(NSString*)objectGuid;
+ (NSString*) locationLocaleName:(NSString*)location;
+ (NSString*) pinyinFirstLetter:(NSString*)string;
-(BOOL) addToZipFile:(NSString*)directory directoryName:(NSString*)name zipFile:(ZipArchive*) zip;

@end


