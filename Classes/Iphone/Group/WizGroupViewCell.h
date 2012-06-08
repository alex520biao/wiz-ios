//
//  WizGroupViewCell.h
//  Wiz
//
//  Created by 朝 董 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GMGridViewCell.h"
#import "WizLabel.h"
@interface WizGroupViewCell : GMGridViewCell
{
    UIImageView* imageView;
    WizLabel*  textLabel;
}
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) WizLabel*  textLabel;

- (id) initWithSize:(CGSize)size;
@end
