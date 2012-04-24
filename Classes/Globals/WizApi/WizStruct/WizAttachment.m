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

- (id) initFromGuid:(NSString*)attachmentGuid
{
    return nil;
}

- (BOOL) saveInfo
{
    return YES;
}
- (BOOL) saveData:(NSString*)filePath
{
    return YES;
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
@end
