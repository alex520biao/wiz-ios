//
//  WizFeedBackViewController.h
//  Wiz
//
//  Created by wiz on 12-2-14.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizFeedBackViewController : UIViewController
{
    UITextView* bodyTextView;
    UITextField* titleTextField;
}
@property (nonatomic, retain) UITextView* bodyTextView;
@property (nonatomic, retain) UITextField* titleTextField;
@end
