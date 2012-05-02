//
//  WizString.m
//  Wiz
//
//  Created by 朝 董 on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizString.h"

@implementation WizString
- (void) dealloc
{
    NSLog(@"string ret %d",[self retainCount]);
    [super dealloc];
}
@end
