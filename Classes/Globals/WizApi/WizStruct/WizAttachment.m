//
//  WizAttachment.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"
#import "WizFileManager.h"
#import "WizDbManager.h"
#import "WizSyncManager.h"

@implementation WizAttachment
@synthesize type;
@synthesize dataMd5;
@synthesize description;
@synthesize dateModified;
@synthesize documentGuid;
@synthesize serverChanged;
@synthesize localChanged;
- (void) dealloc
{
    [type release];
    [dataMd5 release];
    [description release];
    [documentGuid release];
    [super dealloc];
}
- (NSString*) attachmentFilePath
{
    NSString* attachmentPath = [[WizFileManager shareManager] objectFilePath:self.guid];
    NSArray* contents = [[WizFileManager shareManager] contentsOfDirectoryAtPath:attachmentPath error:nil];
    for (NSString* name in contents) {
        
    }
    return  [attachmentPath stringByAppendingPathComponent:self.title];
}
- (NSString*) localDataMd5
{
    NSString* dataFilePath = [self attachmentFilePath];
    if (![[WizFileManager defaultManager] fileExistsAtPath:dataFilePath]) {
        return @"";
    }
    NSString* fileMd5 = [WizGlobals fileMD5:dataFilePath];
    [[WizFileManager shareManager] deleteFile:dataFilePath];
    return fileMd5;
}

- (NSDictionary*) dataBaseModelData
{
    NSMutableDictionary* attachment = [NSMutableDictionary dictionaryWithCapacity:14];
    [attachment setObjectNotNull:self.guid forKey:DataTypeUpdateAttachmentGuid];
    [attachment setObjectNotNull:self.dataMd5 forKey:DataTypeUpdateAttachmentDataMd5];
    [attachment setObjectNotNull:[NSNumber numberWithBool:self.serverChanged] forKey:DataTypeUpdateAttachmentServerChanged];
    [attachment setObjectNotNull:[NSNumber numberWithBool:self.localChanged] forKey:DataTypeUpdateAttachmentLocalChanged];
    [attachment setObjectNotNull:self.title forKey:DataTypeUpdateAttachmentTitle];
    [attachment setObjectNotNull:self.documentGuid forKey:DataTypeUpdateAttachmentDocumentGuid];
    [attachment setObjectNotNull:self.dateModified forKey:DataTypeUpdateAttachmentDateModified];
    [attachment setObject:self.description forKey:DataTypeUpdateAttachmentDescription];
    return attachment;
}

- (BOOL) saveData:(NSString*)filePath
{
    if (self.guid == nil || [self.guid isBlock]) {
        self.guid = [WizGlobals genGUID];
    }
    NSString* fileName = [filePath fileName];
    NSString* fileType = [filePath fileType];
    self.type = fileType;
    self.title = fileName;
    if (![[WizFileManager shareManager] moveItemAtPath:filePath toPath:[self attachmentFilePath] error:nil]) {
        return NO;
    }
    
    if (nil == self.title || [self.title isBlock]) {
        self.title = WizStrNoTitle;
    }
    if (nil == self.dateModified) {
        self.dateModified = [NSDate date];
    }
    if (nil == self.description) {
        self.description = @"";
    }
    self.dataMd5 = [WizGlobals fileMD5:filePath];
    self.localChanged = YES;
    self.serverChanged = NO;
    
    return [[[WizDbManager shareDbManager] shareDataBase] updateAttachment:[self dataBaseModelData]];
}
+ (void) deleteAttachment:(NSString*)attachmentGuid
{
    id<WizDbDelegate> db = [[WizDbManager shareDbManager] shareDataBase];
    [db deleteAttachment:attachmentGuid];
}
+ (WizAttachment*) attachmentFromDb:(NSString *)attachmentGuid
{
    return [[[WizDbManager shareDbManager] shareDataBase] attachmentFromGUID:attachmentGuid];
}

+ (void) setAttachServerChanged:(NSString*)attachmentGUID changed:(BOOL)changed
{
    [[[WizDbManager shareDbManager] shareDataBase] setAttachmentServerChanged:attachmentGUID changed:changed];
}
+ (void) setAttachmentLocalChanged:(NSString *)attachmentGuid changed:(BOOL)changed
{
    [[[WizDbManager shareDbManager] shareDataBase] setAttachmentLocalChanged:attachmentGuid changed:changed];
}
- (void) upload
{
    if (!self.localChanged) {
        return;
    }
    [[[WizSyncManager shareManager] activeGroupSync] uploadWizObject:self];
}

- (void) download
{
    if (!self.serverChanged) {
        return;
    }
    [[[WizSyncManager shareManager]activeGroupSync] downloadWizObject:self];
}

@end
