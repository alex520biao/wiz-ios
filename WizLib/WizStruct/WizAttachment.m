//
//  WizAttachment.m
//  WizLib
//
//  Created by MagicStudio on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"
#import "WizDbManager.h"
@implementation WizAttachment
@synthesize guid;
@synthesize title;
@synthesize description;
@synthesize dateModified;
@synthesize dataMd5;
@synthesize documentGuid;
@synthesize serverChanged;
@synthesize localChanged;
- (void) dealloc
{
    [dataMd5 release];
    [dateModified release];
    [documentGuid release];
    [guid release];
    [title release];
    [description release];
    [super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
        self.guid = [WizGlobals genGUID];
        self.title = WizStrNoTitle;
    }
    return self;
}
- (id) initFromGUID:(NSString *)Guid
{
    self = [super init];
    if (self) {
        WizAttachment* attach = [[WizDbManager shareDbManager] attachmentFromGUID:Guid];
        if (attach == nil ) {
            return nil;
        }
        self.title = attach.title;
        self.guid = attach.guid;
        self.description = attach.description;
        self.dataMd5 = attach.dataMd5;
        self.dateModified = attach.dateModified;
        self.localChanged = attach.localChanged;
        self.serverChanged = attach.serverChanged;
        self.documentGuid = attach.documentGuid;
    }
    return self;
}
@end
