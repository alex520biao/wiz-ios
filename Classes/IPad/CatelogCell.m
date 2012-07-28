//
//  CatelogCell.m
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogCell.h"

@interface CatelogCell()
{
    NSArray* contentViewArray;
}
@end
@implementation CatelogCell
@synthesize catelogDelegate;
- (void) dealloc
{
    catelogDelegate = nil;
    [contentViewArray release];
    contentViewArray = nil;
    [super dealloc];
}
- (void) didSelectedCatelogForKey:(id)key
{
    [self.catelogDelegate didSelectedCateLogViewForKey:key];
}
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id <WizCatelogCellViewDeleage>)delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSMutableArray* contentsV = [[NSMutableArray alloc] init];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        catelogDelegate = delegate;
        for (int i = 0; i < 4; i++) {
            CatelogView* view = [self.catelogDelegate catelogViewForTableView:nil];
            view.frame = CGRectMake(55+55*i+180*i, 15, 180, PADABSTRACTVELLHEIGTH-30);
            view.selectedDelegate = self;
            
            [contentsV addObject:view];
        }
        contentViewArray = [contentsV retain];
        self.contentView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        [contentsV release];
    }
    return self;
}

- (void) setCatelogViewContents:(NSArray*)contents
{
    for (int i = 0; i < [contents count]; i++) {
        CatelogView* view = [contentViewArray objectAtIndex:i];
        [self.contentView addSubview:view];
        id object = [contents objectAtIndex:i];
        [self.catelogDelegate setContentForCatelogView:object catelogView:view];
    }
    for (int i = [contents count]; i < 4; i++) {
        CatelogView* view = [contentViewArray objectAtIndex:i];
        [view removeFromSuperview];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
