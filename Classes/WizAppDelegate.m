//
//  WizAppDelegate.m
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "WizAppDelegate.h"
#import "Globals/WizGlobalData.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "Globals/WizGlobals.h"
#import "Globals/WizSettings.h"
#import "LoginViewController.h"
#import "WizPadLoginViewController.h"
#import "WizPadMainViewController.h"
#import "UIView-TagExtensions.h"
#import "WizIndex.h"
#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"

@implementation WizAppDelegate

@synthesize window;
@synthesize navController;

@synthesize splitViewController;
@synthesize rootViewController;
@synthesize detailViewController;


#pragma mark -
#pragma mark Application lifecycle
- (void) selecteAccount:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
	//
	NSString* accountUserId = [userInfo valueForKey:@"accountUserId"];
    
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    
    if (![index isOpened])
    {
        if (![index open])
        {
            [WizGlobals reportErrorWithString:NSLocalizedString(@"Failed to open account data!", nil)];
            //
            return;
        }
    }
    WizPadMainViewController* pad = [[WizPadMainViewController alloc] init];
    pad.accountUserId = accountUserId;
    [self.navController pushViewController:pad animated:YES];
    [pad release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	UINavigationController* root = [[UINavigationController alloc] init];
    self.navController = root;
    [window addSubview:self.navController.view];
    [root release];
	if (WizDeviceIsPad())
	{
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selecteAccount:) name:@"didAccountSelect" object:nil];
        
        WizPadLoginViewController* pad = [[WizPadLoginViewController alloc] init];
        [self.navController pushViewController:pad animated:YES];
        pad.view.tag = 109;
        [pad release];
	}
	else
	{
        LoginViewController* login = [[WizGlobalData sharedData] wizMainLoginView:DataMainOfWiz];
        [self.navController pushViewController:login animated:YES];
	}
    [self.window makeKeyAndVisible];
    return YES;
}


- (void) didAccountSelect: (NSNotification*)nc
{
	NSDictionary* userInfo = [nc userInfo];
	//
	NSString* accountUserId = [userInfo valueForKey:@"accountUserId"];
	//
	[rootViewController setAccount:accountUserId];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
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
    [self.navController presentModalViewController:nav animated:YES];
    [check release];
    [nav release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkProtectPassword:) name:MessageOfProtectPasswordInputEnd object:nil];
}
- (void)applicationWillEnterForeground:(UIApplication *)application 
{
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSString* appVersion = [WizSettings wizIosAppVersion];
    if (appVersion == nil || [appVersion isEqualToString:@""] || ![appVersion isEqualToString:WizIosAppVersionKeyString]) {
        [WizSettings setAccountProtectPassword:@""];
        [WizSettings setWizIosAppVersion:WizIosAppVersionKeyString];
        return;
    }
    NSString* protectPw = [WizSettings accountProtectPassword];
    if (protectPw != nil && ![protectPw isEqualToString:@""]) {
        [self accountProtect];
    }
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


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
