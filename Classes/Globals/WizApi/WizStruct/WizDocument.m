//
//  WizDocument.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocument.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "WizDbManager.h"
#import "WizFileManager.h"

@implementation WizDocument
@synthesize fileType;
@synthesize type;
@synthesize location;
@synthesize url;
@synthesize dateCreated;
@synthesize dateModified;
@synthesize tagGuids;
@synthesize dataMd5;
@synthesize protected_;
@synthesize serverChanged;
@synthesize localChanged;
@synthesize attachmentCount;
- (void) dealloc
{
    [fileType release];
    [type release];
    [location release];
    [url release];
    [dateCreated release];
    [dateModified release];
    [tagGuids release];
    [dataMd5 release];
    [super dealloc];
}

- (NSComparisonResult) compareCreateDate:(WizDocument*)doc
{
    return [self.dateCreated isLaterThanDate:doc.dateCreated];
}
- (NSComparisonResult) compareReverseCreateDate:(WizDocument*)doc
{
    return [self.dateCreated isEarlierThanDate:doc.dateCreated];
}
- (NSComparisonResult) compareDate:(WizDocument *)doc
{
    return [self.dateModified isLaterThanDate:doc.dateModified];
}
- (NSComparisonResult) compareReverseDate:(WizDocument *)doc
{
    return [self.dateModified isEarlierThanDate:doc.dateModified];
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
- (NSString*) documentIndexFilesPath
{
    WizFileManager* share = [WizFileManager shareManager];
    return [share documentIndexFile:self.guid];
}
- (NSString*) documentIndexFile
{
	WizFileManager* share = [WizFileManager shareManager];
    return [share documentIndexFile:self.guid];
}
- (NSString*) documentMobileFile
{
    WizFileManager* share = [WizFileManager shareManager];
    return [share documentMobileFile:self.guid];
}
- (NSString*) documentAbstractFile
{
    WizFileManager* share = [WizFileManager shareManager];
    return [share documentAbstractFile:self.guid];
}
- (NSString*) documentFullFile
{
    WizFileManager* share = [WizFileManager shareManager];
    return [share documentFullFile:self.guid];
}


@end
