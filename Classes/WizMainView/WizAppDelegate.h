//
//  WizAppDelegate.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;
@class DetailViewController;
@class SplashViewController;
@class UINavigationController;
@interface WizAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController* navController;
	UISplitViewController *splitViewController;
    RootViewController *rootViewController;
    DetailViewController *detailViewController;
	SplashViewController* splashViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

- (void) didAccountSelect: (NSNotification*)nc;
- (void) accountProtect;


@end

