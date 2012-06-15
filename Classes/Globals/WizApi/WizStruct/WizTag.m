//
//  WizTag.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTag.h"
#import "WizDbManager.h"
#import "WizGlobals.h"
@implementation WizTag
@synthesize parentGUID;
@synthesize description;
@synthesize namePath;
@synthesize dateInfoModified;
@synthesize localChanged;
- (id) init
{
    self = [super init];
    if (self) {
        guid = [[WizGlobals genGUID] retain];
        localChanged = YES;
    }
    return self;
}
- (void) dealloc
{
    [parentGUID release];
    [description release];
    [namePath release];
    [dateInfoModified release];
    [super dealloc];
}
+ (WizTag*) tagFromDb:(NSString*)guid
{
    return [[[WizDbManager shareDbManager] shareDataBase] tagFromGuid:guid];
}
- (NSString*) tagAbstract
{
    return [[[WizDbManager shareDbManager] shareDataBase] tagAbstractString:self.guid];
}

- (NSDictionary*) dataBaseModelData
{
    NSMutableDictionary* tag = [NSMutableDictionary dictionary];
    [tag setObjectNotNull:self.guid forKey:DataTypeUpdateTagGuid];
    [tag setObjectNotNull:self.title forKey:DataTypeUpdateTagTitle];
    [tag setObjectNotNull:self.description forKey:DataTypeUpdateTagDescription];
    [tag setObjectNotNull:[NSNumber numberWithInt:self.localChanged] forKey:DataTypeUpdateTagLocalchanged];
    [tag setObjectNotNull:self.dateInfoModified forKey:DataTypeUpdateTagDtInfoModifed];
    [tag setObjectNotNull:self.parentGUID forKey:DataTypeUpdateTagParentGuid];
    return tag;
}

- (BOOL) save
{
    if (nil == self.guid || [self.guid isBlock]) {
        self.guid = [WizGlobals genGUID];
    }
    if (nil == self.description) {
        self.description = @"";
    }
    if (nil == self.dateInfoModified) {
        self.dateInfoModified = [NSDate date];
    }
    if (nil == parentGUID) {
        self.parentGUID = @"";
    }
    return [[[WizDbManager shareDbManager] shareDataBase] updateTag:[self dataBaseModelData]];
}
+ (void) deleteTag:(NSString*)tagGuid
{
    WizDataBase* db = [[WizDbManager shareDbManager] shareDataBase];
    [db deleteTag:tagGuid];
}

+ (NSArray*) allTags
{
    return [[[WizDbManager shareDbManager] shareDataBase] allTagsForTree];
}
+ (NSInteger) fileCountOfTag:(NSString*)tagGuid
{
    return [[[WizDbManager shareDbManager]shareDataBase] fileCountOfTag:tagGuid];
}
@end
