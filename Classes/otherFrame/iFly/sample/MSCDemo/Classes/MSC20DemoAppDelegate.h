//
//  MSC20DemoAppDelegate.h
//  MSC20Demo
//
//  Created by msp on 12-9-12.
//  Copyright 2012 IFLYTEK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface MSC20DemoAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
	RootViewController *_rootViewController;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

