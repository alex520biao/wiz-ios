//
//  WizGetLogKeys.m
//  WizLib
//
//  Created by 朝 董 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGetLogKeys.h"

@implementation WizGetLogKeys
- (void) onClientLogin:(id)ret{
    [WizNotificationCenter postRefreshLogKeys:ret];
}
-(BOOL) getLoginKeys;{
    return [self callClientLogin];
}
@end
