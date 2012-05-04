//
//  WizDocumentEdit.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDocumentEdit.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
#import "WizDocument.h"
@implementation WizDocumentEdit
@synthesize editDelegate;
+ (void) setDocumentServerchangedToDb:(NSString*)documentGUID  changed:(BOOL)changed
{
    [[WizDbManager shareDbManager] setDocumentServerChanged:documentGUID changed:changed];
}
+ (void) setDocumentLocalChanged:(NSString*)documentGUID changed:(BOOL)changed
{
    [[WizDbManager shareDbManager] setDocumentLocalChanged:documentGUID changed:changed];
}
- (NSString*) photoHtmlString:(NSString*)photoName
{
    return [NSString stringWithFormat:@"<img src=\"index_files/%@\" alt=\"%@\" >",photoName,photoName];
}
- (NSString*) audioHtmlString:(NSString*)audioName
{
    return [NSString stringWithFormat:@"<embed src=\"index_files/%@\" autostart=false>",audioName];
}
- (NSString*) titleHtmlString:(NSString*)_title
{
    return [NSString stringWithFormat:@"<title>%@</title>",_title];
}
- (NSString*) wizHtmlString:(NSString*)_title body:(NSString*)body
{
    return [NSString stringWithFormat:@"<html>%@<body>%@</body></html>",_title,body];
}
- (NSString*) tableHtmlString:(NSArray*)contentArray
{
    NSMutableString* ret = [NSMutableString string];
    [ret appendString:@"<ul>"];
    for (NSString* each in contentArray) {
        [ret appendFormat:@"<li>%@</li>",each];
    }
    [ret appendString:@"</ul>"];
    return ret;
}
- (NSArray*) picturesContentArray:(NSArray*)array
{
    NSMutableArray* contentArray = [NSMutableArray array];
    NSString* documentIndexPath = [self documentIndexFilesPath];
    for (NSString* each in array) {
        NSString* fileName = [each fileName];
        NSString* toPath = [documentIndexPath stringByAppendingPathComponent:fileName];
        if ([[WizFileManager shareManager] moveItemAtPath:each toPath:toPath error:nil])
        {
            [contentArray addObject:[self photoHtmlString:fileName]];
        }
        else {
            [WizGlobals reportErrorWithString:@"move error"];
        }
    }
    return contentArray;
}

- (NSArray*) audiosContentArray:(NSArray*)array
{
    NSMutableArray* contentArray = [NSMutableArray array];
    NSString* documentIndexPath = [self documentIndexFilesPath];
    for (NSString* each in array) {
        NSString* fileName = [each fileName];
        NSString* toPath = [documentIndexPath stringByAppendingPathComponent:fileName];
        if ([[WizFileManager shareManager] moveItemAtPath:each toPath:toPath error:nil])
        {
            [contentArray addObject:[self audioHtmlString:fileName]];
        }
    }
    return contentArray;
}
- (void) buildBody
{
    NSString* body = [self.editDelegate documentBody];
    if (body == nil ) {
        body = @"";
    }
    NSArray* pictures = [self.editDelegate documentPictures];
    BOOL hasPicture = pictures != nil && [pictures count] >0;
    NSArray* audios = [self.editDelegate documentAudios];
    BOOL hasAudio = audios != nil && [audios count] >0;
    if (hasAudio && !hasPicture) {
        self.type = @"audio";
    }
    else if (hasPicture && !hasAudio) {
        self.type = @"image";
    }
    else {
        self.type = @"note";
    }
    NSLog(@"picture count is %d",[pictures count]);

    NSMutableArray* filesArray = [NSMutableArray array];
    if (hasAudio) {
        [filesArray addObjectsFromArray:[self audiosContentArray:audios]];
    }
    if (hasPicture) {
        [filesArray addObjectsFromArray:[self picturesContentArray:pictures]];
    }
    NSString* tableString = [self tableHtmlString:filesArray];
    if (self.title == nil || [self.title length] == 0)
	{
		self.title = [body firstLine];
	}
    if (self.title == nil || [self.title isBlock]) {
        self.title = WizStrNoTitle;
    }
    NSString* titleHtml = [self titleHtmlString:self.title];
    body = [body toHtml];
    body = [body stringByAppendingString:tableString];
    NSString* html = [self wizHtmlString:titleHtml body:body];
    NSString* documentIndex = [self documentIndexFile];
    [html writeToFile:documentIndex atomically:YES encoding:NSUTF16StringEncoding error:nil];
    self.dataMd5 = [self localDataMd5];
}
- (BOOL) saveWithData
{
    if (self.serverChanged) {
        return NO;
    }
    if (self.guid == nil || [self.guid isBlock]) {
        self.guid = [WizGlobals genGUID];
    }
    [self buildBody];
    self.localChanged = YES;
    [self saveInfo];
    return YES;
}

- (BOOL) deleteTag:(NSString*)tagGuid
{
    if (nil == self.tagGuids) {
        return NO;
    }
    NSRange range = [self.tagGuids rangeOfString:tagGuid];
    if (range.location == NSNotFound || range.length == NSNotFound)
    {
        return NO;
    }
    self.tagGuids = [self.tagGuids stringByReplacingCharactersInRange:range withString:@""];
    if(range.location >= 1)
    {
        NSRange subRange = NSMakeRange(range.location-1, 1);
        NSString* sepatatedStr = [self.tagGuids substringWithRange:subRange];
        if([sepatatedStr isEqualToString:@"*"])
        {
            self.tagGuids = [self.tagGuids stringByReplacingCharactersInRange:subRange withString:@""];
        }
    }
    return [self saveInfo];
}
- (id) initFromWizDocument:(WizDocument*)doc
{
    self = [super init];
    if (self) {
        self.title = doc.title;
        self.guid = doc.guid;
        self.location = doc.location;
        self.protected_ = doc.protected_;
        self.tagGuids = doc.tagGuids;
        self.dataMd5 = doc.dataMd5;
        self.dateCreated = doc.dateCreated;
        self.dateModified = doc.dateModified;
        self.serverChanged = doc.serverChanged;
        self.localChanged = doc.localChanged;
        self.fileType = doc.fileType;
        self.type = doc.type;
        self.attachmentCount = doc.attachmentCount;
        self.url = doc.url;
    }
    return self;
}
@end
