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

    NSMutableArray* filesArray = [NSMutableArray array];
    if (hasAudio) {
        [filesArray addObjectsFromArray:[self picturesContentArray:audios]];
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
    [html writeToFile:documentIndex atomically:YES encoding:NSUTF8StringEncoding error:nil];
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
    [self saveInfo];
    [WizDocumentEdit setDocumentLocalChanged:self.guid changed:YES];
    [WizDocumentEdit setDocumentServerchangedToDb:self.guid changed:NO];
    return YES;
}
- (BOOL) saveInfo
{
    if (self.guid == nil || [self.guid isBlock]) {
        self.guid = [WizGlobals genGUID];
    }
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithCapacity:14];
    [doc setObject:self.guid forKey:DataTypeUpdateDocumentGUID];
    [doc setObject:[NSNumber numberWithBool:self.serverChanged] forKey:DataTypeUpdateDocumentServerChanged];
    [doc setObject:[NSNumber numberWithBool:1] forKey:DataTypeUpdateDocumentLocalchanged];
    [doc setObject:[NSNumber numberWithBool:self.protected_] forKey:DataTypeUpdateDocumentProtected];
    [doc setObject:[NSNumber numberWithInt:self.attachmentCount] forKey:DataTypeUpdateDocumentAttachmentCount];
    [doc setObject:self.type forKey:DataTypeUpdateDocumentType];
    if (nil == self.url) {
        self.url = @"";
    }
    [doc setObject:self.url forKey:DataTypeUpdateDocumentUrl];
    if (nil == self.location || [self.location isBlock]) {
        self.location = @"/My Notes/";
    }
    [doc setObject:self.location forKey:DataTypeUpdateDocumentLocation];
    if (nil == self.title || [self.title isBlock]) {
        self.title = WizStrNoTitle;
    }
    [doc setObject:self.title forKey:DataTypeUpdateDocumentTitle];
    if (nil == self.tagGuids) {
        self.tagGuids = @"";
    }
    [doc setObject:self.tagGuids forKey:DataTypeUpdateDocumentTagGuids];
    if (nil == self.fileType) {
        self.fileType = @"";
    }
    [doc setObject:self.fileType forKey:DataTypeUpdateDocumentFileType];
    if (nil == self.dateCreated ) {
        self.dateCreated = [NSDate date];
    }
    [doc setObject:self.dateCreated forKey:DataTypeUpdateDocumentDateCreated];
    if (nil == self.dateModified) {
        self.dateModified = [NSDate date];
    }
    [doc setObject:self.dateModified forKey:DataTypeUpdateDocumentDateModified];
    if (nil == self.dataMd5 || [self.dataMd5 isBlock]) {
        //md5
        self.dataMd5 = @"";
    }
    [doc setObject:self.dataMd5 forKey:DataTypeUpdateDocumentDataMd5];
    return [[WizDbManager shareDbManager] updateDocument:doc];
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

@end
