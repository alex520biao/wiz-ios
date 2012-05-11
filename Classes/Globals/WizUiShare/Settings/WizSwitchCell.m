//
//  WizSwitchCell.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSwitchCell.h"

@implementation WizSwitchCell
@synthesize valueSwitch;

- (void) dealloc
{
    [valueSwitch release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        UISwitch* sw = [[UISwitch alloc] initWithFrame:CGRectZero];
        self.accessoryView = sw;
        self.valueSwitch = sw;
        [sw release];
    }
    return self;
}
+ (WizSwitchCell*) switchCell
{
    return [[[WizSwitchCell alloc] init] autorelease];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
