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
}
@property (nonatomic, retain) NSString* location;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSDate* dateCreated;
@property (nonatomic, retain) NSDate* dateModified;
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* fileType;
@property (nonatomic, retain) NSString* tagGuids;
@property (nonatomic, retain) NSString* dataMd5;
@property (assign) BOOL serverChanged;
@property (assign) WizEditDocumentType localChanged;
@property (assign) BOOL protected_;
@property int attachmentCount;
- (NSComparisonResult) compareModifiedDate:(WizDocument*) doc;
- (NSComparisonResult) compareReverseModifiedDate:(WizDocument*) doc;
- (NSComparisonResult) compareWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument*) doc;
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc;
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc;
- (BOOL) isNewWebnote;
- (BOOL) isExistMobileViewFile;
- (BOOL) isExistAbstractFile;
- (BOOL) isExistIndexFile;

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
+ (WizDocument*) documentFromDb:(NSString*)guid;

//
- (NSString*) localDataMd5;
- (NSArray*) tagDatas;
+ (void) deleteDocument:(WizDocument*)document;
- (NSArray*) attachments;

//
- (BOOL) saveInfo;
- (void) upload;
- (void) download;
//
- (BOOL) saveWithData:(NSString*)textBody   attachments:(NSArray*)documentsSourceArray;
- (void) setTagWithArray:(NSArray*)tags;
- (NSArray*) existPhotoAndAudio;
- (BOOL) deleteTag:(NSString*)tagGuid;
//
+ (NSArray*)documentsForCache;
- (BOOL) isIosDocument;
@end
