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
#import "WizIphoneLoginViewController.h"
#import "WizPadLoginViewController.h"
#import "UIView-TagExtensions.h"

#import "WizCheckProtectPassword.h"
#import "WizGlobalNotificationMessage.h"
#import "NSDate-Utilities.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadNotificationMessage.h"
#import "WizNotification.h"
#import "WizAccountManager.h"
#import "WizSyncManager.h"
#import "WizFileManager.h"
#import "WizPasscodeViewController.h"
#import "WizSettings.h"
#import "WizPhoneEditorViewControllerL5.h"
#import "WizPhoneEditViewControllerM5.h"
#import "WizPadEditViewControllerL5.h"
#import "WizPadEditViewControllerM5.h"
#import <Crashlytics/Crashlytics.h>

#define WizYouMengAppKey  @"5022381b527015151f00000d"

#define WizAbs(x) x>0?x:-x
@interface WizAppDelegate()
{
    UILabel* syncLabel;
}
@property (nonatomic, retain) UILabel* syncLabel;
@end

@implementation WizAppDelegate
@synthesize syncLabel;
@synthesize window;
- (void) dealloc
{
    [syncLabel release];
    [window release];
    [super dealloc];
}
#pragma mark -
#pragma mark Application lifecycle

- (void) tryResumeLastEdition
{
    if (![WizGlobals checkLastEditingSaved]) {
        WizEditorBaseViewController* edit = nil;
        if ([WizGlobals WizDeviceVersion]  < 5) {
            if ([WizGlobals WizDeviceIsPad]) {
                edit = [[WizPadEditViewControllerL5 alloc] init];
            }
            else
            {
                edit = [[WizPhoneEditorViewControllerL5 alloc] init];
            }
        }
        else
        {
            if ([WizGlobals WizDeviceIsPad]) {
                edit = [[WizPadEditViewControllerM5 alloc] init];
            }
            else
            {
                 edit = [[WizPhoneEditViewControllerM5 alloc] init];
                
            }
        }
        
        //
        [edit resumeLastEditong];
        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:edit];
        [edit release];
        if ([WizGlobals WizDeviceIsPad]) {
            nav.modalPresentationStyle = UIModalPresentationPageSheet;
            nav.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
        }
        [self.window.rootViewController presentModalViewController:nav animated:YES];
        
        [nav release];
    }
}

- (void) initRootNavigation
{
    [WizNotificationCenter removeObserver:self];
    UINavigationController* root = [[UINavigationController alloc] init];
    if ([WizGlobals WizDeviceIsPad])
    {
        WizPadLoginViewController* pad = [[WizPadLoginViewController alloc] init];
        [root pushViewController:pad animated:NO];
        [pad release];
    }
    else
    {
        WizIphoneLoginViewController* login = [[WizIphoneLoginViewController alloc] initWithNibName:@"WizIphoneLoginViewController" bundle:nil];
        [root pushViewController:login animated:NO];
        [login release];
    }
    window.rootViewController = root;
    [root release];
    [self.window makeKeyAndVisible];
    [self tryResumeLastEdition];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Crashlytics startWithAPIKey:@"ce913e9eceb62de8dd75d62054dad6096abf38c2"];
    [self initRootNavigation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}
- (void) accountProtect
{
    WizPasscodeViewController* check = [[WizPasscodeViewController alloc] init];
    check.checkType = WizcheckPasscodeTypeOfCheck;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:check];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.window.rootViewController presentModalViewController:nav animated:NO];
    [check release];
    [nav release];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if ([[WizSettings defaultSettings] isPasscodeEnable])
    {
        [self accountProtect];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}


#pragma mark -
#pragma mark Memory management

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString* defaultAccount = [[WizAccountManager defaultManager] activeAccountUserId];
    if (defaultAccount == nil || [defaultAccount isEqualToString:@""]) {
        return NO;
    }
    if (url != nil && [url isFileURL]) {
        NSString* filePath = [url path];
        NSString* fileName = [filePath fileName];
        NSString* tempFilePath =[[WizFileManager shareManager] attachmentTempDirectory];
        NSString* toFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        NSURL* toUrl = [NSURL fileURLWithPath:toFilePath];
        NSError* error = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:toUrl error:&error]) {
            [WizGlobals reportError:error];
            return NO;
        }
        WizDocument* doc = [[WizDocument alloc] init];
        doc.title = fileName;
        NSMutableArray* arr = [NSMutableArray array];
        [arr addAttachmentBySourceFile:toFilePath];
        [doc saveWithData:nil attachments:arr];
        [doc release];
        return YES;
    }

    return NO;
}

@end

