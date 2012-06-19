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

- (void) extractSummary:(NSString *)documentGUID  kbGuid:(NSString*)kbguid
{
    BOOL WizDeviceIsPad = [WizGlobals WizDeviceIsPad];
    NSString* sourceFilePath = [[WizFileManager shareManager] documentIndexFile:documentGUID];
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return;
    }
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
    
    [self updateAbstract:abstractText imageData:[compassImage compressedData] guid:documentGUID type:@"" kbguid:kbguid];
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
    return ret;
}
- (BOOL) clearCache
{
    return YES;
}
@end
