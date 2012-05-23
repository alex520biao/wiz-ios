//
//  WizAppDelegate.h
//  Wiz
//
//  Created by Wei Shijun on 3/7/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSyncDescriptionDelegate.h"
@class UINavigationController;
@interface WizAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;
- (void) accountProtect;
@end

