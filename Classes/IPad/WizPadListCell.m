//
//  WizPadListCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListCell.h"
#import "WizPadDocumentAbstractView.h"

@implementation WizPadListCell
@synthesize accountUserId;
@synthesize owner;
@synthesize abstractArray;
- (void) dealloc
{
    [abstractArray release];
    [owner release];
    [accountUserId release];
    [super dealloc];
}
- (void) setDocuments:(NSArray*) arr
{
    for (int i = 0; i < [arr count]; i++) {
        
        WizDocument* doc = [arr objectAtIndex:i];
        WizPadDocumentAbstractView* abst = [self.abstractArray objectAtIndex:i];
        abst.accountUserId = self.accountUserId;
        abst.owner = self.owner;
        [abst setDocument:doc];

        abst.alpha = 1.0f;
    }
    for (int i =[ arr count]; i < 4; i++) {
        WizPadDocumentAbstractView* abst = [self.abstractArray objectAtIndex:i];
        abst.alpha = 0.0f;
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
        self.abstractArray = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            WizPadDocumentAbstractView* abstractView = [[WizPadDocumentAbstractView alloc] initWithFrame:CGRectMake(35*(i+1)+205*i, 15, 205, PADABSTRACTVELLHEIGTH-50)];
            [self.contentView addSubview:abstractView];
            [self.abstractArray addObject:abstractView];
            [abstractView release];
        }
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
