//
//  WizActiveUserManager.m
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizActiveUserManager.h"
#import "WizApi.h"
#import "WizLogIn.h"
@interface WizActiveUserManager()
{
    NSString* activeAccountUserID;
    NSString* kbGuid;
    NSString* token;
    NSURL* apiUrl;
}
@property (nonatomic, retain) NSString* activeAccountUserID;
@property (nonatomic, retain) NSString* kbGuid;
@property (nonatomic, retain) NSString* token;
@property (nonatomic, retain) NSURL* apiUrl;
@end

@implementation WizActiveUserManager
@synthesize activeAccountUserID;
@synthesize kbGuid;
@synthesize token;
@synthesize apiUrl;
static WizActiveUserManager* defaultManager;

+ (WizActiveUserManager*) defaultManager
{
    if (defaultManager == nil) {
        defaultManager = [[WizActiveUserManager alloc] init];
    }
    return defaultManager;
}
+ (void) deleteDefaultManager
{
    if (defaultManager != nil) {
        [defaultManager release];
        defaultManager = nil;
    }
}
+ (void) registerActive:(NSString*)userId
{
    [[WizActiveUserManager defaultManager] setActiveAccountUserID:userId];
}
+ (NSString*) activeAccountUserId
{
    return [[WizActiveUserManager defaultManager] activeAccountUserID];
}
+ (void) setActiveApiInfo:(NSString*)kbguid  token:(NSString*)token apiUrl:(NSURL*)apiUrl
{
    WizActiveUserManager* maneger = [WizActiveUserManager defaultManager];
    if (!token || !kbguid || !apiUrl) {
        WizLogIn* logIn = [[WizLogIn alloc] initWithAccount:maneger.activeAccountUserID password:nil];
    }
    maneger.token = token;
    maneger.apiUrl = apiUrl;
    maneger.kbGuid = kbguid;
}
+ (void) setWizApiInfo:(WizApi*)api
{
    WizActiveUserManager* maneger = [WizActiveUserManager defaultManager];
    if (!maneger.apiUrl || !maneger.kbGuid || !maneger.token) {
        
    }
    api.apiURL = maneger.apiUrl;
    api.token = maneger.token;
    api.kbguid = maneger.kbGuid;
}
@end
