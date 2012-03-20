//
//  WizAppDelegate.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizAppDelegate.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizSettings.h"
#import "LoginViewController.h"
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
#import "PickViewController.h"
#import "WizNotification.h"
//#import "WizTestFlight.h"
#ifdef WIZTESTFLIGHTDEBUG
//#import "TestFlight.h"
#endif
#define WizAbs(x) x>0?x:-x
@interface WizAppDelegate ()
+ (UIViewController*) iphoneBackController;
@end
@implementation WizAppDelegate
@synthesize loginController;
@synthesize window;
@synthesize navController;
static UIViewController* iphoneBackController;
+ (UIViewController*) iphoneBackController
{
    if (iphoneBackController == nil) {
        UIImageView* back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
        iphoneBackController = [[UIViewController alloc] init];
        back.frame = CGRectMake(0.0, 0.0, 320, 480);
        [iphoneBackController.view addSubview:back];
        [back release];
    }
    return iphoneBackController;
}
- (void) dealloc
{
    self.navController = nil;
    self.window = nil;
    self.loginController = nil;
    [super dealloc];
}
#pragma mark -
#pragma mark Application lifecycle
- (void) changeAccount
{
    [self.navController popToRootViewControllerAnimated:NO];
    if (WizDeviceIsPad())
    {

        WizPadLoginViewController* pad = [[WizPadLoginViewController alloc] init];
        UINavigationController* con = [[UINavigationController alloc] initWithRootViewController:pad];
        [self.navController presentModalViewController:con animated:NO];
        [pad release];
        [con release];
    }
    else
    {
        LoginViewController* login = [[LoginViewController alloc] init];
        UINavigationController* con = [[UINavigationController alloc] initWithRootViewController:login];
        [self.navController presentModalViewController:con animated:YES];
        [login release];
        [con release];
    }
}
- (void) initRootNavigation
{
    [WizNotificationCenter removeObserver:self];
    [WizNotificationCenter addObserverWithKey:self selector:@selector(selecteAccount:) name:MessageTypeOfDidSelectedAccount];
    [WizNotificationCenter addObserverForChangeAccount:self selector:@selector(changeAccount)];
    UINavigationController* root = [[UINavigationController alloc] init];
    self.navController = root;
    if (WizDeviceIsPad()) {
        UIViewController* con = [[UIViewController alloc] init];
        con.view.backgroundColor = [UIColor grayColor];
        [self.navController pushViewController:con animated:NO];
        [con release];
    }
    else {
        [self.navController pushViewController:[WizAppDelegate iphoneBackController] animated:NO];
    }
    [window addSubview:self.navController.view];
    [root release];
    [self.window makeKeyAndVisible];
}
- (void) selecteAccount:(NSNotification*)nc
{
	NSString* accountUserId = [WizNotificationCenter getDidSelectedAccountUserId:nc];
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:WizStrFailedtoopenaccountdata];
            return;
        }
    }
    if (WizDeviceIsPad()) {
        WizPadMainViewController* pad = [[WizPadMainViewController alloc] init];
        pad.accountUserId = accountUserId;
        [self.navController pushViewController:pad animated:YES];
        [pad release];
    }
    else {
        PickerViewController* pick =[[PickerViewController alloc] initWithUserID:accountUserId];
        [self.navController pushViewController:pick animated:YES];
        [pick release];
    }
}

- (void) selecteDefaultAccount
{
    NSArray* accounts = [WizSettings accounts];
    if ([accounts count] > 0) {
        NSString* defaultUserId = [WizSettings defaultAccountUserId];
        if (defaultUserId == nil || [defaultUserId isEqualToString:@""]) {
            [WizSettings setDefalutAccount:[WizSettings accountUserIdAtIndex:accounts index:0]];
            defaultUserId = [WizSettings defaultAccountUserId];
        }
        [WizNotificationCenter postDidSelectedAccountMessage:defaultUserId];
    }
    else {
        [WizNotificationCenter postChangeAccountMessage];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    [self initRootNavigation]; 
    [self selecteDefaultAccount];
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

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString* defaultAccount = [[WizGlobalData sharedData] activeAccountUserId];
    if (defaultAccount == nil || [defaultAccount isEqualToString:@""]) {
        return NO;
    }
    if (url != nil && [url isFileURL]) {
        NSString* filePath = url.absoluteString;
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
        NSString* documentGUID = [[index newDocumentWithOneAttachment:toFilePath] autorelease];
        if (documentGUID == nil) {
            return NO;
        }
        [WizNotificationCenter postNewDocumentMessage:documentGUID];
        return YES;
    }
return NO;
}

@end
