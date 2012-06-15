//
//  WizInfoDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizInfoDataBase.h"
#import "WizDocument.h"
#import "WizAttachment.h"
#import "CommonString.h"
#import "WizTag.h"


#import "WizGlobals.h"
#define KeyOfSyncVersion                        @"SYNC_VERSION"
#define KeyOfSyncVersionDocument                @"DOCUMENT"
#define KeyOfSyncVersionDeletedGuid             @"DELETED_GUID"
#define KeyOfSyncVersionAttachment              @"ATTACHMENT"
#define KeyOfSyncVersionTag                     @"TAG"


//document


@interface NSString(SqlString)
- (NSString*)stringToSqlString;
@end

@implementation NSString(SqlString)
- (NSString*)stringToSqlString
{
    return [NSString stringWithFormat:@"'%@'",self];
}

@end

@implementation WizInfoDataBase

- (BOOL) isMetaExist:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    if ([self getMeta:lpszName withKey:lpszKey])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString*) getMeta:(NSString*)lpszName  withKey:(NSString*) lpszKey
{
    NSString* sql = [NSString stringWithFormat:@"select META_VALUE from WIZ_META where META_NAME='%@' and META_KEY='%@'",lpszName,lpszKey];
    FMResultSet* s = [dataBase executeQuery:sql];
    if ([s next]) {
        return [s stringForColumnIndex:0];
    }
    return nil;
}

- (BOOL) setMeta:(NSString*)lpszName  key:(NSString*)lpszKey value:(NSString*)value
{
    
    if (![self isMetaExist:lpszName withKey:lpszKey])
    {
        return [dataBase executeUpdate:@"insert into WIZ_META (META_NAME, META_KEY, META_VALUE) values(?,?,?)",lpszName, lpszKey, value];
    }
    else
    {
        return  [dataBase executeUpdate:@"update WIZ_META set META_VALUE= ? where META_NAME=? and META_KEY=?",value, lpszName, lpszKey];
    }
}
- (BOOL) setSyncVersion:(NSString*)type  version:(int64_t)ver
{
    NSString* verString = [NSString stringWithFormat:@"%lld", ver];
	return [self setMeta:KeyOfSyncVersion key:type value:verString];
}
- (int64_t) syncVersion:(NSString*)type
{
    NSString* verString = [self getMeta:KeyOfSyncVersion withKey:type];
    if (verString) {
        return [verString longLongValue];
    }
    return 0;
}
- (BOOL) setDocumentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDocument version:ver];
}
- (int64_t) documentVersion
{
    return [self syncVersion:KeyOfSyncVersionDocument];
}
- (BOOL) setAttachmentVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionAttachment version:ver];
}
- (int64_t) attachmentVersion
{
    return [self syncVersion:KeyOfSyncVersionAttachment];
}
- (BOOL) setTagVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionTag version:ver];
}
- (int64_t) tagVersion
{
    return [self syncVersion:KeyOfSyncVersionTag];
}
- (BOOL) setDeletedGUIDVersion:(int64_t)ver
{
    return [self setSyncVersion:KeyOfSyncVersionDeletedGuid version:ver];
}
- (int64_t) deletedGUIDVersion
{
    return [self syncVersion:KeyOfSyncVersionDeletedGuid];
}
//document
- (NSArray*) documentsArrayWithWhereFiled:(NSString*)where arguments:(NSArray*)args
{
    NSString* sql = [NSString stringWithFormat:@"select DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT from WIZ_DOCUMENT %@",where];
    FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
    NSMutableArray* array = [NSMutableArray array];
    while ([result next]) {
        WizDocument* doc = [[WizDocument alloc] init];
        doc.guid = [result stringForColumnIndex:0];
        doc.title = [result stringForColumnIndex:1];
        doc.location = [result stringForColumnIndex:2];
        doc.url = [result stringForColumnIndex:3];
        doc.tagGuids = [result stringForColumnIndex:4];
        doc.type = [result stringForColumnIndex:5];
        doc.fileType = [result stringForColumnIndex:6];
        doc.dateCreated = [[result stringForColumnIndex:7] dateFromSqlTimeString] ;
        doc.dateModified = [[result stringForColumnIndex:8] dateFromSqlTimeString];
        doc.dataMd5 = [result stringForColumnIndex:9];
        doc.attachmentCount = [result intForColumnIndex:10];
        doc.serverChanged = [result intForColumnIndex:11];
        doc.localChanged = [result intForColumnIndex:12];
        doc.gpsLatitude = [result doubleForColumnIndex:13];
        doc.gpsLongtitude = [result doubleForColumnIndex:14];
        doc.gpsAltitude = [result doubleForColumnIndex:15];
        doc.gpsDop = [result doubleForColumnIndex:16];
        doc.gpsAddress = [result stringForColumnIndex:17];
        doc.gpsCountry = [result stringForColumnIndex:18];
        doc.gpsLevel1 = [result stringForColumnIndex:19];
        doc.gpsLevel2 = [result stringForColumnIndex:20];
        doc.gpsLevel3 = [result stringForColumnIndex:21];
        doc.gpsDescription = [result stringForColumnIndex:22];
        doc.nReadCount = [result intForColumnIndex:23];
        doc.protected_ = [result intForColumnIndex:24];
        [array addObject:doc];
        [doc release];
    }
    return array;
}

- (WizDocument*) documentFromGUID:(NSString *)documentGUID
{
    if (nil == documentGUID) {
        return nil;
    }
    NSArray* array = [self documentsArrayWithWhereFiled:@"where DOCUMENT_GUID = ?" arguments:[NSArray arrayWithObject:documentGUID]];
    return [array lastObject];
}

- (NSArray*) recentDocuments
{
    return [self documentsArrayWithWhereFiled:@"order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:nil];
}

- (NSArray*) documentForUpload
{
    return [self documentsArrayWithWhereFiled:@"where LOCAL_CHANGED !=0 " arguments:nil];
}

- (NSArray*) documentsByKey:(NSString *)keywords
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",keywords,@"%"];
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TITLE like ? order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObject:sqlWhere]];
}

- (NSArray*) documentsByLocation:(NSString *)parentLocation
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION=? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:parentLocation]];
}

- (NSArray*) documentsByTag:(NSString *)tagGUID
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
    
    NSLog(@"%@",sqlWhere);
    
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_TAG_GUIDS like ? order by DOCUMENT_TITLE" arguments:[NSArray arrayWithObject:sqlWhere]];
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where DT_MODIFIED >= ? and SERVER_CHANGED=1 order by DT_MODIFIED" arguments:[NSArray arrayWithObjects:[date stringSql], nil]];
}

- (WizDocument*) documentForClearCacheNext
{
    return [[self documentsArrayWithWhereFiled:@"where  SERVER_CHANGED=0 and LOCAL_CHANGED=0 order by DT_MODIFIED desc limit 0,1" arguments:nil] lastObject];
}

- (BOOL) setDocumentLocalChanged:(NSString *)guid changed:(WizEditDocumentType)changed
{
    return [dataBase executeUpdate:@"update WIZ_DOCUMENT set LOCAL_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
}
- (BOOL) setDocumentServerChanged:(NSString *)guid changed:(BOOL)changed
{
    return [dataBase executeUpdate:@"update WIZ_DOCUMENT set LOCAL_CHANGED=? where DOCUMENT_GUID= ?",[NSNumber numberWithInt:changed],guid];
}

//
- (BOOL) updateDocument:(NSDictionary *)doc
{
    NSString*  guid = [doc valueForKey:DataTypeUpdateDocumentGUID];
	NSString*  title =[doc valueForKey:DataTypeUpdateDocumentTitle];
	NSString*  location = [doc valueForKey:DataTypeUpdateDocumentLocation];
	NSString*  dataMd5 = [doc valueForKey:DataTypeUpdateDocumentDataMd5];
	NSString*  url = [doc valueForKey:DataTypeUpdateDocumentUrl];
	NSString*  tagGUIDs = [doc valueForKey:DataTypeUpdateDocumentTagGuids];
	NSDate*    dateCreated = [doc valueForKey:DataTypeUpdateDocumentDateCreated];
	NSDate*   dateModified = [doc valueForKey:DataTypeUpdateDocumentDateModified];
	NSString* type = [doc valueForKey:DataTypeUpdateDocumentType];
	NSString* fileType = [doc valueForKey:DataTypeUpdateDocumentFileType];
    NSNumber* nAttachmentCount = [doc valueForKey:DataTypeUpdateDocumentAttachmentCount];
    NSNumber* localChanged = [doc valueForKey:DataTypeUpdateDocumentLocalchanged];
    NSNumber* nProtected = [doc valueForKey:DataTypeUpdateDocumentProtected];
    NSNumber* serverChanged = [doc valueForKey:DataTypeUpdateDocumentServerChanged];
    NSNumber* nReadCount = [doc valueForKey:DataTypeUpdateDocumentREADCOUNT];
    NSNumber* gpsLatitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LATITUDE];
    NSNumber* gpsLongtitue = [doc valueForKey:DataTypeUpdateDocumentGPS_LONGTITUDE];
    NSNumber* gpsAltitue    = [doc valueForKey:DataTypeUpdateDocumentGPS_ALTITUDE];
    NSNumber* gpsDop        = [doc valueForKey:DataTypeUpdateDocumentGPS_DOP];
    NSString* gpsAddress  = [doc valueForKey:DataTypeUpdateDocumentGPS_ADDRESS];
    NSString* gpsCountry = [doc valueForKey:DataTypeUpdateDocumentGPS_COUNTRY];
    NSString* gpsLevel1 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL1];
    NSString* gpsLevel2 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL2];
    NSString* gpsLevel3 = [doc valueForKey:DataTypeUpdateDocumentGPS_LEVEL3];
    NSString* gpsDescription  = [doc valueForKey:DataTypeUpdateDocumentGPS_DESCRIPTION];
    
    if (!dateCreated) {
        dateCreated = [NSDate date];
    }
    
    if (!dateModified) {
        dateModified = [NSDate date];
    }
    
    if ([self documentFromGUID:guid]) {
        return [dataBase executeUpdate:@"update WIZ_DOCUMENT set DOCUMENT_TITLE=?, DOCUMENT_LOCATION=?, DOCUMENT_URL=?, DOCUMENT_TAG_GUIDS=?, DOCUMENT_TYPE=?, DOCUMENT_FILE_TYPE=?, DT_CREATED=?, DT_MODIFIED=?, DOCUMENT_DATA_MD5=?, ATTACHMENT_COUNT=?, SERVER_CHANGED=?, LOCAL_CHANGED=?, GPS_LATITUDE=?, GPS_LONGTITUDE=?, GPS_ALTITUDE=?, GPS_DOP=?, GPS_ADDRESS=?, GPS_COUNTRY=?, GPS_LEVEL1=?, GPS_LEVEL2=?, GPS_LEVEL3=?, GPS_DESCRIPTION=?, READCOUNT=?, PROTECT=? where DOCUMENT_GUID= ?",title, location, url, tagGUIDs, type, fileType, [dateCreated stringSql], [dateModified stringSql],dataMd5, nAttachmentCount, serverChanged, localChanged, gpsLatitue, gpsLongtitue, gpsAltitue, gpsDop, gpsAddress, gpsCountry, gpsLevel1, gpsLevel2 , gpsLevel3, gpsDescription, nReadCount, nProtected,guid];
    }
    else
    {
        return [dataBase executeUpdate:@"insert into WIZ_DOCUMENT (DOCUMENT_GUID, DOCUMENT_TITLE, DOCUMENT_LOCATION, DOCUMENT_URL, DOCUMENT_TAG_GUIDS, DOCUMENT_TYPE, DOCUMENT_FILE_TYPE, DT_CREATED, DT_MODIFIED, DOCUMENT_DATA_MD5, ATTACHMENT_COUNT, SERVER_CHANGED, LOCAL_CHANGED,GPS_LATITUDE ,GPS_LONGTITUDE ,GPS_ALTITUDE ,GPS_DOP ,GPS_ADDRESS ,GPS_COUNTRY ,GPS_LEVEL1 ,GPS_LEVEL2 ,GPS_LEVEL3 ,GPS_DESCRIPTION ,READCOUNT ,PROTECT) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",guid, title, location, url, tagGUIDs, type, fileType, [dateCreated stringSql], [dateModified stringSql],dataMd5, nAttachmentCount, serverChanged, localChanged, gpsLatitue, gpsLongtitue, gpsAltitue, gpsDop, gpsAddress, gpsCountry, gpsLevel1, gpsLevel2 , gpsLevel3, gpsDescription, nReadCount, nProtected];
    }
}

- (BOOL) updateDocuments:(NSArray *)documents
{
    for (NSDictionary* doc in documents) {
        if (![self updateDocument:doc]) {
            return NO;
        }
    }
    return YES;
}

// attachment
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
    if (nil == dateModified) {
        dateModified = [NSDate date];
    }
    if (nil == localChanged) {
        localChanged = [NSNumber numberWithInt:0];
    }
    if (nil == serVerChanged) {
        serVerChanged = [NSNumber numberWithInt:1];
    }
    if ([self attachmentFromGUID:guid]) {
        
       return  [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set DOCUMENT_GUID=?, ATTACHMENT_NAME=?, ATTACHMENT_DATA_MD5=?, ATTACHMENT_DESCRIPTION=?, DT_MODIFIED=?, SERVER_CHANGED=?, LOCAL_CHANGED=? where ATTACHMENT_GUID=?"
           withArgumentsInArray:[NSArray arrayWithObjects:documentGuid, title, dataMd5, description, [dateModified stringSql] , serVerChanged, localChanged,guid, nil]];
    }
    else
    {
        return [dataBase executeUpdate:@"insert into WIZ_DOCUMENT_ATTACHMENT (ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED) values(?, ?, ?, ?, ?, ?, ?, ?)"
                  withArgumentsInArray:[NSArray arrayWithObjects:guid,documentGuid, title, dataMd5, description, [dateModified stringSql], serVerChanged, localChanged, nil]];
    }
}

- (BOOL) updateAttachments:(NSArray *)attachments
{
    for (NSDictionary* attach in attachments)
    {
        if (![self updateAttachment:attach]) {
            return NO;
        }
    }
    return YES;
}

- (NSArray*) attachmentsWithWhereFiled:(NSString*)where args:(NSArray*)args
{
    NSMutableArray* attachments = [NSMutableArray array];
    NSString* sql = [NSString stringWithFormat:@"select ATTACHMENT_GUID ,DOCUMENT_GUID, ATTACHMENT_NAME,ATTACHMENT_DATA_MD5,ATTACHMENT_DESCRIPTION,DT_MODIFIED,SERVER_CHANGED,LOCAL_CHANGED from WIZ_DOCUMENT_ATTACHMENT %@",where];
    FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
    while ([result next]) {
        WizAttachment* attachment = [[WizAttachment alloc] init];
        attachment.guid = [result stringForColumnIndex:0];
        attachment.documentGuid = [result stringForColumnIndex:1];
        attachment.title = [result stringForColumnIndex:2];
        attachment.dataMd5 = [result stringForColumnIndex:3];
        attachment.description = [result stringForColumnIndex:4];
        attachment.dateModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
        attachment.serverChanged = [result intForColumnIndex:6];
        attachment.localChanged = [result intForColumnIndex:7];
        [attachments addObject:attachment];
        [attachment release];
    }
    return attachments;
}

- (WizAttachment*) attachmentFromGUID:(NSString *)guid
{
    return [[self attachmentsWithWhereFiled:@"where ATTACHMENT_GUID=?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (NSArray*) attachmentsByDocumentGUID:(NSString *)documentGUID
{
    return [self attachmentsWithWhereFiled:@"where DOCUMENT_GUID=?" args:[NSArray arrayWithObject:documentGUID]];
}

- (BOOL) setAttachmentLocalChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    return [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set LOCAL_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
}

- (BOOL) setAttachmentServerChanged:(NSString *)attchmentGUID changed:(BOOL)changed
{
    return [dataBase executeUpdate:@"update WIZ_DOCUMENT_ATTACHMENT set SERVER_CHANGED=? where ATTACHMENT_GUID=?",[NSNumber numberWithBool:changed], attchmentGUID];
}

//tag

- (NSArray*) tagsArrayWithWhereField:(NSString*)where   args:(NSArray*)args
{
    NSString* sql = [NSString stringWithFormat:@"select TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION  ,LOCALCHANGED, DT_MODIFIED from WIZ_TAG %@",where];
    FMResultSet* result = [dataBase executeQuery:sql withArgumentsInArray:args];
    NSMutableArray* array = [NSMutableArray array];
    while ([result next]) {
        WizTag* tag = [[WizTag alloc] init];
        tag.guid = [result stringForColumnIndex:0];
        tag.parentGUID = [result stringForColumnIndex:1];
        tag.title = [result stringForColumnIndex:2];
        tag.description = [result stringForColumnIndex:3];
        tag.localChanged = [result intForColumnIndex:4];
        tag.dateInfoModified = [[result stringForColumnIndex:5] dateFromSqlTimeString];
        [array addObject:tag];
        [tag release];
    }
    return array;
}

- (WizTag*) tagFromGuid:(NSString *)guid
{
    return [[self tagsArrayWithWhereField:@"where TAG_GUID = ?" args:[NSArray arrayWithObject:guid]] lastObject];
}

- (BOOL) updateTag:(NSDictionary *)tag
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
    if (nil == guid) {
        return NO;
    }
    if ([self tagFromGuid:guid]) {
        return [dataBase executeUpdate:@"update WIZ_TAG set TAG_NAME=?, TAG_DESCRIPTION=?, TAG_PARENT_GUID=?, LOCALCHANGED=?, DT_MODIFIED=? where TAG_GUID=?",name, description,parentGuid,localChanged,[dtInfoModifed stringSql], guid];
    }
    else
    {
       return [dataBase executeUpdate:@"insert into WIZ_TAG (TAG_GUID, TAG_PARENT_GUID, TAG_NAME, TAG_DESCRIPTION ,LOCALCHANGED, DT_MODIFIED ) values (?, ?, ?, ?, ?, ?)",guid,parentGuid,name,description,localChanged,[dtInfoModifed stringSql]];
    }
}

- (void) genTagNamePath:(WizTag*)parentTag rest:(NSMutableArray*)rest
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parenGUID == %@",parentTag.guid];
    NSPredicate* rpredicate = [NSPredicate predicateWithFormat:@"parenGUID == %@",parentTag.guid];
    NSArray* section = [rest filteredArrayUsingPredicate:predicate];
    [rest filterUsingPredicate:rpredicate];
    if ([rest count]) {
        for (WizTag* each in section) {
            each.namePath = [parentTag.namePath stringByAppendingFormat:@"%@/",each.title];
            [self genTagNamePath:each rest:rest];
            if (![rest count]) {
                break;
            }
        }
    }
}

- (void) getTagNamePath:(NSMutableArray*)array
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentGUID != nil"];
    NSPredicate* rPredicate = [NSPredicate predicateWithFormat:@"parentGUID == nil"];
    NSArray* root = [array filteredArrayUsingPredicate:rPredicate];
    NSLog(@"root %@",root);
    for (WizTag* tag in root) {
        tag.namePath = @"/";
    }
    
    NSMutableArray* rest =[NSMutableArray arrayWithArray:[array filteredArrayUsingPredicate:predicate]];
    
    if (![rest count]) {
        return;
    }
    for (WizTag* each in root) {
        each.namePath = [NSString stringWithFormat:@"/%@/",each.title];
        [self genTagNamePath:each rest:rest];
    }
}
- (NSArray*) allTagsForTree
{
    NSMutableArray* allTags =[NSMutableArray arrayWithArray:[self tagsArrayWithWhereField:@"" args:nil]];
    [self getTagNamePath:allTags];
    for (WizTag* each in allTags) {
        NSLog(@"%@",each.namePath);
    }
    return nil;
}

- (NSArray*) tagsForUpload
{
    return [self tagsArrayWithWhereField:@"" args:nil];
}

- (NSString*) tagAbstractString:(NSString *)guid
{
    return nil;
}

@end
