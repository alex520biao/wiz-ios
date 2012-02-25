//
//  WizUserSettingCell.h
//  Wiz
//
//  Created by wiz on 12-2-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizUserSettingCell : UITableViewCell
{
    UILabel* nameLabel;
    UILabel* valueLabel;
}
@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UILabel* valueLabel;
@end
