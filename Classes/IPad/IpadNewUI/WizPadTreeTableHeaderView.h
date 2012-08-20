//
//  WizPadTreeTableHeaderView.h
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import <UIKit/UIKit.h>
@class WizPadTreeTableHeaderView;
@protocol WizPadTableHeaderDeleage <NSObject>
- (void) didSelectedHeader:(WizPadTreeTableHeaderView*)header;
@end

@interface WizPadTreeTableHeaderView : UIView
{
    UILabel*  titleLabel;
    id<WizPadTableHeaderDeleage> delegate;
}
@property (nonatomic ,assign) id<WizPadTableHeaderDeleage> delegate;
@property (nonatomic, readonly ,retain) UILabel* titleLabel;
@end
