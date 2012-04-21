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
//WizAttachment
//@interface WizAttachment(initFromDb)
//- (id) initFromWizAttachmentData:(const WIZDOCUMENTATTACH&) data;
//@end
//@implementation WizAttachment(initFromDb)
//
//- (id) initFromWizAttachmentData:(const WIZDOCUMENTATTACH &)data
//{
//    self = [super init];
//    if (self) {
//        self.guid = [NSString stringWithCString:data.strAttachmentGuid.c_str() encoding:NSUTF8StringEncoding];
//        self.title = [NSString stringWithCString:data.strAttachmentName.c_str() encoding:NSUTF8StringEncoding];
//        self.description = [NSString stringWithCString:data.strDescription.c_str() encoding:NSUTF8StringEncoding];
//        self.documentGuid = [NSString stringWithCString:data.strDocumentGuid.c_str() encoding:NSUTF8StringEncoding];
//        self.dataMd5 = [NSString stringWithCString:data.strDataMd5.c_str() encoding:NSUTF8StringEncoding];
//        self.dateModified = [WizGlobals sqlTimeStringToDate:[NSString stringWithCString:data.strDataModified.c_str() encoding:NSUTF8StringEncoding]];
//        self.localChanged = data.loaclChanged?YES:NO;
//        self.serverChanged = data.serverChanged?YES:NO;
//    }
//    return self;
//}
//
//@end

//wizdocument
@interface WizNote(InitFromDb)
- (id) initFromWizDocumentData: (const WIZDOCUMENTDATA&) data;
@end
@implementation WizNote(InitFromDb)

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

//@interface WizTag(db)
//- (id) initFromWizTagData:(const WIZTAGDATA&) data;
//@end
//@implementation WizTag(db)
//- (id) initFromWizTagData:(const WIZTAGDATA &)data
//{
//    self = [super init];
//    if (self) {
//        self.guid = [NSString stringWithCString:data.strGUID.c_str() encoding:NSUTF8StringEncoding];
//        self.parentGuid = [NSString stringWithCString:data.strParentGUID.c_str() encoding:NSUTF8StringEncoding];
//        self.description = [NSString stringWithCString:data.strDescription.c_str() encoding:NSUTF8StringEncoding];
//        self.title  = [NSString stringWithCString:data.strName.c_str() encoding:NSUTF8StringEncoding];
//        self.dateModified = [WizGlobals sqlTimeStringToDate:[NSString stringWithCString:data.strDtInfoModified.c_str() encoding:NSUTF8StringEncoding]];
//        self.localChanged = data.localchanged?YES:NO;
//    }
//    return self;
//}
//
//@end
@interface WizDbManager()
{
    CIndex index;
    CTempIndex tempIndex;
}
- (void)registerActiveAccount;
@end

@implementation WizDbManager
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




//single object
static WizDbManager* shareDbManager = nil;
+ (id) shareDbManager
{
    @synchronized(shareDbManager)
    {
        if (shareDbManager == nil) {
            shareDbManager = [[super allocWithZone:NULL] init];
            [WizNotificationCenter addObserverForRegisterActiveAccount:shareDbManager selector:@selector(registerActiveAccount)];
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
- (BOOL) openDb
{
    NSString* dbFilePath = [WizFileManager accountDbFilePath];
    bool indexIsOpen = index.Open([dbFilePath UTF8String]);
    NSString* tempDbFilePath = [WizFileManager accountTempDbFilePath];
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
- (BOOL) setSyncVersionForKbGuid:(NSString*)kbGuid  key:(NSString*)key version:(int64_t)ver
{
    NSString* dataKey = [kbGuid stringByAppendingString:key];
    return [self setSyncVersion:dataKey version:ver];
}
- (int64_t) syncVersionForKbGuid:(NSString*)guid key:(NSString*)key
{
    NSString* dataKey = [guid stringByAppendingString:key];
    return [self syncVersion:dataKey];
}
- (int64_t) documentVersionForKbGuid:(NSString*)kbGuid
{
	return [self syncVersionForKbGuid:kbGuid key:DocumentNameOfSyncVersion];
}
- (BOOL) setDocumentVersionForKbGuid:(NSString*)kbGuid  version:(int64_t)ver  
{
	return [self setSyncVersionForKbGuid:kbGuid key:DocumentNameOfSyncVersion version:ver];
}
- (int64_t) attachmentVersionForKbGuid:(NSString*)kbGuid
{
    return [self syncVersionForKbGuid:kbGuid key:AttachmentNameOfSyncVersion];
}
- (BOOL) setAttachmentVersionForKbGuid:(NSString*)kbGuid  version:(int64_t)ver
{
    return [self setSyncVersionForKbGuid:kbGuid key:AttachmentNameOfSyncVersion version:ver];
}
- (int64_t) tagVersionForKbGuid:(NSString*)kbGuid
{
    return [self syncVersionForKbGuid:kbGuid key:TagVersion];
}
- (BOOL) setTagVersionForKbGuid:(NSString*)kbGuid  version:(int64_t)ver
{
    return [self setSyncVersionForKbGuid:kbGuid key:TagVersion version:ver];
}
- (BOOL) setDeleteVersionForKbGuid:(NSString*)kbGuid  version:(int64_t)ver
{
    return [self setSyncVersionForKbGuid:kbGuid key:DeletedGUIDNameOfSyncVersion version:ver];
}
- (int64_t) deleteVersionForKbGuid:(NSString*)kbGuid
{
    return [self syncVersionForKbGuid:kbGuid key:DeletedGUIDNameOfSyncVersion];
}
//
- (BOOL) setPriveteKbGuid:(NSString *)kbGuid
{
    return [self setMeta:TypeOfWizGroup key:TypeOfPrivateGroup value:kbGuid];
}
- (NSString*) priveteKbGuid
{
    return [self meta:TypeOfWizGroup key:TypeOfPrivateGroup];
}
//
- (BOOL) updateDocumentForKbGuid:(NSString*)kbGuid doc:(NSDictionary*) doc
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
    NSNumber* infoChanged = [doc valueForKey:DataTypeUpdateDocumentInfoLocalChanged];
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
    data.strKbguid = [kbGuid UTF8String];
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
    if (nil == infoChanged) {
        data.nInfoLocalChanged = 0;
    }
    else {
        data.nInfoLocalChanged = [infoChanged intValue];
    }
    BOOL ret =  index.UpdateDocument(data) ? YES : NO;
	return ret;
}
- (BOOL) updateDocumentsForKbGuid:(NSString *)kbGuid docs:(NSArray *)documents
{
	for (NSDictionary* doc in documents)
	{
		@try {
            [self updateDocumentForKbGuid:kbGuid doc:doc];
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
	//
	CWizDocumentDataArray arrayDocument;
	index.GetDocumentsByKey([keywords UTF8String], arrayDocument);
	return [self documentsFromWizDocumentDataArray: arrayDocument];
}

//attachment
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
    data.strDataModified = [[WizGlobals dateToSqlString:dateModified] UTF8String];
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
- (NSArray*) attachmentsFromDocumentGuid:(NSString *)documentGUID
{
    CWizDocumentAttachmentArray arrayAttachment;
    if (!index.AttachmentsFromDocumentGUID([documentGUID UTF8String], arrayAttachment)) {
        return nil;
    }
    return [self attachmentsFormWizDocumentAttachmentArray:arrayAttachment];
}
//tag
- (WizTag*) tagFromGUID:(NSString *)_guid
{
    WIZTAGDATA data;
    if (!index.TagFromGUID([_guid UTF8String], data)) {
        return nil;
    }
    WizTag* tag = [[WizTag alloc] initFromWizTagData:data];
    return [tag autorelease];
}
- (BOOL) updateTag: (NSDictionary*) tag
{
	NSString* name = [tag valueForKey:DataTypeUpdateTagTitle];
	NSString* guid = [tag valueForKey:DataTypeUpdateTagParentGuid];
	NSString* parentGuid = [tag valueForKey:DataTypeUpdateTagParentGuid];
	NSString* description = [tag valueForKey:DataTypeUpdateTagDescription];
    NSNumber* version = [tag valueForKey:DataTypeUpdateTagVersion];
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
    if (nil == version) {
        version = [NSNumber numberWithInt:0];
    }
	WIZTAGDATA data;
	data.strName = [name UTF8String];
	data.strGUID = [guid UTF8String];
    data.strParentGUID = [parentGuid UTF8String];
	data.strDescription= [description UTF8String];
    data.strDtInfoModified = [[WizGlobals dateToSqlString:dtInfoModifed] UTF8String];
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
//delete
- (BOOL) addDeletedGUIDRecord: (NSString*)guid type:(NSString*)type
{
	return index.LogDeletedGUID([guid UTF8String], [type UTF8String]) ? YES : NO;
}
-(BOOL) deleteAttachment:(NSString *)attachGuid
{
    BOOL ret = index.DeleteAttachment([attachGuid UTF8String]) ? YES : NO;
    if (ret) {
        NSString* attachmentDirectory = [WizFileManager objectDirectoryPath:attachGuid];
        if (![[NSFileManager defaultManager] removeItemAtPath:attachmentDirectory error:nil]) {
            NSLog(@"delete document error!");
        }
        [self addDeletedGUIDRecord:attachGuid type:WizAttachmentKeyString];
    }
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
        NSArray* attachments = [self attachmentsFromDocumentGuid:documentGUID];
        NSString* documentDirectory = [WizFileManager objectDirectoryPath:documentGUID];
        if (![[NSFileManager defaultManager] removeItemAtPath:documentDirectory error:nil]) {
            NSLog(@"delete document error!");
        }
        for(WizAttachment* each in attachments)
        {
            [self deleteAttachment:each.guid];
        }
        [self addDeletedGUIDRecord:documentGUID type:WizDocumentKeyString];
    }
	return ret;
}
- (BOOL) setGroupKbGuid:(NSString *)kbGuid  key:(NSString*)key
{
    return [self setMeta:TypeOfWizGroup key:key value:kbGuid];
}
- (NSString*) groupKbGuid:(NSString*)key
{
    return [self meta:TypeOfWizGroup key:key];
}
- (BOOL) updateKbGuid:(NSDictionary*)kbGuidData
{
    int i = 0;
    NSString* guid = [kbGuidData valueForKey:DataTypeUpdateKbGuid];
    for (; i < NSIntegerMax; i++) {
        NSString* key = [NSString stringWithFormat:@"%d",i];
        NSString* existGuid = [self groupKbGuid:key];
        if (existGuid == nil || [existGuid isBlock]) {
            return [self setGroupKbGuid:guid key:key];
        }
        else {
            if ([existGuid isEqualToString:guid]) {
                return YES;
            }
        }
    }
    return YES;
}
- (BOOL) updateKbGuidDatas: (NSArray*) tags
{
	for (NSDictionary* kbData in tags)
	{
		try 
		{
			[self updateKbGuid:kbData];
		}
		catch (...) 
		{
		}
	}
	//
	return YES;
}
@end
