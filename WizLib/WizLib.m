//
//  WizLib.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizLib.h"
#import "WizAccountManager.h"
#import "WizDbManager.h"

@implementation WizLib
+ (void) addAccount:(NSString *)userId password:(NSString *)password
{
    [WizDbManager shareDbManager];
    [WizAccountManager addAccount:userId password:password];
}
+ (void) registeAccount:(NSString*)userId
{
    [WizAccountManager registerActiveAccount:userId];
    [[WizSyncManager shareManager] refreshLogInfo];
    [[WizSyncManager shareManager] startSyncAccountInfo];
}
@end
