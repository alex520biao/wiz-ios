//
//  WizRefreshToken.m
//  Wiz
//
//  Created by 朝 董 on 12-4-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizRefreshToken.h"
#import "WizNotification.h"

@implementation WizRefreshToken
- (BOOL) refresh
{
    return [self callClientLogin];
}
-(void) onClientLogin: (id)retObject
{
	if ([retObject isKindOfClass:[NSDictionary class]]) {
        [WizNotificationCenter postMessageRefreshToken:retObject];
    }
}
@end
