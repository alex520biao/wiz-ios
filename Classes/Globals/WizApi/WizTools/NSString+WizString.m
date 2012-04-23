//
//  NSString+WizString.m
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSString+WizString.h"

@implementation NSString (WizString)
- (BOOL) isBlock
{
    return nil == self ||[self isEqualToString:@""];
}
@end
