//
//  CatelogCell.h
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define PADABSTRACTVELLHEIGTH 300
#import "CatelogView.h"
@protocol WizCatelogCellViewDeleage <NSObject>
@optional
- (CatelogView*) catelogViewForTableView:(UITableView*)tableView;
- (void) didSelectedCateLogViewForKey:(id)keyWords;
- (void) setContentForCatelogView:(id)content  catelogView:(CatelogView*)view;
@end

@interface CatelogCell : UITableViewCell <CatelogViewSelectedDelegate>
{
    id <WizCatelogCellViewDeleage> catelogDelegate;
}
@property (nonatomic, assign) id <WizCatelogCellViewDeleage> catelogDelegate;
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDelegate:(id <WizCatelogCellViewDeleage>)delegate;
- (void) setCatelogViewContents:(NSArray*)contents;
@end
