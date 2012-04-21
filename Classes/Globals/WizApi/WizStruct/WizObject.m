//
//  WizObject.m
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

@implementation WizObject
@synthesize guid;
@synthesize title;
- (void) dealloc
{
    [guid release];
    [title release];
    [super dealloc];
}
@end
