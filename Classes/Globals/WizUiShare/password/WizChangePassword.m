//
//  WizChangePassword.m
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizChangePassword.h"
#import "WizChangePasswordController.h"
@implementation WizChangePassword

@synthesize busy;
@synthesize owner;
-(void) onError: (id)retObject
{
	[super onError:retObject];
	if ([self.owner isKindOfClass:[WizChangePasswordController class]]) {
        WizChangePasswordController* change = (WizChangePasswordController*)self.owner;
        [change.waitAlert dismissWithClickedButtonIndex:0 animated:YES];
        change.waitAlert = nil;
    }
	busy = NO;
}
- (void) onChangePassword:(id)retObject
{
    busy = NO;
}
- (BOOL) changeAccountPassword:(NSString *)password
{
    return [self callChangePassword:password];
}
@end
