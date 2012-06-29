//
//  WizCreateAccount.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizCreateAccount.h"
#import "WizSettings.h"


@implementation WizCreateAccount
@synthesize accountPassword;
@synthesize accountUserId;
@synthesize createAccountDelegate;
- (void) doErrorCreate
{   NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self.createAccountDelegate didCreateAccountFaild];
    [pool drain];
}
-(void) onError: (id)retObject
{
	[WizGlobals reportError:retObject];
	busy = NO;
    [self  performSelectorOnMainThread:@selector(doErrorCreate) withObject:nil waitUntilDone:YES];
}
-(void) onCreateAccount: (id)retObject
{
	busy = NO;
    NSLog(@"ret %@",retObject);
    [self performSelectorOnMainThread:@selector(doCreateAccountOnMainProcess) withObject:nil waitUntilDone:YES];
}
- (void) doCreateAccountOnMainProcess
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [self.createAccountDelegate didCreateAccountSucceed];
    [pool drain];
}
- (BOOL) createAccount
{
	if (self.busy)
		return NO;
	busy = YES;
    self.accountURL = [[WizSettings defaultSettings] wizServerUrl];
	return [self callCreateAccount:self.accountUserId password:self.accountPassword];
}
@end
