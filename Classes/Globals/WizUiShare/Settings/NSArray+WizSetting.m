//
//  NSArray+WizSetting.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSArray+WizSetting.h"

#define WizSettingValue     @"WizSettingValue"
#define WizSettingDescription     @"WizSettingDescription"
@implementation NSArray (WizSetting)
- (NSInteger) imageQulityFormIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            return 300;
            break;
        case 1:
            return 750;
            break;
        case 2:
            return 1024;
            break;
        default:
            break;
    }
    return 0;
}
+ (NSArray*) imageQulityArray
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Original", nil),WizSettingDescription, [NSNumber numberWithInt:1024], WizSettingValue, nil],
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"High", nil),WizSettingDescription, [NSNumber numberWithInt:1024], WizSettingValue ,nil] ,
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Medium", nil),WizSettingDescription, [NSNumber numberWithInt:600], WizSettingValue, nil],
            [NSDictionary dictionaryWithObjectsAndKeys: NSLocalizedString(@"Low", nil),WizSettingDescription, [NSNumber numberWithInt:300], WizSettingValue, nil] ,
            nil];

}
+ (NSArray*) downloadDurationArray
{
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Does not download any notes automatic", nil),WizSettingDescription, [NSNumber numberWithInt:0], WizSettingValue ,nil] ,
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Download notes within a day", nil),WizSettingDescription, [NSNumber numberWithInt:1], WizSettingValue ,nil] ,
            [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Download notes within a week", nil),WizSettingDescription, [NSNumber numberWithInt:7], WizSettingValue ,nil] ,
            [NSDictionary dictionaryWithObjectsAndKeys: NSLocalizedString(@"Download all notes", nil),WizSettingDescription, [NSNumber numberWithInt:1000], WizSettingValue, nil] ,
            nil];
}
- (NSUInteger) wizSettingValueAtIndex:(NSUInteger)index
{
    if ([self count] > index) {
        NSDictionary* dic = [self objectAtIndex:index];
        return [[dic valueForKey:WizSettingValue] intValue];
    }
    return 0;
}
- (NSString*) wizSettingDescriptionAtIndex:(NSUInteger)index
{
    if ([self count] > index) {
        NSDictionary* dic = [self objectAtIndex:index];
        return [dic valueForKey:WizSettingDescription];
    }
    return nil;
}

- (NSInteger) indexForWizSettingValue:(NSInteger)value
{
    for (int i=0; i < [self count]; i++) {
        NSDictionary* dic = [self objectAtIndex:i];
        NSInteger v1 = [[dic valueForKey:WizSettingValue] intValue];
        if (v1 == value) {
            return i;
        }
    }
    return 0;
}

+ (NSArray*) tableViewOptions
{
    return [NSArray arrayWithObjects:
           [NSDictionary dictionaryWithObjectsAndKeys:WizStrDateModified,WizSettingDescription, [NSNumber numberWithInt:1], WizSettingValue ,nil],
           [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Date modified (Reverse)",nil),WizSettingDescription, [NSNumber numberWithInt:2], WizSettingValue ,nil] ,
           [NSDictionary dictionaryWithObjectsAndKeys:WizStrTitle,WizSettingDescription, [NSNumber numberWithInt:3], WizSettingValue ,nil],
           [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Title (Reverse)", nil),WizSettingDescription, [NSNumber numberWithInt:4], WizSettingValue, nil] ,
           [NSDictionary dictionaryWithObjectsAndKeys:WizStrDateCreated,WizSettingDescription, [NSNumber numberWithInt:5], WizSettingValue ,nil] ,
           [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(@"Date created (Reverse)", nil),WizSettingDescription, [NSNumber numberWithInt:6], WizSettingValue, nil] ,
           nil];
}

@end