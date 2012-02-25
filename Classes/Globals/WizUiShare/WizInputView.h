//
//  WizInputView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizInputView : UIView
{
    UIImageView* backgroundView;
    UILabel* nameLable;
    UITextField* textInputField;
}
@property (nonatomic, retain) UIImageView* backgroundView;
@property (nonatomic, retain) UILabel* nameLable;
@property (nonatomic, retain) UITextField* textInputField;

- (id) initWithFrame:(CGRect)frame title:(NSString*)title placeHoder:(NSString*)placeHoder;
@end
