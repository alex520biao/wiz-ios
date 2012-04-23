//
//  WizSettings.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSettings.h"

@implementation WizSettings
//single object
static WizSettings* defaultSettings = nil;
+ (id) defaultSettings
{
    @synchronized(defaultSettings)
    {
        if (defaultSettings == nil) {
            defaultSettings = [[super allocWithZone:NULL] init];
        }
        return defaultSettings;
    }
}
+ (id) allocWithZone:(NSZone *)zone
{
    return [[self shareDbManager] retain];
}
- (id) retain
{
    return self;
}
- (NSUInteger) retainCount
{
    return NSUIntegerMax;
}
- (id) copyWithZone:(NSZone*)zone
{
    return self;
}
- (id) autorelease
{
    return self;
}
- (oneway void) release
{
    return;
}
// over
@end
