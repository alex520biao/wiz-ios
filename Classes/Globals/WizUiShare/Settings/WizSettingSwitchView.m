//
//  WizSettingSwitchView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSettingSwitchView.h"

@implementation WizSettingSwitchView
@synthesize  nameLabel;
@synthesize  valueSwitch;
- (void) dealloc
{
    [nameLabel release];
    [valueSwitch release];
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel* label = [[UILabel alloc] init];
        self.nameLabel = label;
        label.backgroundColor = [UIColor clearColor];
        [label release];
        
        UISwitch* sw = [[UISwitch alloc] init];
        self.valueSwitch = sw;
        sw.backgroundColor = [UIColor clearColor];
        [sw release];
        
        [self addSubview:nameLabel];
        [self addSubview:valueSwitch];
        self.valueSwitch.frame = CGRectMake(220, 6, 50, 40);
        self.nameLabel.frame = CGRectMake(10, 0.0, 210, 40);
    }
    return self;
}


@end
