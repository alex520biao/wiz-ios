//
//  WizPadCatelogViewController.h
//  Wiz
//
//  Created by 朝 董 on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CatelogCell.h"
#import "WizPadViewDocumentDelegate.h"
#import "WizSegmentOrientationDelegate.h"
#import "WizSegmentTableViewControllerBase.h"

@interface WizPadCatelogViewController : WizSegmentTableViewControllerBase <WizCatelogCellViewDeleage>
{
    id <WizPadViewDocumentDelegate> checkDelegate;
}
@property (nonatomic, assign)  id <WizPadViewDocumentDelegate> checkDelegate;
- (NSArray*) catelogDataSourceArray;
- (void) reloadAllData;
@end