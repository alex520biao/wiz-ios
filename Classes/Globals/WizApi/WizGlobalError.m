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
+ (NSError*) canNotResloceError
{
    return [NSError errorWithDomain:WizErrorDomain code:WizCanNoteResloceErrorCode userInfo:nil];
}
@end
