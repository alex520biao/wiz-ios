//
//  WizObject.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
#import "WizDbManager.h"

@implementation WizObject
@synthesize guid;
@synthesize title;
- (void) dealloc
{
    [guid release];
    [title release];
    [super dealloc];
}
+ (int) filecountWithChildOfLocation:(NSString*) location
{
    return [[[WizDbManager shareDbManager] shareDataBase] filecountWithChildOfLocation:location];
}
+ (int) fileCountOfLocation:(NSString *)location
{
    return [[[WizDbManager shareDbManager] shareDataBase] fileCountOfLocation:location];
}
+ (NSArray*) allLocationsForTree
{
    return [[[WizDbManager shareDbManager] shareDataBase] allLocationsForTree];
}

+ (NSString*) folderAbstract:(NSString*)folderKey
{
    return [[[WizDbManager shareDbManager] shareDataBase] folderAbstractString:folderKey];
}
- (id) init
{
    self = [super init];
    if (self) {
        guid = [[WizGlobals genGUID] retain];
    }
    return self;
}
+ (void) deleteFolder:(NSString*)folderKey
{
    id<WizDbDelegate> dataBase = [[WizDbManager shareDbManager] shareDataBase];
    NSArray* documents = [dataBase documentsByLocation:folderKey];
    for (WizDocument* doc in documents) {
        [WizDocument deleteDocument:doc];
    }
    [dataBase deleteLocalFolder:folderKey];
    
}

+ (BOOL) addLocalFolder:(NSString*)folder
{
    id<WizDbDelegate> dataBase = [[WizDbManager shareDbManager] shareDataBase];
    return [dataBase updateLocalFolder:folder];
}
@end
