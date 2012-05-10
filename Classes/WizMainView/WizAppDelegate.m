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
#import "WizIphoneLoginViewController.h"
#import "WizPadLoginViewController.h"
#import "WizPadMainViewController.h"
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


//#import "WizTestFlight.h"
#ifdef WIZTESTFLIGHTDEBUG
//#import "TestFlight.h"
#endif
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
- (void) didChangedSyncDescription:(NSString *)description
{
//    if (description == nil || [description isBlock]) {
//        self.window.frame = CGRectMake(0.0, 0.0, 320, 480);
//    }
//    else {
//        self.window.frame = CGRectMake(0.0, 40, 320, 440);
//        self.syncLabel.text = description;
//    }
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
}

- (void) encryptPasswordV320
{
//    NSArray* arr = [[NSArray alloc] initWithArray:[WizSettings accounts]];
//    for (int i = 0; i < [arr count]; i++) {
//        NSString* account = [WizSettings accountUserIdAtIndex:arr index:i];
//        NSString* password = [WizSettings accountPasswordAtIndex:arr index:i];
//        NSLog(@"account %@ password %@",account, password);
//        if (![WizGlobals checkPasswordIsEncrypt:password])
//        {
//            NSLog(@"change");
//            [WizSettings changeAccountPassword:account password:password];
//        }
//    }
//    [arr release];
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
    NSString* protectPw = [[WizAccountManager defaultManager] accountProtectPassword];
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
    [self.window.rootViewController presentModalViewController:nav animated:NO];
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
    NSString* protectPw = [[WizAccountManager defaultManager] accountProtectPassword];
    if (protectPw != nil && ![protectPw isEqualToString:@""]) {
        [self accountProtect];
    }
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
//    [WizSettings setLastActiveTime];
//    [[WizGlobalData sharedData] stopSyncing];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[WizGlobalData deleteShareData];
}


#pragma mark -
#pragma mark Memory management

- (void) application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame
{
//    
//    if (newStatusBarFrame.origin.x == 0) {
//        if (newStatusBarFrame.origin.y == 0) {
//            if (newStatusBarFrame.size.width == 20) {
//                // 0 0 20 480
//                float rotateAngle = -M_PI/2;
//                CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
//                self.syncDescriptionWindow.frame = CGRectMake(0.0, 0.0, 20, 480);
//                self.syncDescriptionWindow.textLabel.transform = transform;
//            }
//            else {
//                // 0 0 320 20
//                float rotateAngle = 0;
//                CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
//                self.syncDescriptionWindow.textLabel.transform = transform;
//            }
//        }
//        else {
//            //0 460 320 20
//            float rotateAngle = M_PI/2;
//            CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
//            self.syncDescriptionWindow.textLabel.transform = transform;
//        }
//    }
//    else {
//        // 300 0 20 480
//        float rotateAngle = M_PI/2;
//        CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
//        self.syncDescriptionWindow.textLabel.transform = transform;
//    }
////    if (newStatusBarFrame.origin.x != 0) {
////        float rotateAngle = M_PI/2;
////        CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
////        self.syncDescriptionWindow.transform = transform;
////        self.syncDescriptionWindow.frame = CGRectMake(newStatusBarFrame.origin.x - newStatusBarFrame.size.width/2-10, 0, newStatusBarFrame.size.width, newStatusBarFrame.size.height);
////    }
////    else
////    {
////        float rotateAngle = -M_PI/2;
////        CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
////        self.syncDescriptionWindow.transform = transform;
////        self.syncDescriptionWindow.frame = CGRectMake(newStatusBarFrame.origin.x - newStatusBarFrame.size.width/2-10, 0, newStatusBarFrame.size.width, newStatusBarFrame.size.height);
////    }
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString* defaultAccount = [[WizAccountManager defaultManager] activeAccountUserId];
    if (defaultAccount == nil || [defaultAccount isEqualToString:@""]) {
        return NO;
    }
    if (url != nil && [url isFileURL]) {
        NSString* filePath = [url path];
        NSArray* breakFilePath = [filePath componentsSeparatedByString:@"/"];
        NSString* fileName = [breakFilePath lastObject];
        NSString* tempFilePath =[[WizFileManager shareManager] getAttachmentSourceFileName];
        NSString* toFilePath = [tempFilePath stringByAppendingPathComponent:fileName];
        NSURL* toUrl = [NSURL fileURLWithPath:toFilePath];
        NSError* error = nil;
        if (![[NSFileManager defaultManager] copyItemAtURL:url toURL:toUrl error:&error]) {
            [WizGlobals reportError:error];
            return NO;
        }
//        NSString* documentGUID = [[index newDocumentWithOneAttachment:toUrl] autorelease];
//        if (documentGUID == nil) {
//            return NO;
//        }
//        [WizNotificationCenter postNewDocumentMessage:documentGUID];
        return YES;
    }
return NO;
}

@end

