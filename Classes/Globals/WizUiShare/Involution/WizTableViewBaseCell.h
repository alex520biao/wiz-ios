//
//  WizTableViewBaseCell.h
//  Wiz
//
//  Created by wiz on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizTableViewBaseCell : UITableViewCell
{
    NSString* titleStr;
    NSString* timeStr;
    NSString* detailStr;
    UIImage*  absImage;
}
@property (nonatomic, readonly) NSString* titleStr;
@property (nonatomic, readonly) NSString* timeStr;
@property (nonatomic, readonly) NSString* detailStr;
@property (nonatomic, readonly) UIImage*  absImage;
@end
