//
//  WizIphoneLoginViewController.h
//  Wiz
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizIphoneLoginViewController : UIViewController
{
    @private
    UIButton* checkExistAccountsButton;
}
- (IBAction)signInAccount:(id)sender;
- (IBAction)registerAccount:(id)sender;
@end
