//
//  WizSwitchCell.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizSettingSwitchView.h"

@interface WizSwitchCell : UITableViewCell
{
    WizSettingSwitchView* settingView;
}
@property (nonatomic, retain) WizSettingSwitchView* settingView;
+ (WizSwitchCell*) switchCell;
@end
