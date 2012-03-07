//
//  TreeBaseNodeCell.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TreeBaseNode;
@interface TreeBaseNodeCell : UITableViewCell
{
    UIButton* btnExpand;
    SEL onExpand;
    UILabel *label;
    id owner;
    UIImageView* imgIcon;
    TreeBaseNode* treeNode;
}
@property (nonatomic, retain) id owner;
@property (nonatomic, retain) TreeBaseNode* treeNode;
@property (nonatomic, retain) UIImageView* imgIcon;
@property (nonatomic, retain) UILabel* label;
@property (nonatomic, retain) UIButton* btnExpand;

+(int)  indent;
+(void) setIndent:(int) value;
+(int) icoWidth;
+(int) icoHeight;
+(void) setIcoWidth:(int) value;
+(void) setIcoHeight:(int) value;
+(int) labelMarginLeft;
+(void)setLabelMarginLeft:(int)value;
-(int) getIndent;


@end
