//
//  WizTagCatelogView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTagCatelogView.h"
#import "WizAbstractCache.h"

@implementation WizTagCatelogView

@synthesize wizTag;

- (void) dealloc
{
    [wizTag release];
    wizTag = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) didSelectedCateLogView
{
    [self.selectedDelegate didSelectedCatelogForKey:self.wizTag];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (nil == self.wizTag) {
        return;
    }
    nameLabel.text =  getTagDisplayName(self.wizTag.title);
    backGroudImageView.image = [UIImage imageNamed:@"tagBackgroud"];
    NSInteger count =  [WizTag fileCountOfTag:self.wizTag.guid];
    documentsCountLabel.text = [NSString stringWithFormat:@"%d %@",count,WizStrNotes];
    detailLabel.text = [[WizAbstractCache shareCache] getTagAbstract:self.wizTag.guid];
}

@end
