//
//  WizAddAcountViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizVerifyAccount.h"
@class WizInputView;
@interface WizAddAcountViewController : UIViewController <UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,WizVerifyAccountDeletage>

@end
