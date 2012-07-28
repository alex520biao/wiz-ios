//
//  WizUserSettingCell.m
//  Wiz
//
//  Created by wiz on 12-2-13.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizUserSettingCell.h"

@implementation WizUserSettingCell
@synthesize nameLabel;
@synthesize valueLabel;

- (void) dealloc
{
    [nameLabel release];
    [valueLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel* nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 300, 40)];
        UILabel* valueLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(100, 5, 200, 40)];
        [self addSubview:nameLabel_];
        self.nameLabel = nameLabel_;
        [nameLabel_ release];
        [self addSubview:valueLabel_];
        self.valueLabel = valueLabel_;
        [valueLabel_ release];
        valueLabel.textColor = [UIColor grayColor];
        nameLabel.textAlignment = UITextAlignmentLeft;
        valueLabel.textAlignment = UITextAlignmentRight;
        [valueLabel setFont:[UIFont systemFontOfSize:13]];
        nameLabel.font = [UIFont systemFontOfSize:15];
        nameLabel.backgroundColor = [UIColor clearColor];
        valueLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
