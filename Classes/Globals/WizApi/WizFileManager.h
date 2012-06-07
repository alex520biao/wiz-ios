//
//  WizFileManger.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizFileManager : NSFileManager
+(NSString*) documentsPath;
+ (id) shareManager;
- (NSString*) accountPath;
- (NSString*) dbPath;
- (NSString*) tempDbPath;
- (NSString*) objectFilePath:(NSString*)objectGuid;
- (NSString*) documentIndexFile:(NSString*)documentGUID;
- (NSString*) documentMobileFile:(NSString*)documentGuid;
- (NSString*) documentAbstractFile:(NSString*)documentGUID;
- (NSString*) documentFullFile:(NSString*)documentGUID;
- (NSString*) documentIndexFilesPath:(NSString*)documentGUID;
- (BOOL) removeObjectPath:(NSString*)guid;
- (long long) folderTotalSizeAtPath:(NSString*) folderPath;
//
- (NSString*) downloadObjectTempFilePath:(NSString*)objGuid;
- (BOOL) updateObjectDataByPath:(NSString*)objectZipFilePath objectGuid:(NSString*)objectGuid;
//
-(NSString*) createZipByGuid:(NSString*)objectGUID;
-(BOOL) deleteFile:(NSString*)fileName;
- (NSString*) attachmentTempDirectory;
- (NSString*)getAttachmentSourceFileName;
//
- (NSString*) searchHistoryFilePath;
- (NSInteger) activeAccountFolderSize;

//
- (NSString*) dbPathForGroup:(NSString*)kbguid;
- (NSString*) tempDbPathForGroup:(NSString*)kbguid;
- (NSString*) accountsDbPath;
@end
