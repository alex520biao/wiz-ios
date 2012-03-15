//
//  WizTableViewBaseCell.m
//  Wiz
//
//  Created by wiz on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewBaseCell.h"
@implementation WizTableViewBaseCell
@synthesize timeStr, titleStr, detailStr, absImage;
- (void) dealloc
{
    timeStr = nil;
    titleStr = nil;
    detailStr = nil;
    absImage = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
