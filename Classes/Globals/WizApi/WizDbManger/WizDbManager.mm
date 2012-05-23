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
#import "WizFileManager.h"
#import "WizNotification.h"
#import "WizAbstractCache.h"
#define AttachmentNameOfSyncVersion     @"ATTACHMENTVERSION"
//
#define TypeOfWizGroup                  @"GROUPS"
#define TypeOfPrivateGroup              @"PRIVATE"
//
#define KeyOfSyncVersion               @"SYNC_VERSION"
#define DocumentNameOfSyncVersion      @"DOCUMENT"
#define DeletedGUIDNameOfSyncVersion   @"DELETED_GUID"
#define TagVersion                     @"TAGVERSION"
#define UserTrafficLimit               @"TRAFFICLIMIT"
#define UserTrafficUsage               @"TRAFFUCUSAGE"
#define KeyOfUserInfo                  @"USERINFO"
#define UserLevel                      @"USERLEVEL"
#define UserLevelName                  @"USERLEVELNAME"
#define UserType                       @"USERTYPE"
#define UserPoints                     @"USERPOINTS"
#define AttachmentVersion              @"ATTACHMENTVERSION"
#define MoblieView                     @"MOBLIEVIEW"
#define DurationForDownloadDocument    @"DURATIONFORDOWLOADDOCUMENT"
#define WebFontSize                    @"WEBFONTSIZE"
#define DatabaseVesion                 @"DATABASE"
#define ImageQuality                   @"IMAGEQUALITY"
#define ProtectPssword                 @"PROTECTPASSWORD"
#define FirstLog                       @"UserFirstLog"
#define UserTablelistViewOption        @"UserTablelistViewOption"
#define WizNoteAppVerSion              @"wizNoteAppVerSion"
#define ConnectServerOnlyByWif         @"ConnectServerOnlyByWif"
#define AutomicSync                     @"AutomicSync"

@interface WizDeletedGUID : NSObject
{
	NSString* guid;
	NSString* type;
	NSString* dateDeleted;
}
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain)NSString* type;
@property (nonatomic, retain)NSString* dateDeleted;
@end


@implementation WizDeletedGUID

@synthesize guid;
@synthesize type;
@synthesize dateDeleted;

-(void) dealloc
{
    [guid release];
    [type release];
    [dateDeleted release];
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
		self.dateCreated         = [[NSString stringWithCString:data.strDateCreated.c_str() encoding:NSUTF8StringEncoding] dateFromSqlTimeString];
		self.dateModified        = [[NSString stringWithCString:data.strDateModified.c_str() encoding:NSUTF8StringEncoding] dateFromSqlTimeString];
        self.tagGuids           = [NSString stringWithCString:data.strTagGUIDs.c_str() encoding:NSUTF8StringEncoding];
        self.dataMd5             = [NSString stringWithCString:data.strDataMd5.c_str() encoding:NSUTF8StringEncoding];
		self.attachmentCount     = data.nAttachmentCount;
        self.serverChanged      = data.nServerChanged?YES:NO;
        self.localChanged       = data.nLocalChanged;
        self.protected_         = data.nProtected?YES:NO;
	}
	return self;
}
@end

@interface WizTag (InitFromDb)
- (id) initFromWizTagData:(const WIZTAGDATA&) data;
@end

@implementation WizTag (InitFromDb)
- (id) initFromWizTagData:(const WIZTAGDATA &)data
{
    self = [super init];
    if (self) {
        self.guid = [NSString stringWithCString:data.strGUID.c_str() encoding:NSUTF8StringEncoding];
        self.title = [NSString stringWithCString:data.strName.c_str() encoding:NSUTF8StringEncoding];
        self.namePath = [NSString stringWithCString:data.strNamePath.c_str() encoding:NSUTF8StringEncoding];
        self.description = [NSString stringWithCString:data.strDescription.c_str() encoding:NSUTF8StringEncoding];
        self.parentGUID = [NSString stringWithCString:data.strParentGUID.c_str() encoding:NSUTF8StringEncoding];
        self.dateInfoModified = [[NSString stringWithCString:data.strDtInfoModified.c_str() encoding:NSUTF8StringEncoding] dateFromSqlTimeString];
        self.localChanged = data.localchanged ? YES:NO;
    }
    return self;
}
@end

@interface WizAttachment (InitFromDb)
- (id) initFromWizAttachmentData:(const WIZDOCUMENTATTACH&) data;
@end
@implementation WizAttachment (InitFromDb)

- (id) initFromWizAttachmentData:(const WIZDOCUMENTATTACH &)data
{
    self = [super init];
    if (self) {
        self.guid = [NSString stringWithCString:data.strAttachmentGuid.c_str() encoding:NSUTF8StringEncoding];
        self.title = [NSString stringWithCString:data.strAttachmentName.c_str() encoding:NSUTF8StringEncoding];
        self.dateMd5 = [NSString stringWithCString:data.strDataMd5.c_str() encoding:NSUTF8StringEncoding];
        self.description = [NSString stringWithCString:data.strDescription.c_str() encoding:NSUTF8StringEncoding];
        self.documentGuid = [NSString stringWithCString:data.strDocumentGuid.c_str() encoding:NSUTF8StringEncoding];
        self.dateModified = [[NSString stringWithCString:data.strDataModified.c_str() encoding:NSUTF8StringEncoding]dateFromSqlTimeString];
        self.localChanged = data.loaclChanged?YES:NO;
        self.serverChanged = data.serverChanged?YES:NO;
    }
    return  self;
}

@end

@interface WizDbManager()
{
    CIndex index;
    CTempIndex tempIndex;
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
// over

- (void) close
{
    index.Close();
}
- (BOOL) isOpen
{
    return index.IsOpened();
}
- (void) setDocumentServerChanged:(NSString*)guid  changed:(NSInteger)changed
{
    index.SetDocumentLocalChanged([guid UTF8String], changed);
}

- (void) initAccountSetting
{
    //    [self versionUpdateSettings];
    if (![WizGlobals WizDeviceIsPad] ) {
        if ([self imageQualityValue] == 0) {
            [self setImageQualityValue:750];
        }
        if (0 == [self webFontSize]) {
            [self setWebFontSize:270];
        }
        if (-1 == [self durationForDownloadDocument]) {
            if ([WizGlobals WizDeviceIsPad]) {
                [self setDurationForDownloadDocument:3];
            }
            else {
                [self setDurationForDownloadDocument:0];
            }
        }
    }
    else
    {
        if ([self durationForDownloadDocument]== -1) {
            [self setDurationForDownloadDocument:0];
            
        }
        if ([self imageQualityValue] ==0) {
            [self setImageQualityValue:750];
        }
    }
}

- (BOOL) openDb:(NSString*)dbFilePath
{
    NSLog(@"dbFilePath is %@",dbFilePath);
    bool indexIsOpen = index.Open([dbFilePath UTF8String]);
    if (indexIsOpen) {
        [self initAccountSetting];
        return YES;
    }
    return NO;
}
- (BOOL) openTempDb:(NSString *)tempDbFilePath
{
    BOOL ret = tempIndex.Open([tempDbFilePath UTF8String]);
    return ret;
}
- (BOOL) isTempDbOpen
{
    return tempIndex.IsOpened();
}
- (void) closeTempDb
{
    return tempIndex.Close();
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

- (NSString*) userInfo:(NSString*)type
{
    NSString* str = [self meta:KeyOfUserInfo key:type];
    return str;
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
- (WizDocument*) documentFromGUID:(NSString*)documentGUID
{
    WIZDOCUMENTDATA data;
    if (!index.DocumentFromGUID([documentGUID UTF8String], data))
        return nil;
    WizDocument* doc = [[WizDocument alloc] initFromWizDocumentData:data];
    return [doc autorelease];
}
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID
{
    return  tempIndex.DeleteAbstractByGUID([documentGUID UTF8String])?YES:NO;
}

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
	data.strDateCreated = [[dateCreated stringSql] UTF8String];
	data.strDateModified = [[dateModified stringSql] UTF8String];
	data.strType = [type UTF8String];
	data.strFileType = [fileType UTF8String];
    data.nAttachmentCount = [nAttachmentCount intValue];
    if (nProtected == nil) {
        data.nProtected = 0;
    }
    else {
        data.nProtected = [nProtected intValue];
    }
    if (nil == localChanged) {
        data.nLocalChanged = 0;
    }
    else {
        data.nLocalChanged = [localChanged intValue];
    }
    
    if (nil == serverChanged) {
        data.nServerChanged = 1;
        WizDocument* docExit = [WizDocument documentFromDb:guid];
        if (nil != docExit && [docExit.dataMd5 isEqualToString:dataMd5]) {
            data.nServerChanged = 0;
        }
    }
    else {
        data.nServerChanged = [serverChanged  boolValue];
    }
    BOOL ret =  index.UpdateDocument(data) ? YES : NO;
    [self deleteAbstractByGUID:guid];
    if (data.nServerChanged == 0 || data.nLocalChanged!=0) {
        [self extractSummary:guid];
    }
	return ret;
}
- (BOOL) updateDocuments:(NSArray *)documents
{
    NSLog(@"documents count is %d",[documents count]);
    for (int i =0; i < [documents count]; i++) {
        NSDictionary* doc = [documents objectAtIndex:i];
        @try {
            [self updateDocument:doc];
        }
        @catch (NSException *exception) {
            continue;
        }
        @finally {
            
        }
    }
    if ([documents count]) {
        [WizNotificationCenter postupdateDocumentListMessage];
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
		WizDocument* doc = [[WizDocument alloc] initFromWizDocumentData:*it];
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
	index.GetRecentDocuments(arrayDocument);	return [self documentsFromWizDocumentDataArray: arrayDocument];
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
- (NSArray*) documentsByLocation: (NSString*)parentLocation
{
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByLocation([parentLocation UTF8String], arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}
- (NSArray*) documentForUpload
{
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsForUpdate(arrayDocument);
	//
	return [self documentsFromWizDocumentDataArray: arrayDocument];	
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    CWizDocumentDataArray arrayDocument;
    index.documentsWillDowload(duration, arrayDocument);
    return [self documentsFromWizDocumentDataArray:arrayDocument];
}
//
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


//tag
- (NSString*) tagAbstractString:(NSString *)guid
{
    std::string data = index.GetTagAbstract([guid UTF8String]);
    NSString* ret = [[NSString alloc]initWithBytes:data.data() length:data.length() encoding:NSUTF8StringEncoding];
    return [ret autorelease];
}
- (NSArray*) allTagsForTree
{
    CWizTagDataArray arrayTag;
    index.GetAllTagsPathForTree(arrayTag);
    NSMutableArray* tags = [NSMutableArray arrayWithCapacity:arrayTag.size()];
    for (CWizTagDataArray::const_iterator it = arrayTag.begin();
         it != arrayTag.end();
         it++)
    {
        WizTag* tag = [[WizTag alloc] initFromWizTagData:*it];
        [tags addObject:tag];
        [tag release];
    }
    [tags sortUsingFunction:compareTag context:NULL];
    return tags;
}
-(NSArray*) tagsForUpload
{
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
-(WizTag*) tagFromGuid:(NSString *)guid
{
    WIZTAGDATA tagData;
    if (!index.TagFromGUID([guid UTF8String], tagData)) {
        return nil;
    }
    WizTag* tag = [[[WizTag alloc] initFromWizTagData:tagData] autorelease];
    return tag;
}
- (BOOL) updateTag: (NSDictionary*) tag
{
	NSString* name = [tag valueForKey:DataTypeUpdateTagTitle];
	NSString* guid = [tag valueForKey:DataTypeUpdateTagGuid];
	NSString* parentGuid = [tag valueForKey:DataTypeUpdateTagParentGuid];
	NSString* description = [tag valueForKey:DataTypeUpdateTagDescription];
    NSDate* dtInfoModifed = [tag valueForKey:DataTypeUpdateTagDtInfoModifed];
    NSNumber* localChanged = [tag valueForKey:DataTypeUpdateTagLocalchanged];
	
    if (nil == localChanged) {
        localChanged = [NSNumber numberWithInt:0];
    }
    if (nil == dtInfoModifed) {
        dtInfoModifed = [NSDate date];
    }
    if (nil == guid) {
        return NO;
    }
    if (nil == description) {
        description = @"";
    }
    if (nil == parentGuid) {
        parentGuid = @"";
    }
	WIZTAGDATA data;
	data.strName = [name UTF8String];
	data.strGUID = [guid UTF8String];
    data.strParentGUID = [parentGuid UTF8String];
	data.strDescription= [description UTF8String];
    data.strDtInfoModified = [[dtInfoModifed stringSql] UTF8String];
    data.localchanged = [localChanged intValue];
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

//- (NSString*) tagAbstractString:(NSString*)tagGuid
//{
//    index.GetTagPostList(<#CWizTagDataArray &array#>)
//}
//
-(NSArray*) attachmentsFormWizDocumentAttachmentArray:(const CWizDocumentAttachmentArray&) array
{
    NSMutableArray* arr = [NSMutableArray array];
    for(CWizDocumentAttachmentArray::const_iterator it = array.begin();
        it != array.end();
        it++)
    {
        WizAttachment* attach = [[WizAttachment alloc] initFromWizAttachmentData:*it];
        if(attach)
        {
            [arr addObject:attach];
            [attach release];
        }
        
    }
    return arr;
}
-(NSArray*) attachmentsByDocumentGUID:(NSString*) documentGUID
{
    //
    CWizDocumentAttachmentArray arrayAttachment;
    index.AttachmentsFromDocumentGUID([documentGUID UTF8String], arrayAttachment);
    //
    return [self attachmentsFormWizDocumentAttachmentArray: arrayAttachment];
}
- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    return index.SetAttachmentLocalChanged([attchmentGUID UTF8String], changed? true : false) ? YES: NO;
}
- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    return index.SetAttachmentServerChanged([attchmentGUID UTF8String], changed? true : false) ? YES: NO;
}
- (WizAttachment*) attachmentFromGUID:(NSString *)guid
{
    WIZDOCUMENTATTACH data;
    if (!index.AttachFromGUID([guid UTF8String], data)) {
        return nil;
    }
    WizAttachment* attachment = [[WizAttachment alloc] initFromWizAttachmentData:data];
    return [attachment autorelease];
}
- (BOOL) updateAttachment:(NSDictionary *)attachment
{
    NSString* guid = [attachment valueForKey:DataTypeUpdateAttachmentGuid];
    NSString* title = [attachment valueForKey:DataTypeUpdateAttachmentTitle];
    NSString* description = [attachment valueForKey:DataTypeUpdateAttachmentDescription];
    NSString* dataMd5 = [attachment valueForKey:DataTypeUpdateAttachmentDataMd5];
    NSString* documentGuid = [attachment valueForKey:DataTypeUpdateAttachmentDocumentGuid];
    NSNumber* localChanged = [attachment valueForKey:DataTypeUpdateAttachmentLocalChanged];
    NSNumber* serVerChanged = [attachment valueForKey:DataTypeUpdateAttachmentServerChanged];
    NSDate*   dateModified = [attachment valueForKey:DataTypeUpdateAttachmentDateModified];
    if (nil == title  || [title isBlock]) {
        title = WizStrNoTitle;
    }
    if (nil == description || [description isBlock]) {
        description = @"none";
    }
    if (nil == dataMd5 || [dataMd5 isBlock]) {
        dataMd5 = @"";
    }
    if (nil == documentGuid || [documentGuid isBlock]) {
        NSException* ex = [NSException exceptionWithName:WizUpdateError reason:@"documentguid is nil" userInfo:nil];
        @throw ex;
    }
    if (nil == guid || [guid isBlock]) {
        NSException* ex = [NSException exceptionWithName:WizUpdateError reason:@"guid is nil" userInfo:nil];
        @throw ex;
    }
    if (nil == dateModified) {
        dateModified = [NSDate date];
    }
    if (nil == localChanged) {
        localChanged = [NSNumber numberWithInt:0];
    }
    if (nil == serVerChanged) {
        serVerChanged = [NSNumber numberWithInt:1];
    }
    WIZDOCUMENTATTACH data;
    data.strAttachmentGuid = [guid UTF8String];
    data.strAttachmentName = [title UTF8String];
    data.strDataMd5 = [dataMd5 UTF8String];
    data.strDataModified = [[dateModified stringSql] UTF8String];
    data.strDescription = [description UTF8String];
    data.strDocumentGuid = [documentGuid UTF8String];
    data.loaclChanged = [localChanged boolValue];
    data.serverChanged = [serVerChanged boolValue];
    return index.updateAttachment(data);
}

- (BOOL) updateAttachments:(NSArray *)attachments
{
    for (NSDictionary* doc in attachments)
	{
		@try {
            [self updateAttachment:doc];
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
//abstract
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID
{
    WIZABSTRACT abstract;
    if (![WizGlobals WizDeviceIsPad]) {
        tempIndex.PhoneAbstractFromGUID([documentGUID UTF8String], abstract);
    }
    else
    {
        tempIndex.PadAbstractFromGUID([documentGUID UTF8String], abstract);
    }
    NSString* text = [[NSString alloc] initWithUTF8String:abstract.text.c_str()];
    NSData* imageData = [[NSData alloc] initWithBytes:abstract.imageData length:abstract.imageDataLength];
    UIImage* image = [UIImage imageWithData:imageData];
    WizAbstract* ret = [[[WizAbstract alloc] init] autorelease];
    ret.image = image;
    ret.text = text;
    [text release];
    [imageData release];
    return ret;
}
- (void) extractSummary:(NSString *)documentGUID
{
    BOOL WizDeviceIsPad = [WizGlobals WizDeviceIsPad];
    WIZABSTRACT abstract;
    abstract.guid = [documentGUID UTF8String];
    abstract.imageDataLength = 0;
    NSString* sourceFilePath = [[WizFileManager shareManager] documentIndexFile:documentGUID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return;
    }
    NSData* abstractImageData = nil;
    NSString* abstractText = nil;
    NSLog(@"%@",sourceFilePath);
    NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath usedEncoding:nil error:nil];
    NSString* removeTitle = [sourceStr stringReplaceUseRegular:@"<title.*title>"];
    NSString* removeStyle = [removeTitle stringReplaceUseRegular:@"<style[^>]*?>[\\s\\S]*?<\\/style>"];
    NSString* removeScript = [removeStyle stringReplaceUseRegular:@"<script[^>]*?>[\\s\\S]*?<\\/script>"];
    NSString* removeHtmlSpace = [removeScript stringReplaceUseRegular:@"&(.*?);"];
    NSString* removeOhterCharacter = [removeHtmlSpace stringReplaceUseRegular:@"&#(.*?);" ];
    NSString* removeBlock = [removeOhterCharacter stringReplaceUseRegular:@"\\s{2,}|\\ \\;"];
    NSString* removeCOntrol = [removeBlock stringReplaceUseRegular:@"/\n" ];
    NSString* prepareStr = [removeCOntrol stringReplaceUseRegular:@"<[^>]*>" ];
    NSString* destStr = [prepareStr stringReplaceUseRegular:@"'"];
    if (destStr == nil || [destStr isEqualToString:@""]) {
        destStr = @"";
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
        NSRange range = NSMakeRange(0, 100);
        if (abstractText.length <= 100) {
            range = NSMakeRange(0, destStr.length);
        }
        abstractText = [destStr substringWithRange:range];
    }
    NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documentGUID];
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
        }
    }
    UIImage* compassImage = nil;
    //    UIImage* compassImageBig = nil;
    if (nil != maxImage) {
        float compassWidth=0;
        float compassHeight = 0;
        if (WizDeviceIsPad) {
            compassWidth = 175;
            compassHeight = 85;
            compassImage = [maxImage wizCompressedImageWidth:compassWidth height:compassHeight];
            //            compassImageBig = [maxImage wizCompressedImageWidth:140 height:140];
        }
        else
        {
            compassImage = [maxImage wizCompressedImageWidth:140 height:140];
        }
        
    }
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
- (BOOL) clearCache
{
    return YES;
}

//
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
    return arr;
}
- (NSArray*) allDeletedGUIDs
{
    CWizDeletedGUIDDataArray arrayGUID;
    index.GetAllDeletedGUIDs(arrayGUID);
    return [self deletedGUIDsFromWizDeletedGUIDDataArray: arrayGUID];
}
- (NSArray*) deletedGUIDsForUpload
{
    NSMutableArray* ret = [NSMutableArray array];
    NSArray* src = [self allDeletedGUIDs];
    for (WizDeletedGUID* guid in src)
    {
        NSDate* date = [guid.dateDeleted dateFromSqlTimeString];
        //
        NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:guid.guid, @"deleted_guid", guid.type, @"guid_type", date, @"dt_deleted", nil];
        [ret addObject:dict];
        [dict release];
    }
    return ret;
}
- (BOOL) clearDeletedGUIDs
{
    //
    return index.ClearDeletedGUIDs() ? YES : NO;
}

//
- (BOOL) addLocation: (NSString*) location
{
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

- (void) stdStringArrayToNSArray: (const CWizStdStringArray&) arrayLocation retArray:(NSArray**) pretArray
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
//folder
- (NSArray*) allLocationsForTree
{
    CWizStdStringArray arrayLocation;
    index.GetAllLocations(arrayLocation);
    NSArray* allLocations = nil;
    [self stdStringArrayToNSArray: arrayLocation retArray:&allLocations];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc ] init];
    for (NSString* location in allLocations)
    {
        NSString* subLocation = location;
        while ([subLocation length] > 2)
        {
            [dict setObject:subLocation forKey:[subLocation lowercaseString]];
            subLocation = [subLocation stringByDeletingLastPathComponent];
            if ([subLocation isEqualToString:@"/"])
            {
                break;
            }
            subLocation = [subLocation stringByAppendingString:@"/"];
        }
    }
    //
    [allLocations release];
    NSMutableArray* locations = [NSMutableArray arrayWithArray:[dict allValues]];
    [locations sortUsingFunction:compareString context:NULL];
    [dict release];
    return locations;
}
- (int) filecountWithChildOfLocation:(NSString*) location
{
    int count;
    index.fileCountWithChildInlocation([location UTF8String], count);
    return count;
}
- (int) fileCountOfLocation:(NSString *)location
{
    int count;
    index.fileCountInLocation([location UTF8String], count);
    return count;
}
- (int) fileCountOfTag:(NSString *)tagGUID
{
    int count;
    index.fileCountInTag([tagGUID UTF8String], count);
    return count;
}
@end
