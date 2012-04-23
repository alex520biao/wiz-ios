//
//  WizDbManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDbManager.h"
#import "index.h"
#import "tempIndex.h"
#import "WizNote.h"
#define KeyOfSyncVersion   @"SYNC_VERSION"
#define DocumentNameOfSyncVersion       @"DOCUMENT"
#define DeletedGUIDNameOfSyncVersion    @"DELETED_GUID"
#define TagVersion                      @"TAGVERSION"
#define AttachmentNameOfSyncVersion     @"ATTACHMENTVERSION"
//
#define TypeOfWizGroup                  @"GROUPS"
#define TypeOfPrivateGroup              @"PRIVATE"
@interface WizDocument(InitFromDb)
- (id) initFromWizDocumentData: (const WIZDOCUMENTDATA&) data;
@end
@implementation WizDocument(InitFromDb)

- (id) initFromWizDocumentData: (const WIZDOCUMENTDATA&) data
{
    self = [super init];
	if (self)
	{
		self.guid                = [NSString stringWithCString:data.strGUID.c_str() encoding:NSUTF8StringEncoding];
		self.title               = [NSString stringWithCString:data.strTitle.c_str() encoding:NSUTF8StringEncoding];
		self.location            = [NSString stringWithCString:data.strLocation.c_str() encoding:NSUTF8StringEncoding];
		self.url                 = [NSString stringWithCString:data.strURL.c_str() encoding:NSUTF8StringEncoding];
		self.type                = [NSString stringWithCString:data.strType.c_str() encoding:NSUTF8StringEncoding];
		self.fileType            = [NSString stringWithCString:data.strFileType.c_str() encoding:NSUTF8StringEncoding];
		self.dateCreated         = [WizGlobals sqlTimeStringToDate:[NSString stringWithCString:data.strDateCreated.c_str() encoding:NSUTF8StringEncoding]];
		self.dateModified        = [WizGlobals sqlTimeStringToDate:[NSString stringWithCString:data.strDateModified.c_str() encoding:NSUTF8StringEncoding]];
        self.tagGuids           = [NSString stringWithCString:data.strTagGUIDs.c_str() encoding:NSUTF8StringEncoding];
        self.dataMd5             = [NSString stringWithCString:data.strDataMd5.c_str() encoding:NSUTF8StringEncoding];
		self.attachmentCount     = data.nAttachmentCount;
        self.serverChanged      = data.nServerChanged?YES:NO;
        self.localChanged       = data.nLocalChanged?YES:NO;
        self.protected_         = data.nProtected?YES:NO;
	}
	return self;
}

@end
@interface WizDbManager()
{
    CIndex index;
    CTempIndex tempIndex;
}
- (void)registerActiveAccount;
@end

@implementation WizDbManager


//single object
static WizDbManager* shareDbManager = nil;
+ (id) shareDbManager
{
    @synchronized(shareDbManager)
    {
        if (shareDbManager == nil) {
            shareDbManager = [[super allocWithZone:NULL] init];
        }
        return shareDbManager;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareDbManager] retain];
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

- (void) close
{
    index.Close();
    tempIndex.Close();
}
- (BOOL) isOpen
{
    return index.IsOpened() && tempIndex.IsOpened();
}
- (BOOL) openDb:(NSString*)dbFilePath    tempDbFilePath:(NSString*)tempDbFilePath
{
    bool indexIsOpen = index.Open([dbFilePath UTF8String]);
    bool tempIndexIsOpen = tempIndex.Open([tempDbFilePath UTF8String]);
    if (tempIndexIsOpen && indexIsOpen) {
        return YES;
    }
    else {
        index.Close();
        tempIndex.Close();
        return NO;
    }
}
- (void) registerActiveAccount
{
    if ([[WizDbManager shareDbManager] isOpen]) {
        [[WizDbManager shareDbManager] close];
    }
    if ([[WizDbManager shareDbManager] openDb]) {
        
    }
}
//data
- (NSString*) meta: (NSString*)name key:(NSString*)key
{
	std::string value = index.GetMeta([name UTF8String], [key UTF8String]);
	return [NSString stringWithUTF8String:value.c_str()];
}
- (BOOL) setMeta: (NSString*)name key:(NSString*)key value:(NSString*)value
{
	bool ret = index.SetMeta([name UTF8String], [key UTF8String], [value UTF8String]);
	return ret ? YES : NO;
}
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
- (BOOL) setSyncVersion:(NSString*)type version:(int64_t)ver
{
	NSString* verString = [NSString stringWithFormat:@"%lld", ver];
	
	return [self setMeta:KeyOfSyncVersion key:type value:verString];
}
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

// version
- (int64_t) documentVersion
{
	return [self syncVersion:DocumentNameOfSyncVersion];
}
- (BOOL) setDocumentVersion:(int64_t)ver
{
	return [self setSyncVersion:DocumentNameOfSyncVersion version:ver];
}
//
- (BOOL) setDeletedGUIDVersion:(int64_t)ver
{
	return [self setSyncVersion:DeletedGUIDNameOfSyncVersion version:ver];
}
- (int64_t) deletedGUIDVersion
{
	return [self syncVersion:DeletedGUIDNameOfSyncVersion];
}
//
- (int64_t) tagVersion
{
    return [self syncVersion:TagVersion];
}
- (BOOL) setTageVersion:(int64_t)ver
{
    return [self setSyncVersion:TagVersion version:ver];
}
//
- (int64_t) attachmentVersion
{
	return [self syncVersion:AttachmentVersion];
}
- (BOOL) setAttachmentVersion:(int64_t)ver
{
	return [self setSyncVersion:AttachmentVersion version:ver];
}
//
- (int64_t) wizDataBaseVersion
{
    return  [self syncVersion:DatabaseVesion];
}
- (BOOL) setWizDataBaseVersion:(int64_t)ver
{
    return [self setSyncVersion:DatabaseVesion version:ver];
}


//settings
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
-(BOOL) setUserTableListViewOption:(int64_t)option
{
    NSString* info = [NSString stringWithFormat:@"%lld",option];
    return [self setUserInfo:UserTablelistViewOption info:info];
}

- (int64_t) userTablelistViewOption
{
    NSString* str = [self userInfo:UserTablelistViewOption];
    if (str == nil || [str isEqualToString:@""]) {
        return -1;
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
        return -1;
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






//
- (BOOL) updateDocument:(NSDictionary*) doc
{
	NSString* guid = [doc valueForKey:DataTypeUpdateDocumentGUID];
	NSString* title =[doc valueForKey:DataTypeUpdateDocumentTitle];
	NSString* location = [doc valueForKey:DataTypeUpdateDocumentLocation];
	NSString* dataMd5 = [doc valueForKey:DataTypeUpdateDocumentDataMd5];
	NSString* url = [doc valueForKey:DataTypeUpdateDocumentUrl];
	NSString* tagGUIDs = [doc valueForKey:DataTypeUpdateDocumentTagGuids];
	NSDate* dateCreated = [doc valueForKey:DataTypeUpdateDocumentDateCreated];
	NSDate* dateModified = [doc valueForKey:DataTypeUpdateDocumentDateModified];
	NSString* type = [doc valueForKey:DataTypeUpdateDocumentType];
	NSString* fileType = [doc valueForKey:DataTypeUpdateDocumentFileType];
    NSNumber* nAttachmentCount = [doc valueForKey:DataTypeUpdateDocumentAttachmentCount];
    NSNumber* localChanged = [doc valueForKey:DataTypeUpdateDocumentLocalchanged];
    NSNumber* nProtected = [doc valueForKey:DataTypeUpdateDocumentProtected];
    NSNumber* serverChanged = [doc valueForKey:DataTypeUpdateDocumentServerChanged];
	WIZDOCUMENTDATA data;
	data.strGUID =[guid UTF8String];
	data.strTitle =[title UTF8String];
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
    if (nProtected == nil) {
        data.nProtected = 0;
    }
    else {
        data.nProtected = [nProtected intValue];
    }
    if (localChanged == nil) {
        data.nLocalChanged = 0;
    }
    else
    {
        data.nLocalChanged = [localChanged intValue];
    }
    if (nil == serverChanged) {
        data.nServerChanged = 1;
    }
    else {
        data.nServerChanged = [serverChanged intValue];
    }
    BOOL ret =  index.UpdateDocument(data) ? YES : NO;
	return ret;
}
- (BOOL) updateDocuments:(NSArray *)documents
{
	for (NSDictionary* doc in documents)
	{
		@try {
            [self updateDocument:doc];
        }
        @catch (NSException *exception) {
            return NO;
        }
        @finally {
            
        }
	}
	//
	return YES;
	
}
- (NSArray*) documentsFromWizDocumentDataArray: (const CWizDocumentDataArray&) arrayDocument
{
	NSMutableArray* arr = [NSMutableArray array];
	//
	for (CWizDocumentDataArray::const_iterator it = arrayDocument.begin();
		 it != arrayDocument.end();
		 it++)
	{
		WizNote* doc = [[WizNote alloc] initFromWizDocumentData:*it];
		if (doc)
		{
			[arr addObject:doc];
			[doc release];
		}
	}
	return arr;
}
- (NSArray*) recentDocuments
{
	CWizDocumentDataArray arrayDocument;
	index.GetRecentDocuments(arrayDocument);
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (WizNote*) documentFromGUID:(NSString *)guid
{
    WIZDOCUMENTDATA data;
    if (!index.DocumentFromGUID([guid UTF8String], data)) {
        return nil;
    }
    WizNote* doc = [[WizNote alloc] initFromWizDocumentData:data];
    return [doc autorelease];
}

- (NSArray*) documentsByTag: (NSString*)tagGUID
{
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByTag([tagGUID UTF8String], arrayDocument);
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (NSArray*) documentsByKey: (NSString*)keywords
{
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByKey([keywords UTF8String], arrayDocument);
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type
{
	return index.LogDeletedGUID([guid UTF8String], [type UTF8String]) ? YES : NO;
}
-(BOOL) deleteAttachment:(NSString *)attachGuid
{
    BOOL ret = index.DeleteAttachment([attachGuid UTF8String]) ? YES : NO;
    return ret;
}
- (BOOL) deleteTag:(NSString*)tagGuid
{
    NSArray* documents = [self documentsByTag:tagGuid];
    for (WizDocument* eachDoc in documents) {
        [eachDoc deleteTag:tagGuid];
    }
    return index.DeleteTag([tagGuid UTF8String]) ? YES : NO;
}
- (BOOL) deleteDocument:(NSString*)documentGUID
{
    BOOL ret = index.DeleteDocument([documentGUID UTF8String]) ? YES: NO;
    if (ret) {
        [self addDeletedGUIDRecord:documentGUID type:WizDocumentKeyString];
    }
	return ret;
}
@end
