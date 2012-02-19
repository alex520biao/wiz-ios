//
//  WizInputView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-27.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizInputView.h"

@implementation WizInputView
@synthesize backgroundView;
@synthesize nameLable;
@synthesize textInputField;

- (void) dealloc
{
    self.backgroundView = nil;
    self.nameLable = nil;
    self.textInputField = nil;
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame title:(NSString*)title placeHoder:(NSString*)placeHoder
{
    self = [self initWithFrame:frame];
    self.nameLable.text = NSLocalizedString(title, nil);
    self.textInputField.placeholder = NSLocalizedString(placeHoder, nil);
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView* imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0.0, 300, frame.size.height)];
        [self addSubview:imageView_];
        [imageView_ release];
        self.backgroundView = imageView_;
        self.backgroundView.image = [UIImage imageNamed:@"inputBackground"];
        
        UILabel* nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, frame.size.height)];
        nameLabel_.font = [UIFont systemFontOfSize:13];

        self.nameLable = nameLabel_;
        [nameLabel_ release];
        self.nameLable.textAlignment = UITextAlignmentCenter;
        self.nameLable.backgroundColor = [UIColor clearColor];
        
        UITextField* textInputField_ = [[UITextField alloc] initWithFrame:CGRectMake(10, 0.0, 300, frame.size.height)];
        [self addSubview:textInputField_];
        [textInputField_ release];
        textInputField_.leftViewMode = UITextFieldViewModeAlways;
        textInputField_.leftView = self.nameLable;
        textInputField_.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        self.textInputField = textInputField_;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
