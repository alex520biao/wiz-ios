//
//  WizIndex.m
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//


#import "tempIndex.h"
#import "WizGlobals.h"
#import "../C++/index.h"
#import "ZipArchive.h"
#import "WizDictionaryMessage.h"
#include "../CommonString.h"
#import "WizIndex.h"
#import "WizSync.h"
#import "TFHpple.h"
#import "pinyin.h"
#import "RegexKitLite.h"
#define WizAbs(x) x>0?x:-x

#define IMAGEABSTRACTTYPE @"IMAGE"
#define STRINGABSTRACTTYPE @"STRING"

NSInteger compareString(id location1, id location2, void*);
NSInteger compareTag(id location1, id location2, void*);

@implementation WizAbstract
@synthesize image;
@synthesize text;
- (void) dealloc
{
    self.image = nil;
    self.text = nil;
    [super dealloc];
}
@end


@implementation WizTag

@synthesize name;
@synthesize guid;
@synthesize parentGUID;
@synthesize description;
@synthesize namePath;
@synthesize dtInfoModified;
@synthesize localChanged;

- (void) dealloc
{
	self.name = nil;
	self.guid = nil;
	self.parentGUID = nil;
	self.description = nil;
	self.namePath = nil;
	[super dealloc];
}


- (id) initFromWizTagData: (const WIZTAGDATA&) data
{
	if (self = [super init])
	{
		self.guid = [[[NSString alloc] initWithUTF8String: data.strGUID.c_str()] autorelease];
		self.parentGUID = [[[NSString alloc] initWithUTF8String: data.strParentGUID.c_str()] autorelease];
		self.name = [[[NSString alloc] initWithUTF8String: data.strName.c_str()] autorelease];
		self.description = [[[NSString alloc] initWithUTF8String: data.strDescription.c_str()] autorelease];
		self.namePath = [[[NSString alloc] initWithUTF8String: data.strNamePath.c_str()] autorelease];
        self.localChanged = data.localchanged;
        self.dtInfoModified = [[[NSString alloc] initWithUTF8String:data.strDtInfoModified.c_str()] autorelease];
        
	}
	return self;
}


@end


@implementation WizDocument

@synthesize guid;
@synthesize title;
@synthesize location;
@synthesize url;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize type;
@synthesize fileType;
@synthesize attachmentCount;
@synthesize tagGuids;
@synthesize serverChanged;
@synthesize localChanged;
-(void) dealloc
{
	self.guid = nil;
	self.title = nil;
	self.location = nil;
	self.url = nil;
	self.type = nil;
	self.fileType = nil;
	self.dateCreated = nil;
	self.dateModified = nil;
    self.tagGuids = nil;
	//
	[super dealloc];
}

- (NSComparisonResult) compareDate:(WizDocument *)doc
{
    return [[WizGlobals sqlTimeStringToDate:self.dateModified] compare:[WizGlobals sqlTimeStringToDate:doc.dateModified]];
}
- (NSComparisonResult) compareReverseDate:(WizDocument *)doc
{
    return ![[WizGlobals sqlTimeStringToDate:self.dateModified] compare:[WizGlobals sqlTimeStringToDate:doc.dateModified]];
}

- (NSComparisonResult) compareWithFirstLetter:(WizDocument *)doc
{
    return [[WizIndex pinyinFirstLetter:self.title] compare:[WizIndex pinyinFirstLetter:doc.title]];
}

- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument *)doc
{
    NSComparisonResult ret = [[WizIndex pinyinFirstLetter:self.title] compare:[WizIndex pinyinFirstLetter:doc.title]];
    if (ret == -1) {
        return 1;
    }
    else if (ret == 1)
    {
        return -1;
    }
    return ret;
}
- (id) initFromWizDocumentData: (const WIZDOCUMENTDATA&) data
{
	if (self = [super init])
	{
		self.guid            = [[[NSString alloc] initWithUTF8String: data.strGUID.c_str()] autorelease];
		self.title           = [[[NSString alloc] initWithUTF8String: data.strTitle.c_str()] autorelease];
		self.location        = [[[NSString alloc] initWithUTF8String: data.strLocation.c_str()] autorelease];
		self.url             = [[[NSString alloc] initWithUTF8String: data.strURL.c_str()] autorelease];
		self.type            = [[[NSString alloc] initWithUTF8String: data.strType.c_str()] autorelease]; 
		self.fileType        = [[[NSString alloc] initWithUTF8String: data.strFileType.c_str()] autorelease]; 
		self.dateCreated     = [[[NSString alloc] initWithUTF8String: data.strDateCreated.c_str()] autorelease];
		self.dateModified    = [[[NSString alloc] initWithUTF8String: data.strDateModified.c_str()] autorelease];
        self.tagGuids           = [[[NSString alloc] initWithUTF8String: data.strTagGUIDs.c_str()] autorelease];
		self.attachmentCount = data.nAttachmentCount;
        self.serverChanged = data.nServerChanged?YES:NO;
        self.localChanged = data.nLocalChanged?YES:NO;
	}
	return self;
}

@end


@implementation WizDeletedGUID

@synthesize guid;
@synthesize type;
@synthesize dateDeleted;

-(void) dealloc
{
	self.guid = nil;
	self.type = nil;
	self.dateDeleted = nil;
	//
	[super dealloc];
}

-(id) initFromWizDeletedGUIDData: (const WIZDELETEDGUIDDATA&) data
{
	if (self = [super init])
	{
		guid = [[NSString alloc] initWithUTF8String:data.strGUID.c_str()];
		type = [[NSString alloc] initWithUTF8String:data.strType.c_str()];
		dateDeleted = [[NSString alloc] initWithUTF8String:data.strDateDeleted.c_str()];
	}
	//
	return self;
}


@end



@interface WizIndexData : NSObject
{
	CIndex _index;
}
-(CIndex&) index;

@end

@implementation WizIndexData

- (CIndex&) index
{
	return _index;
}

@end

@interface WizTempIndexData : NSObject
{
    CTempIndex _tempIndex;
}
- (CTempIndex&) tempIndex;
@end
@implementation WizTempIndexData

- (CTempIndex&) tempIndex
{
    return _tempIndex;
}

@end

@implementation WizDocumentAttach
@synthesize attachmentGuid;
@synthesize attachmentName;
@synthesize attachmentType;
@synthesize attachmentDataMd5;
@synthesize attachmentDescription;
@synthesize attachmentModifiedDate;
@synthesize serverChanged;
@synthesize localChanged;
@synthesize attachmentDocumentGuid;
-(void) dealloc
{
    self.attachmentGuid = nil;
    self.attachmentName = nil;
    self.attachmentType = nil;
    self.attachmentDataMd5 = nil;
    self.attachmentDescription = nil;
    self.attachmentModifiedDate = nil;
    self.serverChanged = nil;
    self.localChanged = nil;
    self.attachmentDocumentGuid = nil;
    [super dealloc];
}

-(id) initFromAttachmentGuidData:(const WIZDOCUMENTATTACH&)data
{
    self = [super init];
    
    self.attachmentDocumentGuid = [NSString stringWithUTF8String:data.strDocumentGuid.c_str()];
    self.attachmentGuid = [NSString stringWithUTF8String:data.strAttachmentGuid.c_str()] ;
    self.attachmentName = [NSString stringWithUTF8String:data.strAttachmentName.c_str()];
    self.attachmentModifiedDate = [NSString stringWithUTF8String:data.strDataModified.c_str()] ;
    self.attachmentDescription = [NSString stringWithUTF8String:data.strDescription.c_str()] ;
    self.attachmentDataMd5 = [NSString stringWithUTF8String:data.strDataMd5.c_str()] ;
    self.localChanged = data.loaclChanged;
    self.serverChanged = data.serverChanged;
    NSArray* typeArry = [self.attachmentName componentsSeparatedByString:@"."];
    self.attachmentType = [typeArry lastObject];
    return  self;
}
@end

@implementation WizIndex

@synthesize accountUserId;

- (id) initWithAccount: (NSString*)userId
{
	if (self = [super init])
	{
		_indexData = [[WizIndexData alloc] init];
        _tempIndexData = [[WizTempIndexData alloc] init];
		//
		self.accountUserId = userId;
	}
	//
	return self;
}
- (void) dealloc
{
    [_tempIndexData release];
	[_indexData release];
	[super dealloc];
}


- (BOOL) isOpened
{
	CIndex& index = [_indexData index];
    CTempIndex& tempIndex = [_tempIndexData tempIndex];
	return (index.IsOpened() && tempIndex.IsOpened())? YES : NO;
}

- (BOOL) open
{
	if ([self isOpened])
	{
		
		return NO;
	}
    NSString* filename = [WizIndex accountFileName: self.accountUserId];
	bool indexB = [_indexData index].Open([filename UTF8String]);
    if (1 != [self wizDataBaseVersion]) {
        [_indexData index].upgradeDB();
        [self setWizDataBaseVersion:1];
        [self setTageVersion:0];
    } 
    [self initAccountSetting];
    
    NSString* tempFileName = [WizIndex accountTempFileName:self.accountUserId];
    bool tempIndexB = [_tempIndexData tempIndex].Open([tempFileName UTF8String]);
	return (tempIndexB && indexB) ? YES : NO;
}
- (void) close
{
    if (![self isOpened])
	{
		
        return;
	}
	//
	//
	[_indexData index].Close();
    [_tempIndexData tempIndex].Close();
}


+ (void) stdStringArrayToNSArray: (const CWizStdStringArray&) arrayLocation retArray:(NSArray**) pretArray
{
	NSMutableArray* arr = [[NSMutableArray alloc] init];
	*pretArray = arr;
	//
	for (CWizStdStringArray::const_iterator it = arrayLocation.begin();
		 it != arrayLocation.end();
		 it++)
	{
		NSString* str = [[NSString alloc] initWithUTF8String:it->c_str()];
		[arr addObject:str];
		[str release];
	}
}
+ (NSArray*) stdStringArrayToNSArrayReturn: (const CWizStdStringArray&) arrayLocation
{
	NSArray* ret = nil;
	//
	[WizIndex stdStringArrayToNSArray: arrayLocation retArray:&ret];
	//
	return [ret autorelease];
}
- (NSArray*) rootLocations
{
	CIndex& index = [_indexData index];
	//
	CWizStdStringArray arrayLocation;
	index.GetRootLocations(arrayLocation);
	//
	return [WizIndex stdStringArrayToNSArrayReturn: arrayLocation];
}
- (NSArray*) childLocations: (NSString*)parentLocation
{
	CIndex& index = [_indexData index];
	//
	CWizStdStringArray arrayLocation;
	index.GetChildLocations([parentLocation UTF8String], arrayLocation);
	//
	return [WizIndex stdStringArrayToNSArrayReturn: arrayLocation];
}

- (NSArray*) documentsFromWizDocumentDataArray: (const CWizDocumentDataArray&) arrayDocument
{
	NSMutableArray* arr = [NSMutableArray array];
	//
	for (CWizDocumentDataArray::const_iterator it = arrayDocument.begin();
		 it != arrayDocument.end();
		 it++)
	{
		WizDocument* doc = [[WizDocument alloc] initFromWizDocumentData:*it];
		if (doc)
		{
			[arr addObject:doc];
			[doc release];
		}
	}
	//
	return arr;
}



- (NSArray*) documentsByLocation: (NSString*)parentLocation
{
	CIndex& index = [_indexData index];
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByLocation([parentLocation UTF8String], arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}

-(NSArray*) attachmentsFormWizDocumentAttachmentArray:(const CWizDocumentAttachmentArray&) array
{
    NSMutableArray* arr = [NSMutableArray array];
    for(CWizDocumentAttachmentArray::const_iterator it = array.begin();
        it != array.end();
        it++)
    {
        WizDocumentAttach* attach = [[WizDocumentAttach alloc] initFromAttachmentGuidData:*it];
        if(attach)
        {
            [arr addObject:attach];
            [attach release];
        }
        
    }
    return arr;
}

-(WizDocumentAttach*) attachmentFromGUID:(NSString *)attachmentGUID
{
    CIndex& index = [_indexData index];
    WIZDOCUMENTATTACH attach;
    index.AttachFromGUID([attachmentGUID UTF8String], attach);
    return [[[WizDocumentAttach alloc] initFromAttachmentGuidData:attach]autorelease];
}

-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID
{
    CIndex& index = [_indexData index];
	//
	CWizDocumentAttachmentArray arrayAttachment;
	index.AttachmentsFromDocumentGUID([documentGUID UTF8String], arrayAttachment);
	//
	return [self attachmentsFormWizDocumentAttachmentArray: arrayAttachment];
}

-(WizTag*) tagFromGuid:(NSString *)guid
{
    CIndex& index = [_indexData index];
    WIZTAGDATA tagData;
    index.TagFromGUID([guid UTF8String], tagData);
    WizTag* tag = [[[WizTag alloc] initFromWizTagData:tagData] autorelease];
    return tag;
}


- (NSArray*) deletedGUIDsFromWizDeletedGUIDDataArray: (const CWizDeletedGUIDDataArray&) arrayDeletedGUID
{
	NSMutableArray* arr = [NSMutableArray array];
	//
	for (CWizDeletedGUIDDataArray::const_iterator it = arrayDeletedGUID.begin();
		 it != arrayDeletedGUID.end();
		 it++)
	{
		WizDeletedGUID* doc = [[WizDeletedGUID alloc] initFromWizDeletedGUIDData:*it];
		if (doc)
		{
			[arr addObject:doc];
			[doc release];
		}
	}
	//
	return arr;
}


- (NSArray*) allDeletedGUIDs
{
	CIndex& index = [_indexData index];
	//
	CWizDeletedGUIDDataArray arrayGUID;
	index.GetAllDeletedGUIDs(arrayGUID);
	//
	return [self deletedGUIDsFromWizDeletedGUIDDataArray: arrayGUID];
}
- (NSArray*) deletedGUIDsForUpload
{
	NSMutableArray* ret = [NSMutableArray array];
	//
	NSArray* src = [self allDeletedGUIDs];
	for (WizDeletedGUID* guid in src)
	{
		NSDate* date = [WizGlobals sqlTimeStringToDate:guid.dateDeleted];
		//
		NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:guid.guid, @"deleted_guid", guid.type, @"guid_type", date, @"dt_deleted", nil];
		[ret addObject:dict];
		[dict release];
	}
	//
	return ret;
}

- (BOOL) hasDeletedGUIDs
{
	CIndex& index = [_indexData index];
	//
	return index.HasDeletedGUIDs() ? YES : NO;
}

- (BOOL) clearDeletedGUIDs
{
	CIndex& index = [_indexData index];
	//
	return index.ClearDeletedGUIDs() ? YES : NO;
}


- (NSArray*) documentsByTag: (NSString*)tagGUID
{
	CIndex& index = [_indexData index];
	//
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByTag([tagGUID UTF8String], arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (NSArray*) documentsByKey: (NSString*)keywords
{
	CIndex& index = [_indexData index];
	//
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByKey([keywords UTF8String], arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (NSArray*) recentDocuments
{
	CIndex& index = [_indexData index];
	//
	CWizDocumentDataArray arrayDocument;
	index.GetRecentDocuments(arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (NSArray*) documentForUpload
{
	CIndex& index = [_indexData index];
	//
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsForUpdate(arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];	
}
- (NSArray*) documentForDownload
{
    CIndex& index = [_indexData index];
	//
	CWizDocumentDataArray arrayDocument;
	index.documentsWillDowload([self durationForDownloadDocument], arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];	
}

- (NSArray*) attachmentsForUpload
{
    CIndex& index = [_indexData index];
    CWizDocumentAttachmentArray attachArray;
    index.GetAttachmentForUpload(attachArray);
    return [self attachmentsFormWizDocumentAttachmentArray:attachArray];
}
- (NSArray*) tagsByDocumentGuid:(NSString *)documentGUID
{
    WizDocument* doc = [self documentFromGUID:documentGUID];
    NSString* tagGuids = doc.tagGuids;
    NSArray* tagGuidArray = [tagGuids componentsSeparatedByString:@"*"];
    NSMutableArray* ret = [NSMutableArray array];
    for(NSString* eachGuid in tagGuidArray)
    {
        if (eachGuid == nil || [eachGuid isEqualToString:@""]) {
            continue;
        }
        WizTag* tag = [self tagFromGuid:eachGuid];
        [ret addObject:tag];
    }    
    return  ret;
}
- (WizDocument*) documentFromGUID:(NSString*)documentGUID
{
	CIndex& index = [_indexData index];
	//
	WIZDOCUMENTDATA data;
	if (!index.DocumentFromGUID([documentGUID UTF8String], data))
		return nil;
	//
	WizDocument* doc = [[WizDocument alloc] initFromWizDocumentData:data];
	return [doc autorelease];
}

- (BOOL) addFolder: (NSString*)parentLocation newFolderName: (NSString*)folderName
{
	NSString* newName = [folderName toValidPathComponent];
	//
	CIndex& index = [_indexData index];
	//
	return index.AddLocation([parentLocation UTF8String], [newName UTF8String]) ? YES : NO;
}

- (NSArray*) allLocationsForTree
{
	CIndex& index = [_indexData index];
	//
	CWizStdStringArray arrayLocation;
	index.GetAllLocations(arrayLocation);
	//
	NSArray* allLocations = nil;
	//
	[WizIndex stdStringArrayToNSArray: arrayLocation retArray:&allLocations];
	//
	NSMutableDictionary* dict = [[NSMutableDictionary alloc ] init];
	//
	for (NSString* location in allLocations)
	{
		NSString* subLocation = location;
		while ([subLocation length] > 2)
		{
			[dict setObject:subLocation forKey:[subLocation lowercaseString]];
			//
			subLocation = [subLocation stringByDeletingLastPathComponent];
			//
			if ([subLocation isEqualToString:@"/"])
			{
				break;
			}
			//
			subLocation = [subLocation stringByAppendingString:@"/"];
		}
	}
	//
	[allLocations release];
	//
	NSMutableArray* locations = [NSMutableArray arrayWithArray:[dict allValues]];
	//
	[locations sortUsingFunction:compareString context:NULL];
	//
    [dict release];
	return locations;
}

- (NSArray*) allTagsForTree
{
	CIndex& index = [_indexData index];
	//
	CWizTagDataArray arrayTag;
	index.GetAllTagsPathForTree(arrayTag);
	//
	NSMutableArray* tags = [NSMutableArray arrayWithCapacity:arrayTag.size()];
	//
	for (CWizTagDataArray::const_iterator it = arrayTag.begin();
		 it != arrayTag.end();
		 it++)
	{
		WizTag* tag = [[WizTag alloc] initFromWizTagData:*it];
		[tags addObject:tag];
		[tag release];
	}
	//
	[tags sortUsingFunction:compareTag context:NULL];
	//
	return tags;
}

- (BOOL) addLocation: (NSString*) location
{
	CIndex& index = [_indexData index];
	//
	return index.AddLocation([location UTF8String]);
}

- (BOOL) updateLocations:(NSArray*) locations
{
	for (NSString* location in locations)
	{
		try {
			[self addLocation:location];
			
		}
		catch (...) {
			
		}
	}
	//
	return YES;
}


-(NSArray*) tagsWillPostList
{
    CIndex& index = [_indexData index];
    CWizTagDataArray arrayTag;
    index.GetTagPostList(arrayTag);
    
    NSMutableArray* tags = [NSMutableArray arrayWithCapacity:arrayTag.size()];
	//
	for (CWizTagDataArray::const_iterator it = arrayTag.begin();
		 it != arrayTag.end();
		 it++)
	{
		WizTag* tag = [[WizTag alloc] initFromWizTagData:*it];
		[tags addObject:tag];
		[tag release];
	}
    return [[tags copy] autorelease];
}

- (BOOL) updateTag: (NSDictionary*) tag
{
	NSString* name = [tag valueForKey:@"tag_name"];
	NSString* guid = [tag valueForKey:@"tag_guid"];
	NSString* parentGuid = [tag valueForKey:@"tag_group_guid"];
	NSString* description = [tag valueForKey:@"tag_description"];
    NSNumber* version = [tag valueForKey:@"version"];
    NSDate* dtInfoModifed = [tag valueForKey:@"dt_info_modified"];
	//
	WIZTAGDATA data;
	data.strName = [name UTF8String];
	data.strGUID = [guid UTF8String];
    if(parentGuid !=nil)
        data.strParentGUID = [parentGuid UTF8String];
	data.strDescription= [description UTF8String];
    data.strDtInfoModified = [[WizGlobals dateToSqlString:dtInfoModifed] UTF8String];
    data.localchanged = [version intValue];
	//
	CIndex& index = [_indexData index];
	//
	return index.UpdateTag(data) ? YES : NO;
	
}
- (BOOL) updateTags: (NSArray*) tags
{
	for (NSDictionary* tag in tags)
	{
		try 
		{
			[self updateTag:tag];
		}
		catch (...) 
		{
		}
	}
	//
	return YES;
}
//modify
//-(BOOL) updateDocumentAttach: (NSDictionary*) doc {
//    NSString* documentGuid = [doc valueForKey:@"document_guid"];
//    NSString* attachGuid = [doc valueForKey:@"attachment_guid"];
//    NSString* location = [doc valueForKey:@"documentattach_location"];
//    NSString* dataMD5 = [doc valueForKey:@"dataMD5"];
//    NSString* type = [doc valueForKey:@"attach_type"];
//    NSDate* dataCreated = [doc valueForKey:@"dt_created"];
//    
//    WIZDOCUMENTATTACH data;
//    data.strDocumentGuid = [documentGuid UTF8String];
//    data.strAttachGuid = [attachGuid UTF8String];
//    data.strDataCreated= [[WizGlobals dateToSqlString:dataCreated ] UTF8String];
//    data.strAttachType = [type UTF8String];
//    data.strDataMd5 = [dataMD5 UTF8String];
//    data.strLocation = [location UTF8String];
//    
//    CIndex& index = [_indexData index];
//	//
//	return index.UpdateDocument(data) ? YES : NO;
//}


-(BOOL) updateAttachementList:(NSArray*) list
{
    for(NSDictionary* each in list) 
    {
        [self updateAttachement:each];
    }
    return YES;
}


-(BOOL) updateAttachement:(NSDictionary*) attachment
{
    NSString* attachmentDescription = [attachment valueForKey:@"attachment_description"];
    NSString* attachmentDocumentGuid = [attachment valueForKey:@"attachment_document_guid"];
    NSString* attachmentGuid = [attachment valueForKey:@"attachment_guid"];
    NSString* attachmentName = [attachment valueForKey:@"attachment_name"];
    NSString* attachmentDataMd5 = [attachment valueForKey:@"data_md5"];
    NSDate* dtDataModified = [attachment valueForKey:@"dt_data_modified"];
    WIZDOCUMENTATTACH data;
    data.serverChanged = [[attachment valueForKey:@"sever_changed"] intValue];
    
    data.strDocumentGuid = [attachmentDocumentGuid UTF8String];
    data.strAttachmentGuid = [attachmentGuid UTF8String];
    data.strAttachmentName = [attachmentName UTF8String];
    data.strDataMd5 = [attachmentDataMd5 UTF8String];
    data.strDataModified = [[WizGlobals dateToSqlString:dtDataModified] UTF8String];
    if(attachmentDescription != nil)
        data.strDescription = [attachmentDescription UTF8String];
    CIndex& index = [_indexData index];
	return index.updateAttachment(data) ? YES : NO;
}


- (BOOL) updateDocument: (NSDictionary*) doc
{
	NSString* guid = [doc valueForKey:@"document_guid"];
	NSString* title =[doc valueForKey:@"document_title"];
	NSString* location = [doc valueForKey:@"document_location"];
	NSString* dataMd5 = [doc valueForKey:@"data_md5"];
	NSString* url = [doc valueForKey:@"document_url"]; 
	NSString* tagGUIDs = [doc valueForKey:@"document_tag_guids"];
    //wiz-dzpqzb
    
	NSDate* dateCreated = [doc valueForKey:@"dt_created"]; 
	NSDate* dateModified = [doc valueForKey:@"dt_modified"]; 
	NSString* type = [doc valueForKey:@"document_type"];
	NSString* fileType = [doc valueForKey:@"document_filetype"];
    NSNumber* nAttachmentCount = [doc valueForKey:@"document_attachment_count"];
	//
	//wiz-dzpqzb
	WIZDOCUMENTDATA data;
	data.strGUID = [guid UTF8String];
	data.strTitle = [title UTF8String];
	data.strLocation = [location UTF8String];
    if(dataMd5 != nil)
        data.strDataMd5 = [dataMd5 UTF8String];
	data.strURL = [url UTF8String];
	data.strTagGUIDs = [tagGUIDs UTF8String];
	data.strDateCreated = [[WizGlobals dateToSqlString:dateCreated] UTF8String];
	data.strDateModified = [[WizGlobals dateToSqlString:dateModified] UTF8String];
	data.strType = [type UTF8String];
	data.strFileType = [fileType UTF8String];
    data.nAttachmentCount = [nAttachmentCount intValue];
	CIndex& index = [_indexData index];
	//
	return index.UpdateDocument(data) ? YES : NO;
}


- (BOOL) updateDocuments: (NSArray*) documents
{
	for (NSDictionary* doc in documents)
	{
		try
		{
			[self updateDocument:doc];
		}
		catch (...)
		{
		}
	}
	//
	return YES;
	
}

-(BOOL) updateDocumentAttachData:(NSData*)data documentGuid:(NSString*)documentGuid documentAttachGuid:(NSString*)documentAttachGuid {
    NSString* documentPath = [WizIndex documentFileName:self.accountUserId documentGUID:documentGuid];
    [WizGlobals ensurePathExists:documentPath];
    NSString* zipFileName=[documentPath stringByAppendingFormat:@"tem.zip"];
    [data writeToFile:zipFileName atomically:NO];
    ZipArchive* zip = [[ZipArchive alloc]init];
    [zip UnzipOpenFile:zipFileName];
    [zip UnzipFileTo:documentPath overWrite:YES];
    [zip UnzipCloseFile];
    

    //important change
    [zip release];
    return YES;
}

- (BOOL) updateDocumentData:(NSData*)data documentGUID:(NSString*)documentGUID
{
	NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
	//
	[WizGlobals ensurePathExists:documentPath];
	//
	NSString* zipFileName = [documentPath stringByAppendingPathComponent:@"tmp.zip"];
	[data writeToFile:zipFileName atomically:NO];
	//
	
	ZipArchive* zip = [[ZipArchive alloc] init];
	[zip UnzipOpenFile:zipFileName];
	[zip UnzipFileTo:documentPath overWrite:YES];
	[zip UnzipCloseFile];
    //important change
    [zip release];
	//
	//
	[WizGlobals deleteFile:zipFileName];
	//
	[self setDocumentServerChanged:documentGUID changed:NO];
	//
	return YES;
}

-(NSNumber*) appendObjectDataByPath:(NSString*) objectFilePath data:(NSData*)data {
    
    NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath:objectFilePath];
    if(nil == file) {
        [[NSFileManager defaultManager] createFileAtPath:objectFilePath contents:nil attributes:nil];
        file = [NSFileHandle fileHandleForWritingAtPath:objectFilePath];
    }
    [file seekToEndOfFile];
    [file writeData:data];
    NSNumber* fileSize = [NSNumber numberWithLongLong:[file seekToEndOfFile]];
    [file closeFile];
    // 貌似释放后在其他地方回用到，先不释放
    //[file release];
    return  fileSize;
}

-(BOOL) updateObjectDataByPath:(NSString*) objectZipFilePath objectGuid:(NSString*)objectGuid{
    NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:objectGuid];
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:objectZipFilePath];
    [zip UnzipFileTo:documentPath overWrite:YES];
    [zip UnzipCloseFile];
  
    [zip release];
    [self setDocumentServerChanged:objectGuid changed:NO];


    [WizGlobals deleteFile:objectZipFilePath];
    return YES;
}

- (BOOL) editDocument:(NSString*)documentGUID documentText:(NSString*)text documentTitle:(NSString*)title
{
	NSString* guid = documentGUID;
	//
	NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:guid];
	[WizGlobals ensurePathExists:documentPath];
	
	NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:guid fileExt:@".txt"];
	
	NSError* errOrg = nil;
	[text writeToFile:documentOrgFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errOrg];
	if (errOrg != nil)
	{
		[WizGlobals reportError:errOrg];
		return NO;
	}
	//
	NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:guid];
	
	if (title == nil || [title length] == 0)
	{
		title = [text firstLine];
	}
	//
	NSString* html = [[NSString alloc] initWithFormat:@"<html><title>%@</title></head><body>%@</body></html>", title, [text toHtml]];
	//
	NSError* errHtml = nil;
	[html writeToFile:documentFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errHtml];
	//
	[html release];
	//
	if (errHtml != nil)
	{
		[WizGlobals reportError:errHtml];
		return NO;
	}
	//
	CIndex& index = [_indexData index];
	//
	BOOL bRet = index.ChangeDocumentType([documentGUID UTF8String], [title UTF8String], "note", ".txt") ? YES : NO;
	//
	return bRet;
	
}


- (void) onNewDocument:(NSString*)guid
{
	NSDictionary* userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:accountUserId, @"accountUserId", guid, @"guid", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"onNewDocument" object: nil userInfo: userInfo];
    [userInfo release];
}

- (BOOL) editDocumentWithGuidAndData:(NSDictionary*)documentData
{
    return [self newNoteWithGuidAndData:documentData];
}
- (BOOL) newNoteWithGuidAndData:(NSDictionary*)documentData
{
    NSString* documentTitle = [documentData valueForKey:TypeOfDocumentTitle];
    NSString* documentBody = [documentData valueForKey:TypeOfDocumentBody];
    NSString* documentLocation = [documentData valueForKey:TypeOfDocumentLocation];
    NSArray* attachmentsGUIDs = [documentData valueForKey:TypeOfAttachmentGuids];
    NSString* documentGUID = [documentData valueForKey:TypeOfDocumentGUID];
    NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
    NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:documentGUID fileExt:@".txt"];
    NSString* attachmentsDirectory = [documentPath stringByAppendingPathComponent:@"index_files"];
    NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:documentGUID];
    
    [WizGlobals ensurePathExists:attachmentsDirectory];
    
    NSMutableArray* audioNames = [NSMutableArray array];
    NSMutableArray* pictureNames = [NSMutableArray array];
    for (NSString* eachGuid in attachmentsGUIDs) {
        WizDocumentAttach* attach = [self attachmentFromGUID:eachGuid];
        NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attach.attachmentGuid];
        NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attach.attachmentName];
        attachmentFilePath = [attachmentFilePath stringByReplacingOccurrencesOfString:@":" withString:@"-"];
        if ([WizGlobals checkAttachmentTypeIsImage:attach.attachmentType])
        {
            [pictureNames addObject:attach.attachmentName];
        }
        if ([WizGlobals checkAttachmentTypeIsAudio:attach.attachmentType]) {
            [audioNames addObject:attach.attachmentName];
        }
        NSError* error = [[NSError alloc]init];
        NSString* targetFilePath = [attachmentsDirectory stringByAppendingPathComponent:attach.attachmentName];
        if(![[NSFileManager defaultManager] copyItemAtPath:attachmentFilePath toPath:targetFilePath error:&error])
        {
            NSLog(@"move error");
        }
    }
	NSError* errOrg = nil;
	[documentBody writeToFile:documentOrgFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errOrg];
	if (errOrg != nil)
	{
		[WizGlobals reportError:errOrg];
		return NO;
	}
    if (documentBody == nil || [documentBody length] ==0) {
        documentBody = @"";
    }
    if (documentTitle == nil || [documentTitle length] == 0)
	{
		documentTitle = [documentBody firstLine];
	}
	if (documentTitle == nil || [documentTitle length] == 0)
	{
		documentTitle = [NSString stringWithString:@"No title"];
	}
    
    NSString* htmlTitle = [NSString stringWithFormat:@"<title>%@</title>",documentTitle];
    NSString* htmlBodyText = [NSString stringWithFormat:@"<p>%@</p>",[documentBody toHtml]];
    NSMutableString* htmlPictrue = [NSMutableString stringWithFormat:@"<ul>"];

    for (NSString* each in pictureNames) {
        [htmlPictrue appendFormat:@"<li><img src=\"index_files/%@\" alt=\"%@\" ></li>",each,each];
    }
    [htmlPictrue appendFormat:@"</ul>"];
    
    NSMutableString* htmlAudio = [NSMutableString stringWithFormat:@"<ul>"];
    for (NSString* each in audioNames) {
        [htmlAudio appendFormat:@"<li><embed src=\"index_files/%@\" autostart=false></li>",each];
    }
    [htmlAudio appendFormat:@"</ul>"];
    NSString* htmlFinal = [NSString stringWithFormat:@"<html>%@<body>%@%@%@</body></html>",htmlTitle,htmlBodyText,htmlAudio,htmlPictrue];
    NSError* errHtml = nil;
	[htmlFinal writeToFile:documentFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errHtml];
    if (errHtml != nil)
	{
		[WizGlobals reportError:errHtml];
		return NO;
	}
	//
	CIndex& index = [_indexData index];
	//
	if (documentLocation == nil)
	{
		documentLocation = @"";
	}
	//
	BOOL bRet = index.NewNote([documentGUID UTF8String], [documentTitle UTF8String], [documentLocation UTF8String]) ? YES : NO;
	//
	[self onNewDocument:documentGUID];
    [self setDocumentLocalChanged:documentGUID changed:YES];
	//
	return bRet;
}

- (BOOL) newNoteWithGUID:(NSString *)title text:(NSString *)text location:(NSString *)location GUID:(NSString *)guid
{
    if (text == nil)
		return NO;
	//
	
	NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:guid];
	[WizGlobals ensurePathExists:documentPath];
	
	NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:guid fileExt:@".txt"];
	
	NSError* errOrg = nil;
	[text writeToFile:documentOrgFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errOrg];
	if (errOrg != nil)
	{
		[WizGlobals reportError:errOrg];
		return NO;
	}
	//
	NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:guid];
	
	if (title == nil || [title length] == 0)
	{
		title = [text firstLine];
	}
	if (title == nil || [title length] == 0)
	{
		title = [NSString stringWithString:@"No title"];
	}
	NSString* html = [[NSString alloc] initWithFormat:@"<html><title>%@</title></head><body>%@</body></html>", title, [text toHtml]];
	//
	NSError* errHtml = nil;
	[html writeToFile:documentFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errHtml];
	//
	[html release];
	//
	if (errHtml != nil)
	{
		[WizGlobals reportError:errHtml];
		return NO;
	}
	//
	CIndex& index = [_indexData index];
	//
	if (location == nil)
	{
		location = @"";
	}
	//
	BOOL bRet = index.NewNote([guid UTF8String], [title UTF8String], [location UTF8String]) ? YES : NO;
	//
	[self onNewDocument:guid];
	//
	return bRet;
}
- (BOOL) newNote:(NSString*)title text:(NSString*)text location:(NSString*)location
{
	if (text == nil)
		return NO;
	//
	NSString* guid = [WizGlobals genGUID];
	
	NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:guid];
	[WizGlobals ensurePathExists:documentPath];
	
	NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:guid fileExt:@".txt"];
	
	NSError* errOrg = nil;
	[text writeToFile:documentOrgFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errOrg];
	if (errOrg != nil)
	{
		[WizGlobals reportError:errOrg];
		return NO;
	}
	//
	NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:guid];
	
	if (title == nil || [title length] == 0)
	{
		title = [text firstLine];
	}
	if (title == nil || [title length] == 0)
	{
		title = [NSString stringWithString:@"No title"];
	}
	NSString* html = [[NSString alloc] initWithFormat:@"<html><title>%@</title></head><body>%@</body></html>", title, [text toHtml]];
	//
	NSError* errHtml = nil;
	[html writeToFile:documentFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errHtml];
	//
	[html release];
	//
	if (errHtml != nil)
	{
		[WizGlobals reportError:errHtml];
		return NO;
	}
	//
	CIndex& index = [_indexData index];
	//
	if (location == nil)
	{
		location = @"";
	}
	//
	BOOL bRet = index.NewNote([guid UTF8String], [title UTF8String], [location UTF8String]) ? YES : NO;
	//
	[self onNewDocument:guid];
	//
	return bRet;
}
-(WizTag*) newTag:(NSString*) name  description:(NSString *)description parentTagGuid:(NSString*)parentTagGuid {
    NSString* guid = [WizGlobals genGUID];
    NSMutableDictionary* tag = [NSMutableDictionary dictionary];
    [tag setObject:guid forKey:@"tag_guid"];
    [tag setObject:name forKey:@"tag_name"];
    [tag setObject:description forKey:@"tag_description"];
    if(nil != parentTagGuid)   [tag setObject:parentTagGuid forKey:@"tag_group_guid"];
    [tag setObject:[NSNumber numberWithInt:-1] forKey:@"version"];
    [tag setObject:[NSDate date] forKey:@"dt_info_modified"];
    
    WizTag* newTagCopy = [[WizTag alloc] init];
    newTagCopy.name = name;
    newTagCopy.guid = guid;
    newTagCopy.description = description;
    newTagCopy.parentGUID = parentTagGuid;
    newTagCopy.localChanged = -1;
    newTagCopy.dtInfoModified = [NSDate date];
    newTagCopy.namePath = [NSString stringWithFormat:@"/%@",name];
    [self updateTag:tag];
    return newTagCopy;
}

- (BOOL) newPhoto:(UIImage*)image title:(NSString*)title text:(NSString*)text location:(NSString*)location
{
	NSString* guid = [WizGlobals genGUID];
	
	NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:guid];
	[WizGlobals ensurePathExists:documentPath];
	
	NSString* documentOrgFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:guid fileExt:@".jpg"];
	
	// Write image to jpg
	if (![UIImageJPEGRepresentation(image, 0.9) writeToFile:documentOrgFileName atomically:YES])
	{
		[WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to save image", nil)];
		return NO;
	}
	//
	NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:guid];
	
	if (title == nil || [title length] == 0)
	{
		if (text != nil && [text length] > 0)
		{
			title = [text firstLine];
		}
		if (title == nil || [title length] == 0)
		{
			title = [[[NSString alloc] initWithFormat:@"Photo (%@)", [WizGlobals dateToLocalString:[NSDate date]]] autorelease];
		}
	}
	//
	NSString* html = nil;
	//
	if (text == nil || [text length] == 0)
	{
		html = [[NSString alloc] initWithFormat:@"<html><title>%@</title></head><body><img src=\"%@\" border=\"0\"></img></body></html>", title, [documentOrgFileName lastPathComponent]];
	}
	else 
	{
		NSString* documentMemoFileName = [WizIndex documentOrgFileName:self.accountUserId documentGUID:guid fileExt:@".txt"];
		NSError* errText = nil;
		[text writeToFile:documentMemoFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errText];
		
		html = [[NSString alloc] initWithFormat:@"<html><title>%@</title></head><body><p>%@</p><img src=\"%@\" border=\"0\"></img></body></html>", title, [text toHtml], [documentOrgFileName lastPathComponent]];
	}
    
	//
	NSError* errHtml = nil;
	[html writeToFile:documentFileName atomically:NO encoding:NSUnicodeStringEncoding error:&errHtml];
	[html release];
	if (errHtml != nil)
	{
		[WizGlobals reportError:errHtml];
		return NO;
	}
	//
	CIndex& index = [_indexData index];
	//
	if (location == nil)
	{
		location = @"";
	}
	//
	BOOL bRet = index.NewPhoto([guid UTF8String], [title UTF8String], [location UTF8String]) ? YES : NO;
	//
	if (bRet)
	{
		[self onNewDocument:guid];
	}
	//
	return bRet;
}

- (BOOL) updateDocumentTags:(NSString *)documentGuid tagGuids:(NSString *)tagGuids
{
    CIndex& index = [_indexData index];
    return  index.AddTagsToDocumentByGuid([documentGuid UTF8String], [tagGuids UTF8String]);
}

- (NSString*) nextDocumentForDownload
{
	CIndex& index = [_indexData index];
	//
	std::string guid = index.GetNextDocumentForDownload();
	//
	if (guid.empty())
		return nil;
	//
	return [NSString stringWithUTF8String:guid.c_str()];
}

- (BOOL) documentServerChanged:(NSString*)documentGUID
{
	CIndex& index = [_indexData index];
	//
	WIZDOCUMENTDATA data;
	index.DocumentFromGUID([documentGUID UTF8String], data);
	return data.nServerChanged ? YES : NO;
}

- (BOOL) documentLocalChanged:(NSString *)documentGUID
{
    CIndex& index = [_indexData index];
	//
	WIZDOCUMENTDATA data;
	index.DocumentFromGUID([documentGUID UTF8String], data);
	return data.nLocalChanged ? YES : NO;
}

- (BOOL) attachmentSeverChanged:(NSString*)attachmentGUID
{
    CIndex& index = [_indexData index];
	//
	WIZDOCUMENTATTACH data;
	index.AttachFromGUID([attachmentGUID UTF8String], data);
	return data.serverChanged ? YES : NO;
}
- (BOOL) setDocumentLocalChanged:(NSString*)documentGUID changed:(BOOL)changed
{
	CIndex& index = [_indexData index];
	//
    if (changed) {
        [self deleteAbstractByGUID:documentGUID];
        [self extractSummary:documentGUID];
    }
    else
    {
        [self extractSummary:documentGUID];
    }
	return index.SetDocumentLocalChanged([documentGUID UTF8String], changed ? true : false) ? YES : NO;
}
- (BOOL) setDocumentServerChanged:(NSString*)documentGUID changed:(BOOL)changed
{
	CIndex& index = [_indexData index];
	//
    if (changed) {
        [self deleteAbstractByGUID:documentGUID];
    }
    else
    {
        [self extractSummary:documentGUID];
    }
	return index.SetDocumentServerChanged([documentGUID UTF8String], changed ? true : false) ? YES : NO;
}

- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    CIndex& index = [_indexData index];
    return index.SetAttachmentLocalChanged([attchmentGUID UTF8String], changed? true : false) ? YES: NO;
}


- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    CIndex& index = [_indexData index];
    return index.SetAttachmentServerChanged([attchmentGUID UTF8String], changed? true : false) ? YES: NO;
}

- (BOOL) setDocumentMD5:(NSString *)documentGUID md5:(NSString *)md5
{
    CIndex& index = [_indexData index];
    return index.SetDocumentMD5([documentGUID UTF8String], [md5 UTF8String])? YES:NO;
}

- (BOOL) setDocumentLocation:(NSString *)documentGUID location:(NSString *)location
{
    CIndex& index = [_indexData index];
    return index.SetDocumentLocation([documentGUID UTF8String], [location UTF8String])?YES:NO;
}
- (BOOL) setDocumentModifiedDate:(NSString *)documentGUID modifiedDate:(NSDate *)modifiedDate
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [formatter stringFromDate:modifiedDate];
    [formatter release];
    CIndex& index = [_indexData index];
    return index.SetDocumentModifiedDate([documentGUID UTF8String], [dateString UTF8String])? YES:NO;
}


- (BOOL) setDocumentTags:(NSString *)documentGUID tags:(NSString *)tagsString
{
    CIndex& index = [_indexData index];
    return index.SetDocumentTags([documentGUID UTF8String], [tagsString UTF8String])? YES : NO;
}

- (BOOL) setDocumentAttachCount:(NSString *)documentGUID count:(int)count
{
    CIndex& index = [_indexData index];
    return index.SetDocumentAttachmentCount([documentGUID UTF8String], [[NSString stringWithFormat:@"%d",count] UTF8String])? YES : NO;
}

- (BOOL) deleteDocument:(NSString*)documentGUID
{
    NSArray* attachments = [self attachmentsByDocumentGUID:documentGUID];
    for(WizDocumentAttach* each in attachments)
    {
        [self deleteAttachment:each.attachmentGuid];
        [self addDeletedGUIDRecord:each.attachmentGuid type:@"attachment"];
    }
    
    
	CIndex& index = [_indexData index];
	//
	return index.DeleteDocument([documentGUID UTF8String]) ? YES : NO;
}

- (int) fileCountOfLocation:(NSString *)location
{
    int count;
    CIndex& index = [_indexData index];
    index.fileCountInLocation([location UTF8String], count);
    return count;
}

- (int) fileCountOfTag:(NSString *)tagGUID
{
    return [[self documentsByTag:tagGUID] count];
}
- (BOOL) deleteTag:(NSString*)tagGUID
{
	CIndex& index = [_indexData index];
	//
	return index.DeleteTag([tagGUID UTF8String]) ? YES : NO;
}
-(BOOL) deleteAttachment:(NSString *)attachGuid
{
    CIndex& index = [_indexData index];
    return index.DeleteAttachment([attachGuid UTF8String]) ? YES : NO;
}
- (void) initAccountSetting
{
    if (![WizGlobals WizDeviceIsPad] ) {
        if ([self imageQualityValue] == 0) {
            [self setDownloadAllList:YES];
            [self setImageQualityValue:750];
        }
        if (0 == [self webFontSize]) {
            [self setWebFontSize:270];
        }
        if (0 == [self durationForDownloadDocument]) {
            [self setDurationForDownloadDocument:1];
        }
        if (0 == [self isMoblieView]) {
            [self setDocumentMoblleView:YES];
        }
    }
    else
    {
        [self setDocumentMoblleView:NO];
        [self setDownloadDocumentData:NO];
        [self setDurationForDownloadDocument:0];
        [self setImageQualityValue:750];
    }

    [self setDownloadAllList:YES];
}
- (NSString*) meta: (NSString*)name key:(NSString*)key
{
	CIndex& index = [_indexData index];
	//
	std::string value = index.GetMeta([name UTF8String], [key UTF8String]);
	//
	return [NSString stringWithUTF8String:value.c_str()];
}
- (BOOL) setMeta: (NSString*)name key:(NSString*)key value:(NSString*)value
{
	CIndex& index = [_indexData index];
	//
	bool ret = index.SetMeta([name UTF8String], [key UTF8String], [value UTF8String]);
	return ret ? YES : NO;
}


- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type
{
	CIndex& index = [_indexData index];
	//
	return index.LogDeletedGUID([guid UTF8String], [type UTF8String]) ? YES : NO;
}

- (BOOL) removeDeletedGUIDRecord: (NSString*)guid
{
	CIndex& index = [_indexData index];
	//
	return index.RemoveDeletedGUID([guid UTF8String]) ? YES : NO;
}

- (BOOL) boolMetaDef: (NSString*)name key:(NSString*)key def:(BOOL)def
{
	NSString* str = [self meta:name key:key];
	if (str == nil)
		return def;
	if ([str length] == 0)
		return def;
	if ([str isEqualToString:@"1"])
		return YES;
	//
	return NO;
}
- (BOOL) downloadAllList
{
	return [self boolMetaDef:@"SYNC" key:@"DownloadAllList" def:NO];
}
- (BOOL) downloadDocumentData
{
	return [self boolMetaDef:@"SYNC" key:@"DownloadDocumentData" def:NO];	
}
-(BOOL) protect
{
	return [self boolMetaDef:@"COMMON" key:@"Protect" def:NO];	
}
- (void) setDownloadAllList: (BOOL) b
{
	[self setMeta:@"SYNC" key:@"DownloadAllList" value:b ? @"1" : @"0"];
}
- (void) setDownloadDocumentData: (BOOL) b
{
	[self setMeta:@"SYNC" key:@"DownloadDocumentData" value:b ? @"1" : @"0"];
}
- (void) setProtect: (BOOL) b
{
	[self setMeta:@"COMMON" key:@"Protect" value:b ? @"1" : @"0"];
}

static NSString* KeyOfSyncVersion               = @"SYNC_VERSION";
static NSString* DocumentNameOfSyncVersion      = @"DOCUMENT";
static NSString* DeletedGUIDNameOfSyncVersion   = @"DELETED_GUID";
static NSString* TagVersion                     = @"TAGVERSION";
static NSString* UserTrafficLimit               = @"TRAFFICLIMIT";
static NSString* UserTrafficUsage               = @"TRAFFUCUSAGE";
static NSString* KeyOfUserInfo                  = @"USERINFO";
static NSString* UserLevel                      = @"USERLEVEL";
static NSString* UserLevelName                  = @"USERLEVELNAME";
static NSString* UserType                       = @"USERTYPE";
static NSString* UserPoints                     = @"USERPOINTS";
static NSString* AttachmentVersion              = @"ATTACHMENTVERSION";
static NSString* MoblieView                     = @"MOBLIEVIEW";
static NSString* DurationForDownloadDocument    = @"DURATIONFORDOWLOADDOCUMENT";
static NSString* WebFontSize                    = @"WEBFONTSIZE";
static NSString* DatabaseVesion                 = @"DATABASE";
static NSString* ImageQuality                   = @"IMAGEQUALITY";
static NSString* ProtectPssword                 = @"PROTECTPASSWORD";
static NSString* FirstLog                       = @"UserFirstLog";
- (int64_t) syncVersion:(NSString*)type
{
	NSString* str = [self meta:KeyOfSyncVersion key:type];
	if (!str)
		return 0;
	if ([str length] == 0)
		return 0;
	//
	return [str longLongValue];
}

- (NSString*) userInfo:(NSString*)type
{
    NSString* str = [self meta:KeyOfUserInfo key:type];
    return str;
}

- (BOOL) setSyncVersion:(NSString*)type version:(int64_t)ver
{
	NSString* verString = [NSString stringWithFormat:@"%lld", ver];
	
	return [self setMeta:KeyOfSyncVersion key:type value:verString];
}

-(BOOL) setUserInfo:(NSString*) type info:(NSString*)info
{
    BOOL ret = [self setMeta:KeyOfUserInfo key:type value:info];
    return  ret;
}

- (NSString*) documentVersionString
{
	return [NSString stringWithFormat:@"%lld", [self documentVersion]];
}
- (int64_t) documentVersion
{
	return [self syncVersion:DocumentNameOfSyncVersion];
}
- (BOOL) setDocumentVersion:(int64_t)ver
{
	return [self setSyncVersion:DocumentNameOfSyncVersion version:ver];
}

- (int64_t) wizDataBaseVersion
{
    return  [self syncVersion:DatabaseVesion];
}

- (BOOL) setWizDataBaseVersion:(int64_t)ver
{
    return [self setSyncVersion:DatabaseVesion version:ver];
}
- (NSString*) attachmentVersionString
{
	return [NSString stringWithFormat:@"%lld", [self attachmentVersion]];
}
- (int64_t) attachmentVersion
{
	return [self syncVersion:AttachmentVersion];
}
- (BOOL) setAttachmentVersion:(int64_t)ver
{
	return [self setSyncVersion:AttachmentVersion version:ver];
}



- (NSString*) deletedGUIDVersionString
{
	return [NSString stringWithFormat:@"%lld", [self deletedGUIDVersion]];
}
- (NSString*) tagVersionString
{
    return [NSString stringWithFormat:@"%lld", [self tagVersion]];
}

- (int64_t) deletedGUIDVersion
{
	return [self syncVersion:DeletedGUIDNameOfSyncVersion];
}
- (int64_t) tagVersion
{
    return [self syncVersion:TagVersion];
}

- (BOOL) setDeletedGUIDVersion:(int64_t)ver
{
	return [self setSyncVersion:DeletedGUIDNameOfSyncVersion version:ver];
}
- (BOOL) setTageVersion:(int64_t)ver
{
    return [self setSyncVersion:TagVersion version:ver];
}

- (BOOL) setImageQualityValue:(int64_t)value
{
    NSString* imageValue = [NSString stringWithFormat:@"%lld",value];
    return [self setUserInfo:ImageQuality info:imageValue];
}

- (int64_t) imageQualityValue
{
    NSString* str = [self userInfo:ImageQuality];
    if(!str)
        return 0;
    else
        return [str longLongValue];
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

-(int64_t) userTrafficUsage
{
    NSString* str = [self userInfo:UserTrafficUsage];
    if(!str)
        return 0;
    else
        return [str longLongValue];
}

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
- (BOOL) setUserLevelName:(NSString*)levelName
{
    return [self setUserInfo:UserLevelName info:levelName];
}

- (NSString*) userLevelName
{
    return [self userInfo:UserLevelName];
}

- (BOOL) setUserProtectPassword:(NSString*)password
{
    return [self setUserInfo:ProtectPssword    info:password];
}

- (NSString*) userProtectPassword
{
    return [self userInfo:ProtectPssword];
}

-(BOOL) setuserTrafficUsage:(int64_t)ver
{
    NSString* info = [NSString stringWithFormat:@"%lld",ver];
    return [self setUserInfo:UserTrafficUsage info:info];
}

- (BOOL) setUserType:(NSString*)userType
{
    return [self setUserInfo:UserType info:userType];
}

- (NSString*) userType
{
    return [self userInfo:UserType];
}

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



- (int64_t) durationForDownloadDocument
{
    NSString* duration = [self userInfo:DurationForDownloadDocument];
    if(!duration)
        return 0;
    else
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

- (NSString*) documentViewFilename:(NSString*)documentGUID
{
    NSString* path = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
	NSString* filename = nil;
    filename = [path stringByAppendingPathComponent:@"wiz_mobile.html"];
    if([[NSFileManager defaultManager] fileExistsAtPath:filename])
    {
        if ([self isMoblieView]) {
            return filename;
        }
    }
    filename = [path stringByAppendingPathComponent:@"index.html"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filename]) {
        return filename;
    }
	return nil;
}
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID
{
    CTempIndex& tempIndex = [_tempIndexData tempIndex];
    return  tempIndex.DeleteAbstractByGUID([documentGUID UTF8String])?YES:NO;
}

- (BOOL) abstractExist:(NSString *)documentGUID
{
    CTempIndex& index = [_tempIndexData tempIndex];
    if ([WizGlobals WizDeviceIsPad]) {
        return  index.PadAbstractExist([documentGUID UTF8String]);
    }
    else
    {
        return  index.PhoneAbstractExist([documentGUID UTF8String]);
    }
}
- (NSString*) documentAbstractFilePath:(NSString*)documentGUID
{
    NSString* accountPath = [WizIndex accountPath:self.accountUserId];
    NSString* subName = [accountPath stringByAppendingPathComponent:@"temp"];
    NSString* path = [subName stringByAppendingPathComponent:documentGUID];
    [WizGlobals ensurePathExists:path];
    return path;
}

- (NSString*) documentAbstractStringFilePath:(NSString*)documentGUID
{
    NSString* abstractFilePath = [self documentAbstractFilePath:documentGUID];
    NSString* ret = [abstractFilePath stringByAppendingPathComponent:@"index.txt"];
    return ret;
}

- (NSString*) documentAbstractImageFilePath:(NSString*) documentGUID
{
    NSString* abstractFilePath = [self documentAbstractFilePath:documentGUID];
    NSString* ret = [abstractFilePath stringByAppendingPathComponent:@"image.jpg"];
    return ret;
}

- (void) extractSummary:(NSString *)documentGUID
{
    BOOL WizDeviceIsPad = [WizGlobals WizDeviceIsPad];
    CTempIndex& tempIndex = [_tempIndexData tempIndex];
    WIZABSTRACT abstract;
    abstract.guid = [documentGUID UTF8String];
    abstract.imageDataLength = 0;
    NSString* sourceFilePath = [self documentViewFilename:documentGUID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return;
    }
    NSData* abstractImageData = nil;
    NSString* abstractText = nil;
    NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath];
    NSString* removeStyle = [sourceStr stringByReplacingOccurrencesOfRegex:@"<style[^>]*?>[\\s\\S]*?<\\/style>" withString:@""];
    NSString* removeScript = [removeStyle stringByReplacingOccurrencesOfRegex:@"<script[^>]*?>[\\s\\S]*?<\\/script>" withString:@""];
    NSString* removeHtmlSpace = [removeScript stringByReplacingOccurrencesOfRegex:@"&(.*?);" withString:@""];
    NSString* removeOhterCharacter = [removeHtmlSpace stringByReplacingOccurrencesOfRegex:@"&#(.*?);" withString:@""];
    NSString* removeBlock = [removeOhterCharacter stringByReplacingOccurrencesOfRegex:@"\\s{2,}|\\ \\;" withString:@""];
    NSString* removeCOntrol = [removeBlock stringByReplacingOccurrencesOfRegex:@"/\n" withString:@"."];
    NSString* prepareStr = [removeCOntrol stringByReplacingOccurrencesOfRegex:@"<[^>]*>" withString:@""];
    NSString* destStr = [prepareStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    if (destStr == nil || [destStr isEqualToString:@""]) {
        destStr = @"NULL";
    }
    if (WizDeviceIsPad) {
        NSRange range = NSMakeRange(0, 100);
        if (abstractText.length <= 100) {
            range = NSMakeRange(0, destStr.length);
        }
        abstractText = [destStr substringWithRange:range];
    }
    else
    {
        NSRange range = NSMakeRange(0, 200);
        if (abstractText.length <= 200) {
            range = NSMakeRange(0, destStr.length);
        }
        abstractText = [destStr substringWithRange:range];
    }
    
    NSString* sourcePath = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
    NSString* sourceImagePath = [sourcePath stringByAppendingPathComponent:@"index_files"];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
//    NSString* maxImageFilePath = nil;
    UIImage* maxImage = nil;
    float maxImageArea = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
//            unsigned long long int currentImageFileLength = [[fileAttributers objectForKey:NSFileSize] unsignedLongLongValue];
            UIImage* currentImage = [UIImage imageWithContentsOfFile:sourceImageFilePath];
            float imageArea = currentImage.size.width*currentImage.size.height;
            
            if (imageArea <= 32* 32) {
                continue;
            }
            if (imageArea == 468*60) {
                continue;
            }
            if (imageArea == 170*60) {
                continue;
            }
            if (imageArea == 234*60) {
                continue;
            }
            if (imageArea == 88*31) {
                continue;
            }
            if (imageArea == 120*60) {
                continue;
            }
            if (imageArea == 120*90) {
                continue;
            }
            if (imageArea == 120*120) {
                continue;
            }
            if (imageArea == 360*300) {
                continue;
            }
            if (imageArea == 392*72) {
                continue;
            }
            if (imageArea == 125*125) {
                continue;
            }
            if (imageArea == 770*100) {         
                continue;
            }
            if (imageArea == 80*80) {
                continue;
            }
            if (imageArea == 750*550) {
                continue;
            }
            if (imageArea == 130* 200) {
                continue;
            }
            maxImage = imageArea > maxImageArea  ? currentImage: maxImage;
            maxImageArea = imageArea > maxImageArea ? imageArea:maxImageArea;

        
            // old mathod
//            maxImageFilePath = currentImageFileLength > imageFileLength && currentImageFileLength >4096?sourceImageFilePath:maxImageFilePath;
//            imageFileLength = currentImageFileLength > imageFileLength&& currentImageFileLength >4096? currentImageFileLength:imageFileLength;
        }
    }
  
//    UIImage* image = [UIImage imageWithContentsOfFile:maxImageFilePath];
    UIImage* compassImage = nil;
    if (nil != maxImage) {
        NSLog(@" max is %f %f ",maxImage.size.height, maxImage.size.width);
        CGRect compassRect;
        float compassWidth=0;
        float compassHeight = 0;
        if (WizDeviceIsPad) {
            compassWidth = 175;
            compassHeight = 85;
        }
        else
        {
            compassWidth = 80;
            compassHeight = 80;
        }
        if (maxImage.size.width > 175) {
            compassImage = [maxImage compressedImage:compassWidth];
            NSLog(@"compassImage %f %f",compassImage.size.height, compassImage.size.width);
            
            compassRect = CGRectMake( WizAbs((compassImage.size.width -compassWidth)/2),0.0, compassImage.size.width>compassWidth?compassWidth:compassImage.size.width,compassHeight);
        }
        else {
            compassImage = [maxImage compressedImage:compassHeight];
            compassRect = CGRectMake(0.0, WizAbs((compassImage.size.height -compassHeight)/2), compassWidth, compassImage.size.height>compassHeight?compassHeight:compassImage.size.height);
        }
        NSLog(@" compass is %f %f %f %f",compassRect.origin.x, compassRect.origin.y, compassRect.size.height , compassRect.size.width);
        compassImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect(compassImage.CGImage, compassRect)];
    }
//    if (WizDeviceIsPad) {
//        compassImage = [maxImage compressedImage:280];
//    }
//    else
//    {
//        compassImage = [maxImage compressedImage:140];
//    }
    abstractImageData = [compassImage compressedData:1.0];
    abstract.setData((unsigned char *)[abstractImageData bytes], [abstractImageData length]);
    abstract.imageDataLength = [abstractImageData length];
    abstract.text = [abstractText UTF8String];
    if (WizDeviceIsPad) {
        tempIndex.UpdatePadAbstract(abstract);
    }
    else
    {
        tempIndex.UpdateIphoneAbstract(abstract);
    }
}

- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID
{
    CTempIndex& tempIndex = [_tempIndexData tempIndex];
    WIZABSTRACT abstract;
    if (![WizGlobals WizDeviceIsPad]) {
        tempIndex.PhoneAbstractFromGUID([documentGUID UTF8String], abstract);
    }
    else
    {
        tempIndex.PadAbstractFromGUID([documentGUID UTF8String], abstract);
    }
    NSString* text = [[NSString alloc] initWithUTF8String:abstract.text.c_str()];
    if (nil == text || [text isEqualToString:@""]) {
        [text release];
        return nil;
    }
    NSData* imageData = [[NSData alloc] initWithBytes:abstract.imageData length:abstract.imageDataLength];
    UIImage* image = [UIImage imageWithData:imageData];
    WizAbstract* ret = [[[WizAbstract alloc] init] autorelease];
    ret.image = image;
    ret.text = text;
    [text release];
    [imageData release];
    return ret;
}

-(NSString*) newAttachment:(NSString*) filePath documentGUID:(NSString*)documentGUID
{    
    NSString* guid = [WizGlobals genGUID];
    NSArray* fileNameTempArray = [filePath componentsSeparatedByString:@"/"];
    NSString* fileName = [fileNameTempArray lastObject];
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:guid];
    [WizGlobals ensurePathExists:objectPath];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    NSString* fileNamePath = [objectPath stringByAppendingPathComponent:fileName];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager moveItemAtPath:filePath toPath:fileNamePath error:nil])
    {
        NSLog(@"move error");
    }
    NSString* dateCreatedString = [WizGlobals dateToSqlString:[NSDate date]];
    NSString* dataMd5 = [WizGlobals fileMD5:filePath];
    NSMutableDictionary* atttachNew = [NSMutableDictionary dictionary];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"-"];
    [atttachNew setObject:fileName forKey:@"attachment_name"];
    [atttachNew setObject:guid forKey:@"attachment_guid"];
    [atttachNew setObject:documentGUID forKey:@"attachment_document_guid"];
    [atttachNew setObject:[WizGlobals sqlTimeStringToDate:dateCreatedString] forKey:@"dt_data_modified"];
    [atttachNew setObject:dataMd5 forKey:@"data_md5"];
    [self updateAttachement:atttachNew];
    [self setAttachmentServerChanged:guid changed:NO];
    [self setAttachmentLocalChanged:guid changed:YES];
    return [guid copy];
}
- (NSString*) documentAbstractFileName:(NSString*)documentGUID
{
    NSString* path = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
	NSString* filename =  [path stringByAppendingPathComponent:@"wiz_abstract.html"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filename])
    {
        filename = [path stringByAppendingPathComponent:@"index.html"];
    }
	return filename;
}
- (NSString*) abstractToDocumentGUID:(NSString *)documentGUID
{
    NSString* abstractFilePath = [self documentAbstractStringFilePath:documentGUID];
    NSString* abstractStr = [NSString stringWithContentsOfFile:abstractFilePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:abstractFilePath]) {
        return @"";
    }
    NSRange range = NSMakeRange(0, 100);
    if (abstractStr.length <= 100) {
        range = NSMakeRange(0, abstractStr.length-1);
    }
    NSString* ret = [abstractStr substringWithRange:range];
    if (nil == ret) {
        return @"";
    }
    return ret;
}
+ (NSString*) accountPath: (NSString*)userId
{
	NSString* documentPath = [WizGlobals documentsPath];
	NSString* subPathName = [NSString stringWithFormat:@"%@/", userId]; 
	//
	NSString* path = [documentPath stringByAppendingPathComponent:subPathName];
	//
	[WizGlobals ensurePathExists:path];
	//
	return path;
}

+ (NSString*) accountFileName: (NSString*)userId
{
	NSString* accountPath = [WizIndex accountPath:userId]; 
	//
	return [accountPath stringByAppendingPathComponent:@"index.db"];
}

+ (NSString*) accountTempFileName:(NSString*)userId
{
    NSString* accountPath = [WizIndex accountPath:userId];
    return [accountPath stringByAppendingPathComponent:@"temp.db"];
}

+ (NSString*) documentFilePath:(NSString*)userId documentGUID:(NSString*)documentGUID
{
	NSString* accountPath = [WizIndex accountPath:userId]; 
	NSString* subName = [[NSString alloc] initWithFormat:@"%@", documentGUID];
	//
	NSString* path = [accountPath stringByAppendingPathComponent:subName];
	//
	[subName release];
	//
	return path;
}
+ (NSString*) documentFileName:(NSString*)userId documentGUID:(NSString*)documentGUID
{
	NSString* path = [WizIndex documentFilePath:userId documentGUID:documentGUID];
	NSString* filename = [path stringByAppendingPathComponent:@"index.html"];
	//
	return filename;
}
+ (NSString*) documentOrgFileName:(NSString*)userId documentGUID:(NSString*)documentGUID fileExt:(NSString*)fileExt
{
	NSString* documentFileName = [WizIndex documentFileName:userId documentGUID:documentGUID];
	NSString* srcFileName = [NSString stringWithFormat:@"%@%@", documentFileName, fileExt];
	//
	return srcFileName;
}
+ (NSString*) pathName: (NSString*)location
{
	NSString* str = [location trimChar:'/'];
	//
	int index = [str lastIndexOfChar:'/'];
	if (-1 == index)
		return str;
	//
	return [str substringFromIndex:index + 1];
}

+ (int) pathLevel: (NSString*)location
{
	int level = 0;
	int length = [location length];
	for (int i = 0; i < length; i++)
	{
		if ([location characterAtIndex:i] == '/')
			level++;
	}
	//
	level = level - 2;
	if (level < 0)
		return 0;
	//
	return level;
}

+ (NSString*) locationLocaleName:(NSString*)location
{
	NSString* name = [WizIndex pathName:location];
	if ([WizIndex pathLevel:location] != 0)
		return name;
	//
	if ([name isEqualToString:@"My Drafts"])
		return WizStrMyDrafts;
	else if ([name isEqualToString:@"My Journals"])
		return WizStrMyJournals;
	else if ([name isEqualToString:@"My Mobiles"])
		return WizStrMyMobiles;
	else if ([name isEqualToString:@"My Events"])
		return WizStrMyEvents;
	else if ([name isEqualToString:@"My Notes"])
		return WizStrMyNotes;
	//
	return name;
}

-(NSDictionary*) attachmentFileMd5:(NSString *)attachmentGUID
{
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attachmentGUID];
    [WizGlobals ensurePathExists:objectPath];
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:nil];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:@"temppp.ziw"];
    
    NSMutableDictionary* md5s = [NSMutableDictionary dictionary];
    
    for(NSString* each in selectedFile) {
        NSString* path = [objectPath stringByAppendingPathComponent:each];
        if(![each isEqualToString:@"temppp.ziw"])
            [md5s setObject:[WizApi fileMD5:path]  forKey:@"data_file_md5"];
    }
    if(![[NSFileManager defaultManager] fileExistsAtPath:zipPath])
    {
        [self createZipByGuid:attachmentGUID];
        [md5s setObject:[WizApi fileMD5:zipPath] forKey:@"ziw_file_md5"];
        [WizGlobals deleteFile:objectPath];
    } else {
        [md5s setObject:[WizApi fileMD5:zipPath] forKey:@"ziw_file_md5"];
    }
    return md5s;
}

-(NSString*) createZipByGuid:(NSString*)objectGUID 
{
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:objectGUID];
    //
    [WizGlobals ensurePathExists:objectPath];
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:nil];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:@"temppp.ziw"];
    ZipArchive* zip = [[ZipArchive alloc] init];
    
    BOOL ret;
    ret = [zip CreateZipFile2:zipPath];
    for(NSString* each in selectedFile) {
        BOOL isDir;
        NSString* path = [objectPath stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:each zipFile:zip];
        }
        else
        {
            ret = [zip addFileToZip:path newname:each];
        }
    }
    
    [zip CloseZipFile2];
    if(!ret) zipPath =nil;
    [zip release];
    return zipPath;
}

-(BOOL) addToZipFile:(NSString*) directory directoryName:(NSString*)name zipFile:(ZipArchive*) zip
{
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:nil];
    
    for(NSString* each in selectedFile) {
        BOOL isDir;
        NSString* path = [directory stringByAppendingPathComponent:each];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir] && isDir)
        {
            [self addToZipFile:path directoryName:[NSString stringWithFormat:@"%@/%@",name,each] zipFile:zip];
        }
        else
        {
            if(! [zip addFileToZip:path newname:[NSString stringWithFormat:@"/%@/%@",name,each]]) 
            {
                return NO;
            }
        }
    }
    return YES;
}

-(BOOL) deleteTempFileByGUID:(NSString*)objectGuid
{
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:objectGuid];
    [WizGlobals ensurePathExists:objectPath];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:@"temppp.zip"];
    BOOL ret = [WizGlobals deleteFile:zipPath];
    return ret;
}

-(int) attachmentCountOfDocument:(NSString *)documentGUID
{
    NSArray* attachList = [self attachmentsByDocumentGUID:documentGUID];
    return [attachList count];
}

+ (NSString*) pinyinFirstLetter:(NSString *)string
{
    return  [[NSString stringWithFormat:@"%c",pinyinFirstLetter([string characterAtIndex:0])] uppercaseString];
}

+ (NSString*) timerStringFromTimerInver:(NSTimeInterval) ftime
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:ftime];
    NSRange range = NSMakeRange(14, 5);
    NSString* ret = [[formatter stringFromDate:date] substringWithRange:range];
    [formatter release];
    return ret;
}
@end




NSInteger compareString(id location1, id location2, void* context)
{
	NSString* str1 = location1;
	NSString* str2 = location2;
	//
	return [str1 compare: str2 options:NSCaseInsensitiveSearch];
}

NSInteger compareTag(id location1, id location2, void*)
{
	WizTag* tag1 = location1;
	WizTag* tag2 = location2;
	//
	return [tag1.namePath compare: tag2.namePath options:NSCaseInsensitiveSearch];
}