//
//  WizLabel.h
//  Wiz
//
//  Created by 朝 董 on 12-6-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum
{
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom
} VerticalAlignment;
@interface WizLabel : UILabel
{
    VerticalAlignment verticalAlignment;
}
@property (nonatomic) VerticalAlignment verticalAlignment;
@end
