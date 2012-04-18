//
//  NSArray+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSArray+WizTools.h"

@implementation NSMutableArray (WizTools)
- (void) addObjectUnique:(id)object
{
    for (id each in self) {
        if ([object isEqual:each]) {
            return;
        }
    }
    [self addObject:object];
}
@end
