//
//  WizSettingsParentNavigationDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizSettingsParentNavigationDelegate <NSObject>
- (UINavigationController*) settingsViewControllerParentViewController;
- (void) willChangAccount;
@end
