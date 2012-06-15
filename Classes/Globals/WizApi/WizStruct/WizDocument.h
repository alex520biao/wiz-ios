//
//  WizDocument.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
#define WizDocumentTypeAudioKeyString @"audio"
#define WizDocumentTypeImageKeyString @"image"
#define WizDocumentTypeNoteKeyString @"note"
@class WizDataBase;
typedef NSUInteger WizTableOrder;
//%2 is reverse
BOOL isReverseMask(NSInteger mask);
enum
{
     kOrderDate=1,
     kOrderReverseDate=2,
     kOrderFirstLetter=3,
     kOrderReverseFirstLetter=4,
     kOrderCreatedDate=5,
     kOrderReverseCreatedDate=6
};
typedef NSInteger WizEditDocumentType;
enum
{
    WizEditDocumentTypeNoChanged = 0,
    WizEditDocumentTypeInfoChanged = 2,
    WizEditDocumentTypeAllChanged = 1,
};

@interface WizDocument : WizObject
{
	NSString* location;
	NSString* url;
	NSDate* dateCreated;
	NSDate* dateModified;
	NSString* type;
	NSString* fileType;
    NSString* tagGuids;
    NSString* dataMd5;
    BOOL protected_;
    BOOL serverChanged;
    WizEditDocumentType localChanged;
	NSInteger attachmentCount;
    
    float   gpsLatitude;
    float   gpsLongtitude;
    float   gpsAltitude;
    float   gpsDop;
    
    NSString* gpsAddress;
    NSString* gpsCountry;
    NSString* gpsLevel1;
    NSString* gpsLevel2;
    NSString* gpsLevel3;
    
    NSString* gpsDescription;
    int nReadCount;
    
}
@property (atomic, retain) NSString* location;
@property (atomic, retain) NSString* url;
@property (atomic, retain) NSDate* dateCreated;
@property (atomic, retain) NSDate* dateModified;
@property (atomic, retain) NSString* type;
@property (atomic, retain) NSString* fileType;
@property (atomic, retain) NSString* tagGuids;
@property (atomic, retain) NSString* dataMd5;
@property (atomic, assign) BOOL serverChanged;
@property (atomic, assign) WizEditDocumentType localChanged;
@property (atomic, assign) BOOL protected_;
@property (atomic, assign) int attachmentCount;
@property (atomic, assign)     float   gpsLatitude;
@property (atomic, assign)     float   gpsLongtitude;
@property (atomic, assign)     float   gpsAltitude;
@property (atomic, assign)     float   gpsDop;
@property (atomic, assign) int nReadCount;
@property (atomic, retain) NSString* gpsAddress;
@property (atomic, retain) NSString* gpsCountry;
@property (atomic, retain) NSString* gpsLevel1;
@property (atomic, retain) NSString* gpsLevel2;
@property (atomic, retain) NSString* gpsLevel3;
@property (atomic, retain) NSString* gpsDescription;


- (NSComparisonResult) compareModifiedDate:(WizDocument*) doc;
- (NSComparisonResult) compareWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc;
- (BOOL) isNewWebnote;
- (BOOL) isExistMobileViewFile;
- (BOOL) isExistAbstractFile;
- (BOOL) isExistIndexFile;

- (NSString*) documentPath;
- (NSString*) documentIndexFilesPath;
- (NSString*) documentIndexFile;
- (NSString*) documentMobileFile;
- (NSString*) documentAbstractFile;
- (NSString*) documentFullFile;
- (NSString*) documentWillLoadFile;
- (BOOL) addFileToIndexFiles:(NSString*)sourcePath;
//
+ (NSArray*) recentDocuments;
+ (NSArray*) documentsByTag: (NSString*)tagGUID;
+ (NSArray*) documentsByKey: (NSString*)keywords;
+ (NSArray*) documentsByLocation: (NSString*)parentLocation;
+ (NSArray*) documentForUpload;
+ (WizDocument*) documentFromDb:(NSString*)guid  ;

//
- (NSString*) localDataMd5;
- (NSArray*) tagDatas;
+ (void) deleteDocument:(WizDocument*)document;
- (NSArray*) attachments;

//
- (BOOL) saveInfo:(WizDataBase*)dataBase;
- (void) upload;
- (void) download;
//
- (BOOL) saveWithData:(NSString*)textBody   attachments:(NSArray*)documentsSourceArray toDataBase:(WizDataBase*)dataBase;
- (void) setTagWithArray:(NSArray*)tags;
- (NSArray*) existPhotoAndAudio;
//
+ (NSArray*)documentsForCache;
- (BOOL) isIosDocument;
//
- (NSString*)tagDisplayString;

//
- (NSDictionary*) dataBaseModelData;
@end
