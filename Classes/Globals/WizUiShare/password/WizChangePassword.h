//
//  WizChangePassword.h
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"
#import "WizChangePasswordDelegate.h"
@interface WizChangePassword : WizApi
{
    BOOL busy;
    id <WizChangePasswordDelegate> changePasswordDelegate;
}
@property (readonly) BOOL busy;
@property (nonatomic, retain) id <WizChangePasswordDelegate> changePasswordDelegate;
- (void) onError:(id)retObject;
- (BOOL) changeAccountPassword:(NSString*)accountUserId  oldPassword:(NSString*)oldPassword newPassword:(NSString*)newPassword;
- (void) onChangePassword:(id)retObject;
@end
