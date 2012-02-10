//
//  WizPadListCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListCell.h"
#import "WizPadDocumentAbstractView.h"
#import "WizIndex.h"
@implementation WizPadListCell
@synthesize accountUserId;
@synthesize owner;
- (void) dealloc
{
    self.owner = nil;
    self.accountUserId = nil;
    [super dealloc];
}
- (void) setDocuments:(NSArray*) arr
{
    if ([arr count]) {
        for (UIView* each in [self.contentView subviews]) {
            [each removeFromSuperview];
        }

    }
    for (int i = 0; i < [arr count]; i++) {
        WizDocument* doc = [arr objectAtIndex:i];
        WizPadDocumentAbstractView* abstractView = [[WizPadDocumentAbstractView alloc] initWithFrame:CGRectMake(35*(i+1)+205*i, 15, 205, PADABSTRACTVELLHEIGTH-50)];
        abstractView.accountUserId = self.accountUserId;
        abstractView.owner = self.owner;
        [abstractView setDocument:doc];
        [self.contentView addSubview:abstractView];
        [abstractView release];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor grayColor];
        self.accessoryView.backgroundColor = [UIColor grayColor];
        self.backgroundColor = [UIColor grayColor];
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
