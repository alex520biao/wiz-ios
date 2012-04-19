//
//  WizVerifyAccount.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizApi.h"

@protocol WizVerifyAccountDeletage <NSObject>
- (void) didVerifyAccountSucceed;
- (void) didVerifyAccountFaild;
@end

@interface WizVerifyAccount : WizApi {
	BOOL busy;
    NSString* accountUserId;
    NSString* accountPassword;
    id<WizVerifyAccountDeletage> verifyDelegate;
}
@property (readonly) BOOL busy;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
@property (retain, nonatomic) id <WizVerifyAccountDeletage> verifyDelegate;
-(void) onError: (id)retObject;
-(void) onClientLogin: (id)retObject;
-(void) onClientLogout: (id)retObject;
-(BOOL) verifyAccount;
@end
