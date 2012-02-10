//
//  WizVerifyAccount.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@interface WizVerifyAccount : WizApi {
	BOOL busy;
}

@property (readonly) BOOL busy;

-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout: (id)retObject;

-(BOOL) verifyAccount;


@end
