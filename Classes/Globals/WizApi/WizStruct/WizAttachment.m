//
//  WizAttachment.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"
#import "WizFileManager.h"

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
@end
