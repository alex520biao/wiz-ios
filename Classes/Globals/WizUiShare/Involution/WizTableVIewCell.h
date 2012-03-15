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
    CALayer* layer;
}
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSString* documemtGuid;
- (id) initWithUserIdAndDocGUID:(UITableViewCellStyle)style userId:(NSString *)userID;
@end
