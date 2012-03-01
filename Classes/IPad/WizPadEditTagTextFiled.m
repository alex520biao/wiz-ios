//
//  WizPadEditTagTextFiled.m
//  Wiz
//
//  Created by wiz on 12-2-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadEditTagTextFiled.h"
#import "UIBadgeView.h"
#import "CommonString.h"
@implementation WizPadEditTagTextFiled

- (id)init
{
    self = [super init];
    if (self) {

        UIFont* font = [UIFont systemFontOfSize:17];
        NSString* tagRemindText = [NSString stringWithFormat:@"%@:",WizStrTags];
        UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, [tagRemindText sizeWithFont:font].width + 10, 44)];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.leftView = tagLabel;
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        tagLabel.font = font;
        tagLabel.textAlignment = UITextAlignmentCenter;
        tagLabel.text = tagRemindText;
        [self setBackgroundColor:[UIColor whiteColor]];
        tagLabel.textColor = [UIColor grayColor];
        UIButton* tagButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [tagButton addTarget:self action:@selector(tagViewSelected) forControlEvents:UIControlEventTouchUpInside];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.rightView = tagButton;
        [tagLabel release];
    }
    
    return self;
}

- (void) addTag:(NSString*)tagName
{
    UIFont* font = [UIFont systemFontOfSize:17];
    UIBadgeView* tagLabel = [[UIBadgeView alloc] initWithFrame:CGRectMake(self.leftView.frame.size.width+10, 0.0, [tagName sizeWithFont:font].width+10, 44)];
    tagLabel.badgeString = tagName;
    [self.leftView addSubview:tagLabel];
    [tagLabel release];
}
@end
