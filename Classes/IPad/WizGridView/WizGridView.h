//
//  WizGridView.h
//  Wiz
//
//  Created by 朝 董 on 12-5-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizGridView;
@protocol WizGridViewDataSourceDelegate
- (NSInteger) numberOfSectionInWizGridView:(WizGridView*)gridView;
- (NSInteger) numberOfItemsInSection:(NSInteger)section inWizGridView:(WizGridView*)gridView;
@end
@interface WizGridView : UIScrollView <UIScrollViewDelegate>
{
    id <WizGridViewDataSourceDelegate> dataSourceDelegate;
    NSMutableArray* visibleCells;
    //
    CGSize gridViewCellSize;
    CGFloat gridViewCellBreakSpace;
    CGFloat gridSectionViewHeight;
}

@property (nonatomic, readonly) NSMutableArray* visibleCells;
@property (nonatomic, assign) id <WizGridViewDataSourceDelegate> dataSourceDelegate;
//
@property (nonatomic, assign) CGSize gridViewCellSize;
@property (nonatomic, assign) CGFloat gridViewCellBreakSpace;
@property (nonatomic, assign) CGFloat gridSectionViewHeight;
@end

