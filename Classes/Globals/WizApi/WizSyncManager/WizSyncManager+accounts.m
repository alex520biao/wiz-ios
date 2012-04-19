//
//  WizSyncManager+accounts.m
//  Wiz
//
//  Created by 朝 董 on 12-4-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncManager+accounts.h"
#import "WizApi.h"

@interface WizSyncManager()
{
    id<WizVerifyAccountDeletage>  delegate;
    WizApi* api;
}
@property (retain, nonatomic) id<WizVerifyAccountDeletage>  delegate;
@end

@implementation WizSyncManager (accounts)
- (void) verifyAccount:(NSString*)accountUserId    password:(NSString*)password
{
    
}
@end
