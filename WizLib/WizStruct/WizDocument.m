//
//  WizDocument.m
//  WizLib
//
//  Created by 朝 董 on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocument.h"
@implementation WizDocument
@synthesize guid;
@synthesize title;
@synthesize location;
@synthesize url;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize type;
@synthesize fileType;
@synthesize attachmentCount;
@synthesize tagGuids;
@synthesize serverChanged;
@synthesize localChanged;
@synthesize dataMd5;
@synthesize protectedB;
-(void) dealloc
{
	self.guid = nil;
	self.title = nil;
	self.location = nil;
	self.url = nil;
	self.type = nil;
	self.fileType = nil;
	self.dateCreated = nil;
	self.dateModified = nil;
    self.tagGuids = nil;
    self.dataMd5 = nil;
	[super dealloc];
}
- (id) init
{
    self = [super init];
    if (self) {
        self.guid = [WizGlobals genGUID];
        self.type = @"note";
        self.location = @"/My Notes/";
    }
    return self;
}
@end
