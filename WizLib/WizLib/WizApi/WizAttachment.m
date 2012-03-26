//
//  WizAttachment.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"
#import "index.h"
@implementation WizAttachment
@synthesize title;
@synthesize type;
@synthesize dataMd5;
@synthesize description;
@synthesize dateModified;
@synthesize serverChanged;
@synthesize localChanged;
@synthesize documentGuid;
-(void) dealloc
{
    self.title = nil;
    self.type = nil;
    self.dataMd5 = nil;
    self.description = nil;
    self.dateModified = nil;
    self.serverChanged = nil;
    self.localChanged = nil;
    self.documentGUID = nil;
    [super dealloc];
}

-(id) initFromAttachmentGuidData:(const WIZDOCUMENTATTACH&)data
{
    self = [super init];
    if (self) {
        self.documentGUID = [NSString stringWithUTF8String:data.strDocumentGuid.c_str()];
        self.guid = [NSString stringWithUTF8String:data.strAttachmentGuid.c_str()] ;
        self.title = [NSString stringWithUTF8String:data.strAttachmentName.c_str()];
        self.dateModified = [NSString stringWithUTF8String:data.strDataModified.c_str()] ;
        self.description = [NSString stringWithUTF8String:data.strDescription.c_str()] ;
        self.dataMd5 = [NSString stringWithUTF8String:data.strDataMd5.c_str()] ;
        self.localChanged = data.loaclChanged;
        self.serverChanged = data.serverChanged;
        NSArray* typeArry = [self.attachmentName componentsSeparatedByString:@"."];
        self.type = [typeArry lastObject];
    }

    return  self;
}
@end