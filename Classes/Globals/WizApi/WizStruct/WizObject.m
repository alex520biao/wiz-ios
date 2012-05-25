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
    return [[WizDbManager shareDbManager] filecountWithChildOfLocation:location];
}
+ (int) fileCountOfLocation:(NSString *)location
{
    return [[WizDbManager shareDbManager] fileCountOfLocation:location];
}
+ (NSArray*) allLocationsForTree
{
    return [[WizDbManager shareDbManager] allLocationsForTree];
}

+ (NSString*) folderAbstract:(NSString*)folderKey
{
    return [[WizDbManager shareDbManager] folderAbstractString:folderKey];
}
- (id) init
{
    self = [super init];
    if (self) {
        guid = [[WizGlobals genGUID] retain];
    }
    return self;
}
@end
