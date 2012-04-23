//
//  WizTag.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTag.h"

@implementation WizTag
@synthesize parentGUID;
@synthesize description;
@synthesize namePath;
@synthesize dateInfoModified;
@synthesize localChanged;
- (void) dealloc
{
    [parentGUID release];
    [description release];
    [namePath release];
    [dateInfoModified release];
    [super dealloc];
}
@end
