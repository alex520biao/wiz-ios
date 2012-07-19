//
//  WizSetting.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSetting.h"


@implementation WizSetting

@synthesize accountUserId;
@synthesize key;
@synthesize value;

- (void) dealloc
{
    [accountUserId release];
    [key release];
    [value release];
    [super dealloc];
}

@end
