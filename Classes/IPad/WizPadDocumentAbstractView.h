//
//  WizPadDocumentAbstractView.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@class WizDocument;
@interface WizPadDocumentAbstractView : UIView
{
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
    UIImageView* abstractImageView;
    WizDocument* doc;
}
@property (nonatomic, retain)     UILabel* nameLabel;
@property (nonatomic, retain)  UILabel* timeLabel;
@property (nonatomic, retain)  UILabel* detailLabel;
@property (nonatomic, retain) UIImageView* abstractImageView;
@property (nonatomic, retain) WizDocument* doc;
- (void) setDocument:(WizDocument*) document;
@end
