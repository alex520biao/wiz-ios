//
//  WizFileManger.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFileManager.h"
#import "WizGlobalData.h"
#import "ZipArchive.h"
#import "WizAccountManager.h"

#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"
#define EditTempDirectory   @"EditTempDirectory"

@implementation WizFileManager
//singleton
static WizFileManager* shareManager = nil;
+ (id) shareManager;
{
    @synchronized(shareManager)
    {
        if (shareManager == nil) {
            shareManager = [[super allocWithZone:NULL] init];
        }
        return shareManager;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareManager] retain];
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

//


+(NSString*) documentsPath
{
    static NSString* documentDirectory= nil;
    if (nil == documentDirectory) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentDirectory = [[paths objectAtIndex:0] retain];
    }
	return documentDirectory;
}

-(BOOL) ensurePathExists:(NSString*)path
{
	BOOL b = YES;
    if (![self fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
			[WizGlobals reportError:err];
		}
	}
	return b;
}
- (BOOL) ensureFileExists:(NSString*)path
{
    if (![self fileExistsAtPath:path]) {
        return [self createFileAtPath:path contents:nil attributes:nil];
    }
    return YES;
}
- (NSString*) accountPathFor:(NSString*)accountUserId
{
    NSString* documentPath = [WizFileManager documentsPath];
    NSString* accountPath = [documentPath stringByAppendingPathComponent:accountUserId];
    [self ensurePathExists:accountPath];
    return accountPath;
}
- (NSString*) accountPath
{
	return [self accountPathFor:[[WizAccountManager defaultManager] activeAccountUserId]];
}

- (NSString*) dataBasePath:(NSString*)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:@"index.db"];
}

- (NSString*) abstractDataBatabasePath:(NSString*)accountUserId
{
    NSString* accountPath = [self accountPathFor:accountUserId];
    return [accountPath stringByAppendingPathComponent:@"tempAbs.db"];
}

- (NSString*) objectFilePath:(NSString*)objectGuid
{
	NSString* accountPath = [self accountPath];
	NSString* subName = [NSString stringWithFormat:@"%@", objectGuid];
	NSString* path = [accountPath stringByAppendingPathComponent:subName];
    [self ensurePathExists:path];
	return path;
}
- (NSString*) documentIndexFilesPath:(NSString*)documentGUID
{
    NSString* documentFilePath = [self accountPath];
    NSString* indexFilesPath = [[documentFilePath stringByAppendingPathComponent:documentGUID] stringByAppendingPathComponent:@"index_files"];
    [self ensurePathExists:indexFilesPath];
    return indexFilesPath;
}
- (NSString*) documentFile:(NSString*)documentGUID fileName:(NSString*)fileName
{
    NSString* path = [self objectFilePath:documentGUID];
	NSString* filename = [path stringByAppendingPathComponent:fileName];
	return filename;
}
- (NSString*) documentIndexFile:(NSString*)documentGUID
{
	return [self documentFile:documentGUID fileName:@"index.html"];
}
- (NSString*) documentMobileFile:(NSString*)documentGuid
{
    return [self documentFile:documentGuid fileName:@"wiz_mobile.html"];
}
- (NSString*) documentAbstractFile:(NSString*)documentGUID
{
    return [self documentFile:documentGUID fileName:@"wiz_abstract.html"];
}
- (NSString*) documentFullFile:(NSString*)documentGUID
{
    return [self documentFile:documentGUID fileName:@"wiz_full.html"];
}
- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid
{
    NSString* objectPath = [self objectFilePath:objGuid];
    return [objectPath stringByAppendingPathComponent:@"temp.zip"];
}
//

-(BOOL) deleteFile:(NSString*)fileName
{
	NSError* err = nil;
	BOOL b = [self removeItemAtPath:fileName error:&err];
	if (!b && err)
	{
		[WizGlobals reportError:err];
	}
	//
	return b;
}

- (BOOL) updateObjectDataByPath:(NSString*)objectZipFilePath objectGuid:(NSString*)objectGuid
{
    NSString* objectPath = [self objectFilePath:objectGuid];
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:objectZipFilePath];
    BOOL zipResult = [zip UnzipFileTo:objectPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
    if (!zipResult) {
        if ([WizGlobals checkFileIsEncry:objectZipFilePath]) {
            return YES;
        }
        else {
            [self deleteFile:objectZipFilePath];
            return NO;
        }
    }
    else {
        [self deleteFile:objectZipFilePath];
        return YES;
    }
    return YES;
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
            if(![zip addFileToZip:path newname:[NSString stringWithFormat:@"%@/%@",name,each]]) 
            {
                return NO;
            }
        }
    }
    return YES;
}
-(NSString*) createZipByGuid:(NSString*)objectGUID 
{
    NSString* objectPath = [self objectFilePath:objectGUID];
    NSArray* selectedFile = [self contentsOfDirectoryAtPath:objectPath error:nil];
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

- (BOOL) removeObjectPath:(NSString*)guid
{
    NSString* objectPath = [self objectFilePath:guid];
    return [self removeItemAtPath:objectPath error:nil];
}
//editDocumentAndAttachment
- (NSString*) attachmentTempDirectory
{
    return [self objectFilePath:ATTACHMENTTEMPFLITER];
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    if ([self fileExistsAtPath:filePath]){
        return [[self attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
- (long long) folderTotalSizeAtPath:(NSString*) folderPath{
    if (![self fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[self subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        if ([fileName isEqualToString:@"index.db"]) {
            continue;
        }
        if ([fileName isEqualToString:@"tempAbs.db"]) {
            continue;
        }
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
        }
    return folderSize;
}
- (NSString*) getAttachmentSourceFileName
{
     NSString* objectPath = [[self editingTempDirectory] stringByAppendingPathComponent:@"index_files"];
    [[WizFileManager shareManager] ensurePathExists:objectPath];
    return [objectPath stringByAppendingPathComponent:[WizGlobals genGUID]];
}
//- (NSString*)getAttachmentSourceFileName
//{
//    NSString* ret = @"";
//    NSString* dateString = [[NSDate date] stringSql];
//    NSString* objectPath = [self attachmentTempDirectory];
//    for (int i = 0;;i++) {
//        NSString* dateAppend = [NSString stringWithString:dateString];
//        if (i != 0) {
//            dateAppend = [dateString stringByAppendingFormat:@"%d",i];
//        }
//        ret = [objectPath stringByAppendingPathComponent:dateAppend];
//        
//        NSArray* fileExist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:nil];
//        BOOL fileNotExist = YES;
//        for (NSString* each in fileExist) {
//            NSArray* nameArray = [each componentsSeparatedByString:@"."];
//            for (NSString* ea in nameArray) {
//                if ([ea isEqualToString:dateAppend]) {
//                    fileNotExist = NO;
//                }
//            }
//        }
//        if (fileNotExist) {
//            break;
//        }
//        else {
//            continue;
//        }
//    }
//    ret = [ret stringByReplacingOccurrencesOfString:@":" withString:@"-"];
//    return ret;
//}
- (NSInteger) activeAccountFolderSize
{
    NSString* path = [self accountPath];
    return [self folderTotalSizeAtPath:path];
}
- (NSString*) searchHistoryFilePath
{
    return [self documentFile:@"SearchHistoryDir" fileName:@"history.dat"];
}
- (NSString*) editingTempDirectory
{
    return [self objectFilePath:EditTempDirectory];
}


@end
