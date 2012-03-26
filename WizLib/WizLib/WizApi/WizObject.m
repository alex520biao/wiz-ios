//
//  WizObject.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"
#import "WizGlobals.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
@implementation WizObject
@synthesize guid;
- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
- (void) dealloc
{
    self.guid = nil;
    [super dealloc];
}
- (NSString*) directoryPath
{
    NSString* directoryPath = [WizIndex documentFilePath:[WizActiveUserManager activeAccountUserId] documentGUID:guid];
    return directoryPath;
}
- (NSString*) downloadTempFilePath
{
    NSString* directoryPath = [self directoryPath];
    NSString* filePath = [directoryPath stringByAppendingPathComponent:@"temp.zip"];
    return filePath;
}
@end
