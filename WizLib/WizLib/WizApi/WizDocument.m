//
//  WizDocument.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocument.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "index.h"
@implementation WizDocument

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
-(void) dealloc
{
	self.title = nil;
	self.location = nil;
	self.url = nil;
	self.type = nil;
	self.fileType = nil;
	self.dateCreated = nil;
	self.dateModified = nil;
    self.tagGuids = nil;
	[super dealloc];
}
- (NSComparisonResult) compareCreateDate:(WizDocument*)doc
{
    return [[WizGlobals sqlTimeStringToDate:self.dateCreated] isLaterThanDate:[WizGlobals sqlTimeStringToDate:doc.dateCreated]];
}
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc
{
    return [[WizGlobals sqlTimeStringToDate:self.dateCreated] isEarlierThanDate:[WizGlobals sqlTimeStringToDate:doc.dateCreated]];
}
- (NSComparisonResult) compareDate:(WizDocument *)doc
{
    return [[WizGlobals sqlTimeStringToDate:self.dateModified] isLaterThanDate:[WizGlobals sqlTimeStringToDate:doc.dateModified]];
}
- (NSComparisonResult) compareReverseDate:(WizDocument *)doc
{
    return [[WizGlobals sqlTimeStringToDate:self.dateModified] isEarlierThanDate:[WizGlobals sqlTimeStringToDate:doc.dateModified]];
}

- (NSComparisonResult) compareWithFirstLetter:(WizDocument *)doc
{
    return [[WizGlobals pinyinFirstLetter:self.title] compare:[WizGlobals pinyinFirstLetter:doc.title]];
}

- (NSComparisonResult) compareReverseWithFirstLetter:(WizDocument *)doc
{
    NSComparisonResult ret = [[WizGlobals pinyinFirstLetter:self.title] compare:[WizGlobals pinyinFirstLetter:doc.title]];
    if (ret == -1) {
        return 1;
    }
    else if (ret == 1)
    {
        return -1;
    }
    return ret;
}
- (id) initFromWizDocumentData: (const WIZDOCUMENTDATA&) data
{
    self = [super init];
	if (self)
	{
		self.guid            = [[[NSString alloc] initWithUTF8String: data.strGUID.c_str()] autorelease];
		self.title           = [[[NSString alloc] initWithUTF8String: data.strTitle.c_str()] autorelease];
		self.location        = [[[NSString alloc] initWithUTF8String: data.strLocation.c_str()] autorelease];
		self.url             = [[[NSString alloc] initWithUTF8String: data.strURL.c_str()] autorelease];
		self.type            = [[[NSString alloc] initWithUTF8String: data.strType.c_str()] autorelease]; 
		self.fileType        = [[[NSString alloc] initWithUTF8String: data.strFileType.c_str()] autorelease]; 
		self.dateCreated     = [[[NSString alloc] initWithUTF8String: data.strDateCreated.c_str()] autorelease];
		self.dateModified    = [[[NSString alloc] initWithUTF8String: data.strDateModified.c_str()] autorelease];
        self.tagGuids           = [[[NSString alloc] initWithUTF8String: data.strTagGUIDs.c_str()] autorelease];
		self.attachmentCount = data.nAttachmentCount;
        self.serverChanged = data.nServerChanged?YES:NO;
        self.localChanged = data.nLocalChanged?YES:NO;
	}
	return self;
}

@end
