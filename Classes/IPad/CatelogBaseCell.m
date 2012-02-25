//
//  CatelogBaseCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogBaseCell.h"
#import "CatelogBaseAbstractView.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "TTTAttributedLabel.h"
#import "CatelogBaseController.h"
@implementation CatelogBaseCell
@synthesize accountUserId;
@synthesize owner;
- (void) dealloc
{
    self.owner = nil;
    self.accountUserId = nil;
    [super dealloc];
}


- (void) setContent:(NSArray*) arr
{
    if ([arr count]) {
        for (UIView* each in [self.contentView subviews]) {
            [each removeFromSuperview];
        }
        
    }
    for (int i = 0; i < [arr count]; i++) {
        WizPadCatelogData* data = [arr objectAtIndex:i];
        CatelogBaseAbstractView* abstractView = [[CatelogBaseAbstractView alloc] initWithFrame:CGRectMake(55+55*i+180*i, 15, 180, PADABSTRACTVELLHEIGTH-30)];
        abstractView.backGroud.image = [UIImage imageNamed:@"folderBackgroud"];
        abstractView.owner = self.owner;
        abstractView.nameLabel.text = data.name;
        abstractView.documentsCountLabel.text = data.count;
        abstractView.keywords = data.keyWords;
        abstractView.abstractLabel.text = data.abstract;
        [self.contentView addSubview:abstractView];
        [abstractView release];
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
