//
//  NSArray+WizSetting.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (WizSetting)
+ (NSArray*) imageQulityArray;
+ (NSArray*) downloadDurationArray;
- (NSUInteger) wizSettingValueAtIndex:(NSUInteger)index;
- (NSString*) wizSettingDescriptionAtIndex:(NSUInteger)index;
- (NSInteger) indexForWizSettingValue:(NSInteger)value;
+ (NSArray*) tableViewOptions;
@end
