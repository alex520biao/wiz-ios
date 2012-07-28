//
//  WizGridView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizGridView.h"

@interface WizGridView ()
{
    
}
@end

@implementation WizGridView

@synthesize visibleCells;
@synthesize gridViewCellSize;
@synthesize gridSectionViewHeight;
@synthesize gridViewCellBreakSpace;
@synthesize dataSourceDelegate;

- (void) dealloc
{
    dataSourceDelegate = nil;
    [visibleCells release];
    visibleCells = nil;
    [super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        visibleCells = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGFloat) scrollContentSize
{
//    NSInteger numberOfSection = [self.dataSourceDelegate numberOfSectionInWizGridView:self];
//    CGFloat scrollContentHeight = self.frame.size.height;
//    for (int i = 0; i < numberOfSection; i ++) {
//        NSInteger numberOfItem = [self.dataSourceDelegate numberOfItemsInSection:i inWizGridView:self];
//        NSInteger numberOfItemsInRow = (int)(self.frame.size.width / (self.gridViewCellSize.height + self.gridViewCellBreakSpace));
//        NSInteger numberOfRow = numberOfSection/numberOfItems
//        scrollContentHeight = self.gridSectionViewHeight + numberOfSection*(self.gridViewCellSize.height + self.gridViewCellBreakSpace);
//    }
//    self.contentSize = CGSizeMake(self.frame.size.width, <#CGFloat height#>)
    return 9;
}

- (void) loadNeedDisplayItems
{
    
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
@end
