//
//  WizTag.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTag.h"
#import "WizDbManager.h"

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
    return [[WizDbManager shareDbManager] tagFromGuid:guid];
}
- (NSString*) tagAbstract
{
    return [[WizDbManager shareDbManager] tagAbstractString:self.guid];
}
- (BOOL) save
{
    if (nil == self.guid || [self.guid isBlock]) {
        self.guid = [WizGlobals genGUID];
    }
    NSMutableDictionary* tag = [NSMutableDictionary dictionary];
    
    if (nil == self.description) {
        self.description = @"";
    }
    [tag setObject:self.guid forKey:DataTypeUpdateTagGuid];
    [tag setObject:self.title forKey:DataTypeUpdateTagTitle];
    [tag setObject:self.description forKey:DataTypeUpdateTagDescription];
    [tag setObject:[NSNumber numberWithInt:self.localChanged] forKey:DataTypeUpdateTagLocalchanged];
    if (nil == self.dateInfoModified) {
        self.dateInfoModified = [NSDate date];
    }
    [tag setObject:self.dateInfoModified forKey:DataTypeUpdateTagDtInfoModifed];
    if (nil == parentGUID) {
        self.parentGUID = @"";
    }
    [tag setObject:self.parentGUID forKey:DataTypeUpdateTagParentGuid];
    return [[WizDbManager shareDbManager] updateTag:tag];
}
+ (void) deleteTag:(NSString*)tagGuid
{
    WizDbManager* db = [WizDbManager shareDbManager];
    [db deleteTag:tagGuid];
}

+ (NSArray*) allTags
{
    return [[WizDbManager shareDbManager] allTagsForTree];
}
+ (NSInteger) fileCountOfTag:(NSString*)tagGuid
{
    return [[WizDbManager shareDbManager] fileCountOfTag:tagGuid];
}
@end
