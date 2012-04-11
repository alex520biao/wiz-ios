//
//  WizFileManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFileManager.h"
#import "WizAccountManager.h"
#import "ZipArchive.h"
@interface NSFileManager(wizFile)
-(NSString*) createZipByGuid:(NSString*)objectGUID;
- (NSInteger) fileLengthAtPath:(NSString*)path;
- (BOOL) unzipFileToPath:(NSString*)sourceFilePath   to:(NSString*)targetPath;
- (NSString*) documentFilePath:(NSString*)documentGUID    name:(NSString*)name;
@end

@interface WizFileManager()
+ (NSString*) wizAppPath;
+(BOOL) ensurePathExists:(NSString*)path;
@end
@implementation NSFileManager(wizFileManager)
- (NSString*) documentFilePath:(NSString*)documentGUID    name:(NSString*)name
{
    NSString* documentDir = [WizFileManager objectDirectoryPath:documentGUID];
    [WizFileManager ensurePathExists:documentDir];
    return [documentDir stringByAppendingPathComponent:name];
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
    NSString* objectPath = [WizFileManager objectDirectoryPath:objectGUID];
    NSArray* selectedFile = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectPath error:nil];
    NSString* zipPath = [objectPath stringByAppendingPathComponent:@"temppp.ziw"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    }
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
- (NSInteger) fileLengthAtPath:(NSString*)path
{
    NSError* error=nil;
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    if (error == nil) {
        return [fileAttributes fileSize];
    }
    else {
        return NSNotFound;
    }
}
- (BOOL) unzipFileToPath:(NSString *)sourceFilePath to:(NSString *)targetPath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:sourceFilePath]) {
        return NO;
    }
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:sourceFilePath];
    BOOL zipResult = [zip UnzipFileTo:targetPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
    return zipResult;
}
@end
@implementation WizFileManager
+(BOOL) ensurePathExists:(NSString*)path
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	BOOL b = YES;
    if (![fileManager fileExistsAtPath:path])
	{
		NSError* err = nil;
		b = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
		if (!b)
		{
			[WizGlobals reportError:err];
		}
	}
	//
	[fileManager release];
	//
	return b;
}
+ (NSString*) wizAppPath
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}
+ (NSString*) accountPath
{
    NSString* activeUserId = [WizAccountManager activeAccountUserId];
    NSString* userPath = [[WizFileManager wizAppPath] stringByAppendingPathComponent:activeUserId];
    [WizFileManager ensurePathExists:userPath];
    return userPath;
}
+ (NSString*) accountDbFilePath
{
	NSString* accountPath = [WizFileManager accountPath];
	return [accountPath stringByAppendingPathComponent:@"index.db"];
}
+ (NSString*) accountTempDbFilePath
{
    NSString* accountPath = [WizFileManager accountPath];
    return [accountPath stringByAppendingPathComponent:@"temp.db"];
}
+ (NSString*) objectDirectoryPath:(NSString*)guid
{
    NSString* accountPath = [WizFileManager accountPath];
    NSString* objectPath =  [accountPath stringByAppendingPathComponent:guid];
    [WizFileManager ensurePathExists:objectPath];
    return objectPath;
}
+ (NSString*) downloadTempFilePath:(NSString*)guid
{
    NSString* objPath = [WizFileManager objectDirectoryPath:guid];
    NSString* tempFilePath =  [objPath stringByAppendingPathComponent:@"temp.zip"];
    return tempFilePath;
}

+ (BOOL) updateObjectLocalData:(NSString*)guid
{
    NSString* downloadTempFilePath = [WizFileManager downloadTempFilePath:guid];
    NSString* objectDirectoryPath = [WizFileManager objectDirectoryPath:guid];
    return [[WizFileManager defaultManager] unzipFileToPath:downloadTempFilePath to:objectDirectoryPath];
}
+ (void) ensureFileIsExist:(NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil])
        {
        }
    }
}
+(BOOL) deleteFile:(NSString*)fileName
{
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSError* err = nil;
	BOOL b = [fileManager removeItemAtPath:fileName error:&err];
	//
	[fileManager release];
	//
	if (!b && err)
	{
		[WizGlobals reportError:err];
	}
	//
	return b;
}

+ (BOOL) deleteDownloadTempFile:(NSString*)guid
{
    return [WizFileManager deleteFile:[WizFileManager downloadTempFilePath:guid]];
}
+ (NSString*) zipFileForUploadObject:(NSString*)guid
{
    return [[WizFileManager defaultManager] createZipByGuid:guid];
}
+ (NSString*) documentFile:(NSString*)documentGUID
{
    return [[NSFileManager defaultManager] documentFilePath:documentGUID name:@"index.html"];
}
+ (NSString*) documentMobileViewFile:(NSString*)documentGUID
{
    return [[NSFileManager defaultManager] documentFilePath:documentGUID name:@"wiz_mobile.html"];
}
+ (NSString*) documentAbstractFile:(NSString*)documentGUID
{
    return [[NSFileManager defaultManager] documentFilePath:documentGUID name:@"wiz_abstract.html"];
}
+ (NSString*) documentFullFile:(NSString*)documentGUID
{
    return [[NSFileManager defaultManager] documentFilePath:documentGUID name:@"wiz_full.html"];
}
@end
