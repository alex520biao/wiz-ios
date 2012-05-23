//
//  CatelogView.h
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CatelogViewSelectedDelegate
- (void) didSelectedCatelogForKey:(id)key;
@end
@interface CatelogView : UIView
{
    UILabel* nameLabel;
    UILabel* detailLabel;
    UILabel* documentsCountLabel;
    UIImageView* backGroudImageView;
    id <CatelogViewSelectedDelegate> selectedDelegate;
}
@property (nonatomic, assign) id <CatelogViewSelectedDelegate> selectedDelegate;
- (void) didSelectedCateLogView;
@end
