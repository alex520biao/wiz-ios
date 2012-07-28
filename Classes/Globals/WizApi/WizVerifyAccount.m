//
//  WizVerifyAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizVerifyAccount.h"
#import "WizSettings.h"
#import "Reachability.h"
#import "WizDbManager.h"

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
{   busy = NO;
    [self.verifyDelegate didVerifyAccountSucceed];
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
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
       
        id<WizSettingsDbDelegate> dataBase = [[WizDbManager shareDbManager] getWizSettingsDataBase];
        WizAccount* existAccount = [dataBase accountFromUserId:self.accountUserId];
        if (existAccount) {
            NSString* encryptPassword = self.accountPassword;
            if (![WizGlobals checkPasswordIsEncrypt:self.accountPassword]) {
                encryptPassword = [WizGlobals encryptPassword:encryptPassword];
            }
            NSString* oldPassword = existAccount.password;
            if (![WizGlobals checkPasswordIsEncrypt:oldPassword])
            {
                oldPassword = [WizGlobals encryptPassword:oldPassword];
            }
            if([oldPassword isEqualToString:encryptPassword])
            {
                [self.verifyDelegate didVerifyAccountSucceed];
            }
            else
            {
                [WizGlobals reportError:[NSError errorWithDomain:WizErrorDomain code:6666 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"The password is wrong!", nil) forKey:NSLocalizedDescriptionKey]]];
                [self.verifyDelegate didVerifyAccountFaild];
            }
        }
        else
        {
            [WizGlobals reportError:[NSError errorWithDomain:WizErrorDomain code:6666 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"There is no internet connection and it can't login!", nil) forKey:NSLocalizedDescriptionKey]]];
            [self.verifyDelegate didVerifyAccountFaild];
        }
         busy = NO;
        return YES;
    }
	return [self callClientLogin:self.accountUserId accountPassword:self.accountPassword];
}

@end
