//
//  WizTableAbstractViewDecorate.h
//  Wiz
//
//  Created by wiz on 12-3-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableAbstractView.h"

@interface WizTableAbstractViewDecorate : WizTableAbstractView
{
    BOOL isLoadingAbstract;
    @private
    NSString* detailStr;
    NSString* timerStr;
    NSString* nameStr;
    UIImage*  abstractImage;
    BOOL hasAbstract;
}
@property (readonly, nonatomic) BOOL hasAbstract;
@property (nonatomic, readonly) BOOL isLoadingAbstract;
@property (nonatomic, readonly ) NSString* detailStr;
@property (nonatomic, readonly ) NSString* timerStr;
@property (nonatomic, readonly ) NSString* nameStr;
@property (nonatomic, readonly ) UIImage*  abstractImage;
@end
