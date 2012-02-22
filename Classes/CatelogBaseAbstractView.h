//
//  CatelogBaseAbstractView.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@interface CatelogBaseAbstractView : UIView
{
    UILabel* nameLabel;
    UILabel* documentsCountLabel;
    TTTAttributedLabel* abstractLabel;
    NSString* keywords;
    UIImageView* backGroud;
    id owner;
}
@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UILabel* documentsCountLabel;
@property (nonatomic, retain) TTTAttributedLabel* abstractLabel;
@property (nonatomic, retain) id owner;
@property (nonatomic, retain) NSString* keywords;
@property (nonatomic, retain) UIImageView* backGroud;
@end
