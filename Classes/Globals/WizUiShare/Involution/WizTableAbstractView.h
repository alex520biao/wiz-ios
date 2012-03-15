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
    NSString* docTitle;
    NSString* docTime;
    NSString* docDetail;
    UIImage* absImage;
}
@property (nonatomic, readonly) NSString* accountUserId;
@property (nonatomic, retain) NSString* documentGuid;
@property (nonatomic, readonly) NSString* docTitle;
@property (nonatomic, readonly) NSString* docTime;
@property (nonatomic, readonly) NSString* docDetail;
@property (nonatomic, readonly) UIImage* absImage;
@end
