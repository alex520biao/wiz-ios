//
//  WizTableVIewCell.h
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@interface WizTableViewCell : UITableViewCell
{
    @public
    NSString* accountUserId;
    NSString* documemtGuid;
    @private
    TTTAttributedLabel* detailLabel;
    UIImageView* abstractImageView;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) TTTAttributedLabel* detailLabel;
@property (nonatomic, retain) UIImageView* abstractImageView;
@property (nonatomic, retain) NSString* documemtGuid;
- (id) initWithUserIdAndDocGUID:(UITableViewCellStyle)style userId:(NSString *)userID;
@end
