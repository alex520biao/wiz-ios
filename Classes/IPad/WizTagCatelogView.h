//
//  WizTagCatelogView.h
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogView.h"

@interface WizTagCatelogView : CatelogView
{
    WizTag* wizTag;
}
@property (nonatomic, retain) WizTag* wizTag;
@end
