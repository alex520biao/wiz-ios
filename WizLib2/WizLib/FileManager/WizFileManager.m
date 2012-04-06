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
@interface NSFileManager(wizFileManager)
-(NSString*) createZipByGuid:(NSString*)objectGUID;
- (NSInteger) fileLengthAtPath:(NSString*)path
@end

@interface WizFileManager()
+ (NSString*) wizAppPath;
+(BOOL) ensurePathExists:(NSString*)path;
- (NSInteger) fileLengthAtPath:(NSString*)path;
@end
@implementation NSFileManager(wizFileManager)
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]) {
        NSError* error= nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:&error]) {
            [WizGlobals reportError:error];
        }
    }
    [WizFileManager ensureFileIsExist:tempFilePath];
    return tempFilePath;
}

+ (BOOL) updateObjectLocalData:(NSString*)guid
{
    NSString* downloadTempFilePath = [WizFileManager downloadTempFilePath:guid];
    NSString* objectDirectoryPath = [WizFileManager objectDirectoryPath:guid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:downloadTempFilePath]) {
        return NO;
    }
    ZipArchive* zip = [[ZipArchive alloc] init];
    [zip UnzipOpenFile:downloadTempFilePath];
    BOOL zipResult = [zip UnzipFileTo:objectDirectoryPath overWrite:YES];
    [zip UnzipCloseFile];
    [zip release];
    return zipResult;
}
+ (void) ensureFileIsExist:(NSString*)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil])
        {
        
        }
    }
}

+ (NSString*) zipFileForUploadObject:(NSString*)guid
{
    return [[WizFileManager defaultManager] createZipByGuid:guid];
}
@end
