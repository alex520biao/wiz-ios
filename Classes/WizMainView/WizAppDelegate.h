//
//  WizAppDelegate.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UINavigationController;
@interface WizAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController* navController;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navController;
- (void) accountProtect;
@end

