//
//  WizLib.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizLib.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"
#import "WizFileManager.h"
@implementation WizLib
+ (void) addAccount:(NSString *)userId password:(NSString *)password
{
    [WizDbManager shareDbManager];
    [WizAccountManager addAccount:userId password:password];
}
+ (void) registeAccount:(NSString*)userId
{
    [WizAccountManager registerActiveAccount:userId];
    [[WizSyncManager shareManager] refreshLogInfo];
    [[WizSyncManager shareManager] startSyncAccountInfo];
}
@end
@implementation WizDocument (WizNote)
- (id) initFromGuid:(NSString *)Guid
{
    self = [super init];
    if (self) {
        WizDocument* doc = [[WizDbManager shareDbManager] documentFromGUID:Guid];
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
- (BOOL) saveBody:(NSString*)body
{
    if ([body isBlock]) {
        body = @"<html><body>Error!</body></html>";
    }
    NSError* error=nil;
    NSString* filePath = [self documentFilePath];
    if (![body writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        [WizGlobals reportError:error];
        return NO;
    }
    return [self save];
}
- (BOOL) save
{
    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithCapacity:14];
    if (self.serverChanged) {
        return NO;
    }
    [doc setObject:self.guid forKey:DataTypeUpdateDocumentGUID];
    [doc setObject:[NSNumber numberWithBool:self.serverChanged] forKey:DataTypeUpdateDocumentServerChanged];
    [doc setObject:[NSNumber numberWithBool:1] forKey:DataTypeUpdateDocumentLocalchanged];
    [doc setObject:[NSNumber numberWithBool:self.protectedB] forKey:DataTypeUpdateDocumentProtected];
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
    if (nil == self.dateCreated || [self.dateCreated isBlock]) {
        self.dateCreated = [WizGlobals dateToSqlString:[NSDate date]];
    }
    [doc setObject:[WizGlobals sqlTimeStringToDate:self.dateCreated] forKey:DataTypeUpdateDocumentDateCreated];
    if (nil == self.dateModified || [self.dateModified isBlock]) {
        self.dateModified = [WizGlobals dateToSqlString:[NSDate date]];
    }
    [doc setObject:[WizGlobals sqlTimeStringToDate:self.dateModified] forKey:DataTypeUpdateDocumentDateModified];
    if (nil == self.dataMd5 || [self.dataMd5 isBlock]) {
        //md5
        self.dataMd5 = @"";
    }
    [doc setObject:self.dataMd5 forKey:DataTypeUpdateDocumentDataMd5];
    return  [[WizDbManager shareDbManager] updateDocument:doc];
}
- (void) upload
{
    [[WizSyncManager shareManager] uploadDocument:self.guid];
}
- (void) download
{
    [[WizSyncManager shareManager] downloadDocument:self.guid];
}
@end