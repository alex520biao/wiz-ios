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

@implementation WizAttachment
@synthesize type;
@synthesize dateMd5;
@synthesize description;
@synthesize dateModified;
@synthesize documentGuid;
@synthesize serverChanged;
@synthesize localChanged;
- (void) dealloc
{
    [type release];
    [dateMd5 release];
    [description release];
    [documentGuid release];
    [documentGuid release];
    [super dealloc];
}
- (NSString*) attachmentFilePath
{
    NSString* attachmentPath = [[WizFileManager shareManager] objectFilePath:self.guid];
    return  [attachmentPath stringByAppendingString:self.title];
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
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithCapacity:14];
    if (nil == self.title || [self.title isBlock]) {
        self.title = WizStrNoTitle;
    }
    if (nil == self.dateModified) {
        self.dateModified = [NSDate date];
    }
    if (nil == self.description) {
        self.description = @"";
    }
    self.dateMd5 = [WizGlobals fileMD5:filePath];
    [doc setObject:self.guid forKey:DataTypeUpdateAttachmentGuid];
    [doc setObject:self.dateMd5 forKey:DataTypeUpdateAttachmentDataMd5];
    [doc setObject:[NSNumber numberWithBool:self.serverChanged] forKey:DataTypeUpdateAttachmentServerChanged];
    [doc setObject:[NSNumber numberWithBool:1] forKey:DataTypeUpdateAttachmentLocalChanged];
//    [doc setObject:self.type forKey:DataTypeUpdateAttachmentDataMd5];
    [doc setObject:self.title forKey:DataTypeUpdateAttachmentTitle];
    [doc setObject:self.documentGuid forKey:DataTypeUpdateAttachmentDocumentGuid];
    [doc setObject:self.dateModified forKey:DataTypeUpdateAttachmentDateModified];
    [doc setObject:self.description forKey:DataTypeUpdateAttachmentDescription];
    return [[WizDbManager shareDbManager] updateDocument:doc];
}
+ (void) deleteAttachment:(NSString*)attachmentGuid
{
    WizDbManager* db = [WizDbManager shareDbManager];
    [db deleteAttachment:attachmentGuid];
}
+ (WizAttachment*) attachmentFromDb:(NSString *)attachmentGuid
{
    return [[WizDbManager shareDbManager] attachmentFromGUID:attachmentGuid];
}

+ (void) setAttachServerChanged:(NSString*)attachmentGUID changed:(BOOL)changed
{
    [[WizDbManager shareDbManager] setAttachmentServerChanged:attachmentGUID changed:changed];
}
+ (void) setAttachmentLocalChanged:(NSString *)attachmentGuid changed:(BOOL)changed
{
    [[WizDbManager shareDbManager] setAttachmentLocalChanged:attachmentGuid changed:changed];
}
@end
