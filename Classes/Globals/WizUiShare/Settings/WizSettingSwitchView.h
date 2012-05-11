//
//  WizSettingSwitchView.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizSettingSwitchView : UIView
{
    UILabel* nameLabel;
    UISwitch* valueSwitch;
}
@property (nonatomic ,retain) UILabel* nameLabel;
@property (nonatomic, retain) UISwitch* valueSwitch;
@end
