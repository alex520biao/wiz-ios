//
//  WizPadListCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListCell.h"

@interface WizPadListCell()
{
    NSMutableArray* abstractArray;
}
@property (nonatomic, retain) NSMutableArray* abstractArray;
@end

@implementation WizPadListCell
@synthesize abstractArray;
@synthesize documents;
@synthesize selectedDelegate;
- (void) dealloc
{
    selectedDelegate = nil;
    [abstractArray release];
    abstractArray = nil;
    [documents release];
    documents = nil;
    [super dealloc];
}

- (void) drawRect:(CGRect)rect
{
    for (int i = 0; i < [documents count]; i++) {
        
        WizDocument* doc = [documents objectAtIndex:i];
        WizPadDocumentAbstractView* abst = [self.abstractArray objectAtIndex:i];
        abst.doc = doc;
        abst.alpha = 1.0f;
        [abst setNeedsDisplay];
    }
    for (int i =[documents count]; i < 4; i++) {
        WizPadDocumentAbstractView* abst = [self.abstractArray objectAtIndex:i];
        abst.alpha = 0.0f;
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.backgroundColor = [UIColor grayColor];
        self.accessoryType = UITableViewCellAccessoryNone;
        self.abstractArray = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 4; i++) {
            WizPadDocumentAbstractView* abstractView = [[WizPadDocumentAbstractView alloc] initWithFrame:CGRectMake(35*(i+1)+205*i, 15, 205, PADABSTRACTVELLHEIGTH-50)];
            [self.contentView addSubview:abstractView];
            [self.abstractArray addObject:abstractView];
            abstractView.selectedDelegate = self;
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
- (void) didSelectedDocument:(WizDocument *)doc
{
    [self.selectedDelegate didPadCellDidSelectedDocument:doc];
}
@end
