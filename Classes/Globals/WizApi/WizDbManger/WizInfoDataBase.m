//
//  WizInfoDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-14.
//
//

#import "WizInfoDataBase.h"
#import "WizDocument.h"
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
    return [self documentsArrayWithWhereFiled:@"DOCUMENT_TITLE like ? order by max(DT_CREATED, DT_MODIFIED) desc limit 0, 100" arguments:[NSArray arrayWithObject:keywords]];
}

- (NSArray*) documentsByLocation:(NSString *)parentLocation
{
    return [self documentsArrayWithWhereFiled:@"where DOCUMENT_LOCATION=? order by max(DT_CREATED, DT_MODIFIED) desc" arguments:[NSArray arrayWithObject:parentLocation]];
}

- (NSArray*) documentsByTag:(NSString *)tagGUID
{
    NSString* sqlWhere = [NSString stringWithFormat:@"%@%@%@",@"%",tagGUID,@"%"];
    return [self documentsArrayWithWhereFiled:@"DOCUMENT_TAG_GUIDS like ? order by DOCUMENT_TITLE" arguments:[NSArray arrayWithObject:sqlWhere]];
}
- (NSArray*) documentsForCache:(NSInteger)duration
{
    NSDate* date = [NSDate dateWithDaysBeforeNow:duration];
    return [self documentsArrayWithWhereFiled:@"where DT_MODIFIED >= ? and SERVER_CHANGED=1 order by DT_MODIFIED" arguments:[NSArray arrayWithObjects:[date stringSql], nil]];
}

- (WizDocument*) documentForClearCacheNext
{
    return nil;
}

- (BOOL) setDocumentLocalChanged:(NSString *)guid changed:(id)changed
{
    return NO;
}

- (BOOL) setDocumentServerChanged:(NSString *)guid changed:(BOOL)changed
{
    return NO;
}

//
- (BOOL) updateDocument:(NSDictionary *)doc
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


@end
