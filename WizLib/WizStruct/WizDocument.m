//
//  WizDocument.m
//  WizLib
//
//  Created by 朝 董 on 12-4-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocument.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
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
	[guid release];
	[title release];
	[location release];
	[url release];
	[type release];
	[fileType release];
	[dateCreated release];
	[dateModified release];
    [tagGuids release];
    [dataMd5 release];
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
- (id) initFromGuid:(NSString *)Guid
{
    self = [super init];
    if (self) {
        WizDocument* doc = [[WizDbManager shareDbManager] documentFromGUID:Guid];
        if (nil == doc) {
            return nil;
        }
        self.guid = doc.guid;
        self.title = doc.title;
        self.dateCreated = doc.dateCreated;
        self.dateModified = doc.dateModified;
        self.location = doc.location;
        self.localChanged = doc.localChanged;
        self.serverChanged = doc.serverChanged;
        self.dataMd5 = doc.dataMd5;
        self.tagGuids = doc.tagGuids;
        self.attachmentCount = doc.attachmentCount;
        self.protectedB = doc.protectedB;
        self.type = doc.type;
        self.fileType = doc.fileType;
        self.url = doc.url;
    }
    return self;
}
- (NSString*) documentFilePath
{
    return [WizFileManager documentFile:self.guid];
}
- (NSString*) documentMobileFilePath
{
    return [WizFileManager documentMobileViewFile:self.guid];
}
- (NSString*) documentAbstractFilePath
{
    return [WizFileManager documentAbstractFile:self.guid];
}
- (NSString*) documentFullFilePath
{
    return [WizFileManager documentFullFile:self.guid];
}
@end
