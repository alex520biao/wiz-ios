//
//  WizFileManager.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface NSFileManager(wizFileManager)
-(NSString*) createZipByGuid:(NSString*)objectGUID;
- (NSInteger) fileLengthAtPath:(NSString*)path;
@end
@interface WizFileManager : NSFileManager
+ (NSString*) accountDbFilePath;
+ (NSString*) accountTempDbFilePath;
+ (NSString*) wizAppPath;
+ (NSString*) objectDirectoryPath:(NSString*)guid;
+ (NSString*) downloadTempFilePath:(NSString*)guid;
+ (BOOL) updateObjectLocalData:(NSString*)guid;
+ (void) ensureFileIsExist:(NSString*)path;
+ (NSString*) zipFileForUploadObject:(NSString*)guid;
+(BOOL) deleteFile:(NSString*)fileName;
+ (BOOL) deleteDownloadTempFile:(NSString*)guid;
@end
