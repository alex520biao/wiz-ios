//
//  WizVerifyAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizVerifyAccount.h"
#import "WizSettings.h"
#import "WizAccountManager.h"
@implementation WizVerifyAccount
@synthesize accountPassword;
@synthesize accountUserId;
@synthesize verifyDelegate;
- (void) dealloc
{
    [accountUserId release];
    [accountPassword release];
    [verifyDelegate release];
    [super dealloc];
}
-(void) onError: (id)retObject
{
    [self.verifyDelegate didVerifyAccountFaild];
	[WizGlobals reportError:retObject];
	busy = NO;
}
-(void) onClientLogin: (id)retObject
{
    [self.verifyDelegate didVerifyAccountSucceed];
    if ([retObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary* userInfo = retObject;
        NSString* _token = [userInfo valueForKey:@"token"];
        NSURL* urlAPI = [[NSURL alloc] initWithString:[userInfo valueForKey:@"kapi_url"]];
        self.token = _token;
        self.apiURL = urlAPI;
        [urlAPI release];
        NSLog(@"%@",retObject);
        NSString* privateKbGuid = [userInfo valueForKey:@"kb_guid"];
        [[WizAccountManager defaultManager] updatePrivateGroups:privateKbGuid accountUserId:nil];
        [self callGetGroupKblist];
    }
}
- (void) onCallGetGropList:(id)retObject
{
    if ([retObject isKindOfClass:[NSArray class]]) {
        [[WizAccountManager defaultManager] updateGroups:retObject];
    }
    busy = NO;
}

-(void) onClientLogout: (id)retObject
{
	[super onClientLogout:retObject];
	busy = NO;
}


- (BOOL) verifyAccount
{
	if (self.busy)
		return NO;
	busy = YES;
    self.accountURL = [[WizSettings defaultSettings] wizServerUrl];
	return [self callClientLogin:self.accountUserId accountPassword:self.accountPassword];
}

@end
