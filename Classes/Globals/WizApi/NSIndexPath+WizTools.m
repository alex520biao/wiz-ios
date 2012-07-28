//
//  NSIndexPath+WizTools.m
//  Wiz
//
//  Created by 朝 董 on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSIndexPath+WizTools.h"

@implementation NSIndexPath (WizTools)
- (BOOL) isEqualToSectionAndRow:(NSInteger)section row:(NSInteger)row
{
    if (self.section  == section && self.row == row) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
