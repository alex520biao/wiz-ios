//
//  WizTableAbstractView.h
//  Wiz
//
//  Created by wiz on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizTableAbstractView : UIView
{
    NSString* documentGuid;
    @private
    NSString* accountUserId;
}
@property (nonatomic, readonly) NSString* accountUserId;
@property (nonatomic, retain) NSString* documentGuid;
- (id)initWithFrame:(CGRect)frame userId:(NSString*)userId;
@end
