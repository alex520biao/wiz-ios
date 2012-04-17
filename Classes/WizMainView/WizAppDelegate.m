//
//  WizAppDelegate.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//
#import "WizAbstractCache.h"
#import "WizAppDelegate.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "WizIphoneLoginViewController.h"
#import "WizPadLoginViewController.h"
#import "WizPadMainViewController.h"
#import "UIView-TagExtensions.h"
#import "WizIndex.h"
#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "WizSync.h"
#import "NSDate-Utilities.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#import "WizNotification.h"
//#import "WizTestFlight.h"
#ifdef WIZTESTFLIGHTDEBUG
//#import "TestFlight.h"
#endif
#define WizAbs(x) x>0?x:-x
@implementation WizAppDelegate
@synthesize window;
@synthesize navController;
- (void) dealloc
{
    [navController release];
    [window release];
    [super dealloc];
}
#pragma mark -
#pragma mark Application lifecycle

- (void) initRootNavigation
{
    [WizGlobals toLog:@"dd"];
    [WizNotificationCenter removeObserver:self];
    UINavigationController* root = [[UINavigationController alloc] init];
    self.navController = root;
    if (WizDeviceIsPad())
    {
        WizPadLoginViewController* pad = [[WizPadLoginViewController alloc] init];
        [self.navController pushViewController:pad animated:NO];
        [pad release];
    }
    else
    {
        WizIphoneLoginViewController* login = [[WizIphoneLoginViewController alloc] initWithNibName:@"WizIphoneLoginViewController" bundle:nil];
        [self.navController pushViewController:login animated:NO];
        [login release];
    }

    [window addSubview:self.navController.view];
    [root release];
    [self.window makeKeyAndVisible];
}

- (void) encryptPasswordV320
{
    NSArray* arr = [[NSArray alloc] initWithArray:[WizSettings accounts]];
    for (int i = 0; i < [arr count]; i++) {
        NSString* account = [WizSettings accountUserIdAtIndex:arr index:i];
        NSString* password = [WizSettings accountPasswordAtIndex:arr index:i];
        NSLog(@"account %@ password %@",account, password);
        if (![WizGlobals checkPasswordIsEncrypt:password])
        {
            NSLog(@"change");
            [WizSettings changeAccountPassword:account password:password];
        }
    }
    [arr release];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self encryptPasswordV320];
    [self initRootNavigation];
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {

}




- (void) checkProtectPassword:(NSNotification*)nc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfProtectPasswordInputEnd object:nil];
    NSDictionary* userInfo = [nc userInfo];
    NSString* password = [userInfo valueForKey:TypeOfProtectPassword];
    NSString* protectPw = [WizSettings accountProtectPassword];
    if (![password isEqualToString:protectPw] ) {
        [self accountProtect];
    }
}
- (void) accountProtect
{
    WizCheckProtectPassword* check = [[WizCheckProtectPassword alloc] init];
    check.willMakeSure = NO;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:check];
    nav.view.frame = CGRectMake(0.0, 0.0, 320, 480);
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.navController presentModalViewController:nav animated:NO];
    [check release];
    [nav release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkProtectPassword:) name:MessageOfProtectPasswordInputEnd object:nil];
}
- (void)applicationWillEnterForeground:(UIApplication *)application 
{
    
}
- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[WizAbstractCache shareCache] didReceivedMenoryWarning];
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (WizAbs([[WizSettings lastActiveTime] timeIntervalSinceNow]) > 1800 ) {
        for (int i = 0; i < [[WizSettings accounts] count]; i++) {
            NSString* userId = [WizSettings accountUserIdAtIndex:[WizSettings accounts] index:i];
            [[WizGlobalData sharedData] removeAccountData:userId];
        }
    }
    NSString* protectPw = [WizSettings accountProtectPassword];
    if (protectPw != nil && ![protectPw isEqualToString:@""]) {
        [self accountProtect];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [WizSettings setLastActiveTime];
    [[WizGlobalData sharedData] stopSyncing];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[WizGlobalData deleteShareData];
}


#pragma mark -
#pragma mark Memory management



- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString* defaultAccount = [[WizGlobalData sharedData] activeAccountUserId];
    if (defaultAccount == nil || [defaultAccount isEqualToString:@""]) {
        return NO;
    }
    if (url != nil && [url isFileURL]) {
        NSString* filePath = [url path];
        NSArray* breakFilePath = [filePath componentsSeparatedByString:@"/"];
        NSString* fileName = [breakFilePath lastObject];
        WizIndex* index = [[WizGlobalData sharedData] indexData:defaultAccount];
        NSString* tempFilePath =[WizGlobals getAttachmentTempFilePath:defaultAccount];
        NSString* toFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        NSURL* toUrl = [NSURL fileURLWithPath:toFilePath];
        NSError* error = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:toUrl error:&error]) {
            [WizGlobals reportError:error];
            return NO;
        }
        NSString* documentGUID = [[index newDocumentWithOneAttachment:toUrl] autorelease];
        if (documentGUID == nil) {
            return NO;
        }
        [WizNotificationCenter postNewDocumentMessage:documentGUID];
        return YES;
    }
return NO;
}

@end
