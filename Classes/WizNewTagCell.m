//
//  WizNewTagCell.m
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizNewTagCell.h"

@implementation WizNewTagCell
@synthesize textField;
- (void) dealloc
{
    self.textField = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSString* newTagRemindText = NSLocalizedString(@"Add", nil);
        UITextField* newTagTextField = [[UITextField alloc] init];
        newTagTextField.frame= CGRectMake(0.0, 0.0, 320, 44);
        UIFont* newTagLabelFont = [UIFont systemFontOfSize:14];
        UILabel* newTagLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 10, [newTagRemindText sizeWithFont:newTagLabelFont].width+20, 44)];
        [newTagLabel setFont:newTagLabelFont];
        newTagTextField.leftViewMode = UITextFieldViewModeAlways;
        newTagTextField.leftView = newTagLabel;
        newTagLabel.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        newTagLabel.text = newTagRemindText; 
        newTagLabel.textAlignment = UITextAlignmentCenter;
        UIImageView* newTagImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tree_view_icon_list_collapse"]];
        newTagTextField.rightView = newTagImage;
        newTagTextField.rightViewMode = UITextFieldViewModeAlways;
        newTagTextField.enabled = NO;
        [self.contentView addSubview:newTagTextField];
        newTagTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textField =newTagTextField;
        [newTagTextField release];
        [newTagImage release];
        [newTagLabel release];
    }
    return self;
}
- (void) setTextFieldText:(NSString*)str
{
    NSString* textFieldText = [NSString stringWithFormat:@"  %@%@%@"
                               ,NSLocalizedString(@"\"", nil)
                               ,str
                               ,NSLocalizedString(@"\"", nil)];
    self.textField.text = textFieldText;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
