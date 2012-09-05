//
//  WizGlobalError.m
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGlobalError.h"

@implementation WizGlobalError
+ (NSError*) tokenUnActiveError
{
    return [NSError errorWithDomain:WizErrorDomain code:CodeOfTokenUnActiveError userInfo:nil];
}
+ (NSError*) cancelFixPasswordError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizErrorCodeCancelFixPassword userInfo:nil];
}
+ (NSString*) folderInvalidCharacterErrorString:(NSString*)errorText
{
    if (errorText) {
        errorText = [errorText stringReplaceUseRegular:@"[^[\\,/,:,<,>,*,?,\",&,\"]]" withString:@""];
    }
    return [NSString stringWithFormat:@"%@:\"%@\"",NSLocalizedString(@"Invalid character", nil),errorText];
}
+ (NSError*) folderInvalidCharacterError:(NSString*)errorText
{
    if (errorText) {
        errorText = [errorText stringReplaceUseRegular:@"[^[\\,/,:,<,>,*,?,\",&,\"]]" withString:@""];
    }
    return  [NSError errorWithDomain:WizErrorDomain code:9999 userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@:\"%@\"",NSLocalizedString(@"Invalid character", nil),errorText] forKey:NSLocalizedDescriptionKey]];
}

@end
