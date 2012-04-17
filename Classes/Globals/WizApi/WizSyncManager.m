//
//  WizSyncManager.m
//  Wiz
//
//  Created by 朝 董 on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncManager.h"
#import "WizGlobalData.h"

@interface WizSyncManager ()
{
    NSMutableArray* downloadQueque;
    NSMutableArray* uploadQueque;
    NSMutableArray* errorQueque;
}
@end

@implementation WizSyncManager
+ (id) shareManager
{
    return [[WizGlobalData sharedData] syncManger];
}
@end
