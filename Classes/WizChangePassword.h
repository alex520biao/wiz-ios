//
//  WizChangePassword.h
//  Wiz
//
//  Created by wiz on 12-2-17.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"

@interface WizChangePassword : WizApi
{
    BOOL busy;
}
@property (readonly) BOOL busy;
- (void) onError:(id)retObject;
- (BOOL) changeAccountPassword:(NSString*)password;
- (void) onChangePassword:(id)retObject;
@end
