//
//  WizSyncDescription.m
//  Wiz
//
//  Created by 朝 董 on 12-4-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncDescription.h"

@implementation WizSyncDescription
@dynamic globalString;

- (void) setGlobalString:(NSString *)_globalString
{
    if (globalString == _globalString) {
        return;
    }
    [globalString release];
    globalString = [_globalString retain];
}
@end
