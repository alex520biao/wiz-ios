//
//  WizTempDataBase.m
//  Wiz
//
//  Created by wiz on 12-6-17.
//
//

#import "WizTempDataBase.h"
#import "WizFileManager.h"
#import "WizAbstract.h"
#import "WizAccountManager.h"
#import "WizAbstractCache.h"
@implementation WizTempDataBase

- (BOOL) isAbstractExist:(NSString*)documentGuid
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select * from WIZ_ABSTRACT where ABSTRACT_GUID is ?",documentGuid];
        if ([result next]) {
            ret =  YES;
        }
        else
        {
            ret = NO;
        }
        [result close];

    }];
    return ret;
}

- (BOOL) imageIsAD:(int)imageArea
{
    if (imageArea <= 32* 32) {
        return YES;
    }
    if (imageArea == 468*60) {
        return YES;
    }
    if (imageArea == 170*60) {
        return YES;
    }
    if (imageArea == 234*60) {
        return YES;
    }
    if (imageArea == 88*31) {
        return YES;
    }
    if (imageArea == 120*60) {
        return YES;
    }
    if (imageArea == 120*90) {
        return YES;
    }
    if (imageArea == 120*120) {
        return YES;
    }
    if (imageArea == 360*300) {
        return YES;
    }
    if (imageArea == 392*72) {
        return YES;
    }
    if (imageArea == 125*125) {
        return YES;
    }
    if (imageArea == 770*100) {
        return YES;
    }
    if (imageArea == 80*80) {
        return YES;
    }
    if (imageArea == 750*550) {
        return YES;
    }
    if (imageArea == 130* 200) {
        return YES;
    }
    return NO;
}

- (void) extractSummary:(NSString *)documentGUID  kbGuid:(NSString*)kbguid
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self extractSummaryCall:(NSString *)documentGUID  kbGuid:(NSString*)kbguid];
    [pool drain];
}
- (void) extractSummaryCall:(NSString *)documentGUID  kbGuid:(NSString*)kbguid
{
 
    BOOL WizDeviceIsPad = [WizGlobals WizDeviceIsPad];
    NSString* sourceFilePath = [[WizFileManager shareManager] documentIndexFile:documentGUID];

    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return;
    }
    NSString* abstractText = nil;
    if ([WizGlobals fileLength:sourceFilePath] < 1024*1024) {

        NSString* sourceStr = [NSString stringWithContentsOfFile:sourceFilePath usedEncoding:nil error:nil];
        if (sourceStr.length > 1024*50) {
            sourceStr = [sourceStr substringToIndex:1024*50];
        }
        NSString* destStr = [sourceStr htmlToText:140];
        destStr = [destStr stringReplaceUseRegular:@"&(.*?);" withString:@""];
        
        if (destStr == nil || [destStr isEqualToString:@""]) {
            destStr = @"";
        }
        if (WizDeviceIsPad) {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
        else
        {
            NSRange range = NSMakeRange(0, 70);
            if (destStr.length <= 70) {
                range = NSMakeRange(0, destStr.length);
            }
            abstractText = [destStr substringWithRange:range];
        }
    }
    else
    {
        NSLog(@"the file name is %@",sourceFilePath);
    }


      NSString* sourceImagePath = [[WizFileManager shareManager] documentIndexFilesPath:documentGUID];
    NSArray* imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourceImagePath  error:nil];
    
    NSString* maxImageFilePath = nil;
    int maxImageSize = 0;
    for (NSString* each in imageFiles) {
        NSArray* typeArry = [each componentsSeparatedByString:@"."];
        if ([WizGlobals checkAttachmentTypeIsImage:[typeArry lastObject]]) {
            NSString* sourceImageFilePath = [sourceImagePath stringByAppendingPathComponent:each];
            int fileSize = [WizGlobals fileLength:sourceFilePath];
            if (fileSize > maxImageSize && fileSize < 1024*1024) {
                maxImageFilePath = sourceImageFilePath;
            }
        }
    }
    UIImage* compassImage = nil;
    
    //
    if (nil != maxImageFilePath) {
        float compassWidth=140;
        float compassHeight = 140;
        if (WizDeviceIsPad) {
            compassWidth = 350;
            compassHeight = 170;
        }
        UIImage* image = [[UIImage alloc] initWithContentsOfFile:maxImageFilePath];
        
        if (nil != image)
        {
            if (image.size.height >= compassHeight && image.size.width >= compassWidth) {
                 compassImage = [image wizCompressedImageWidth:compassWidth height:compassHeight];
            }
            [image release];
        }
    }

    
    if (kbguid == nil || [kbguid isBlock]) {
        kbguid = [[WizAccountManager defaultManager] activeAccountUserId];
    }
    NSData* imageData = nil;
    if (nil != compassImage) {
        imageData = [compassImage compressedData];
    }
    [self updateAbstract:abstractText imageData:imageData guid:documentGUID type:@"" kbguid:kbguid];
}

- (BOOL) updateAbstract:(NSString*)text imageData:(NSData*)imageData guid:(NSString*)guid type:(NSString*)type kbguid:(NSString*)kbguid
{
    __block BOOL ret;
    if ([self isAbstractExist:guid]) {
        [self.queue inDatabase:^(FMDatabase *db) {
            ret =[db executeUpdate:@"update WIZ_ABSTRACT set ABSTRACT_TYPE=?, ABSTRACT_TEXT=?, ABSTRACT_IMAGE=?, GROUP_KBGUID=?,DT_MODIFIED=? where ABSTRACT_GUID=?", type, text, imageData,kbguid, [[NSDate date] stringSql], guid];
        }];
    }
    else
    {
        [self.queue inDatabase:^(FMDatabase *db) {
            ret =[db executeUpdate:@"insert into WIZ_ABSTRACT (ABSTRACT_GUID ,ABSTRACT_TYPE, ABSTRACT_TEXT, ABSTRACT_IMAGE, GROUP_KBGUID,DT_MODIFIED) values(?, ?, ?, ?, ?, ?)",guid,type,text,imageData,kbguid,[[NSDate date] stringSql]];
        }];
    }
    return ret;
}

- (WizAbstract*) abstractForGroup:(NSString *)kbguid
{
    __block WizAbstract* abs = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select  ABSTRACT_TEXT, ABSTRACT_IMAGE from WIZ_ABSTRACT where GROUP_KBGUID = ? and  length(ABSTRACT_IMAGE) > 0 order by DT_MODIFIED desc limit 0,1",kbguid];
        if ([result next]) {
            WizAbstract* local = [[WizAbstract alloc] init];
            local.text = [result stringForColumnIndex:0];
            local.image = [UIImage imageWithData:[result dataForColumnIndex:1]];
            abs = [local autorelease];
        }
        [result close];
    }];
    return abs;
}
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID
{
    __block WizAbstract* abs = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* result = [db executeQuery:@"select ABSTRACT_TEXT, ABSTRACT_IMAGE from WIZ_ABSTRACT where ABSTRACT_GUID=?",documentGUID];
        if ([result next]) {
             WizAbstract* local = [[WizAbstract alloc] init];
            local.text = [result stringForColumnIndex:0];
            local.image = [UIImage imageWithData:[result dataForColumnIndex:1]];
            abs = [local autorelease];
        }
        [result close];
    }];
    return abs;
}
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID
{
    __block BOOL ret;
    [self.queue inDatabase:^(FMDatabase *db) {
       ret = [db executeUpdate:@"delete from WIZ_ABSTRACT where ABSTRACT_GUID=?",documentGUID];
    }];
    [[WizAbstractCache shareCache] clearCacheForDocument:documentGUID];
    return ret;
}
- (BOOL) deleteAbstractsByAccountUserId:(NSString *)accountUserID
{
    __block BOOL isSucceess;
    [self.queue inDatabase:^(FMDatabase *db) {
        isSucceess = [db executeUpdate:@"delete from WIZ_ABSTRACT where GROUP_KBGUID=?",accountUserID];
    }];
    return isSucceess;
}
- (BOOL) clearCache
{
    return YES;
}
- (WizSearch*) searchDataFromDb:(NSString*)keywords
{
    __block WizSearch* search = nil;
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* searchData = [db executeQuery:@"select SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE,SEARCH_KEYWORDS, SEARCH_ISLOCAL from Wiz_Search where SEARCH_KEYWORDS = ?",keywords];
        if ([searchData next]) {
            WizSearch* search_ = [[WizSearch alloc] init];
            search_.nNotesNumber = [searchData intForColumnIndex:0];
            search_.searchDate = [searchData dateForColumnIndex:1];
            search_.keyWords = [searchData stringForColumnIndex:2];
            search_.isSearchLocal = [searchData boolForColumnIndex:3];
            search = [search_ autorelease];
        }
     [searchData close];
    }];
    return search;
}
- (BOOL) updateWizSearch:(NSString *)keywords notesNumber:(NSInteger)notesNumber isSerchLocal:(BOOL)isSearchLocal
{
    __block BOOL isSuccess;
    if ([self searchDataFromDb:keywords]) {
        [self.queue inDatabase:^(FMDatabase *db) {
            isSuccess = [db executeUpdate:@"update Wiz_Search set SEARCH_NOTE_COUNT=?, SEARCH_EDIT_DATE=?, SEARCH_ISLOCAL=? where SEARCH_KEYWORDS = ?",[NSNumber numberWithInteger:notesNumber], [[NSDate date] stringSql], [NSNumber numberWithBool:isSearchLocal], keywords];
        }];
    }
    else
    {
        [self.queue inDatabase:^(FMDatabase *db) {
            isSuccess = [db executeUpdate:@"insert into Wiz_Search (SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE, SEARCH_ISLOCAL,SEARCH_KEYWORDS) values(?,?,?,?)",[NSNumber numberWithInteger:notesNumber], [[NSDate date] stringSql], [NSNumber numberWithBool:isSearchLocal], keywords];
        }];
    }
    return isSuccess;
}

- (BOOL) deleteWizSearch:(NSString *)keywords
{
    __block BOOL isSuccess;
    [self.queue inDatabase:^(FMDatabase *db) {
        isSuccess = [db executeUpdate:@"delete from Wiz_Search where SEARCH_KEYWORDS=?",keywords];
    }];
    return isSuccess;
}

- (NSArray*) allWizSearchs
{
    __block NSMutableArray* allSearchs = [NSMutableArray array];
    [self.queue inDatabase:^(FMDatabase *db) {
        FMResultSet* searchDatas = [db executeQuery:@"select SEARCH_NOTE_COUNT, SEARCH_EDIT_DATE,SEARCH_KEYWORDS, SEARCH_ISLOCAL from Wiz_Search"];
        while ([searchDatas next]) {
            WizSearch* search_ = [[WizSearch alloc] init];
            search_.nNotesNumber = [searchDatas intForColumnIndex:0];
            search_.searchDate = [[searchDatas stringForColumnIndex:1] dateFromSqlTimeString];
            search_.keyWords = [searchDatas stringForColumnIndex:2];
            search_.isSearchLocal = [searchDatas boolForColumnIndex:3];
            [allSearchs addObject:search_];
            [search_ release];
        }
    }];
    return allSearchs;
}
@end
