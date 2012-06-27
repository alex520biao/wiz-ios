//
//  NSArray+WizSetting.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
enum WizSettingKind {
    WizSetDownloadDurationCode = 4000,
    WizSetImageQulityCode = 4001,
    WizSetTableOption = 4002,
    WizSelectGroup  = 4003
};
@interface NSArray (WizSetting)
+ (NSArray*) imageQulityArray;
+ (NSArray*) downloadDurationArray;
- (NSUInteger) wizSettingValueAtIndex:(NSUInteger)index;
- (NSString*) wizSettingDescriptionAtIndex:(NSUInteger)index;
- (NSInteger) indexForWizSettingValue:(NSInteger)value;
+ (NSArray*) tableViewOptions;
- (NSString*) descriptionForWizSettingValue:(NSInteger)value;
+ (NSDictionary*) dictionaryForSettings:(id)value descriptor:(id)descripor;
- (NSString*)wizStringValueAtIndex:(NSUInteger)index;
@end
