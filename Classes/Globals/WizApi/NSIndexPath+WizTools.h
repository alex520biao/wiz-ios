//
//  NSIndexPath+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (WizTools)
- (BOOL) isEqualToSectionAndRow:(NSInteger)section row:(NSInteger)row;
@end
