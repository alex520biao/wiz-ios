//
//  WizCreateAccount.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "WizApi.h"

@protocol WizCreateAccountDelegate <NSObject>

- (void) didCreateAccountSucceed;
- (void) didCreateAccountFaild;

@end

@interface WizCreateAccount : WizApi {
    NSString* accountUserId;
    NSString* accountPassword;
    id<WizCreateAccountDelegate> createAccountDelegate;
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* accountPassword;
@property (nonatomic, retain) id<WizCreateAccountDelegate> createAccountDelegate;
-(BOOL) createAccount;
@end
