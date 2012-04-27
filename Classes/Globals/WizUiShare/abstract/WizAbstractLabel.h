//
//  WizAbstractLabel.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizAbstractLabel : UILabel
{
    NSString* strTitle;
    NSString* strTimer;
    NSString* strDetail;
}
@property (nonatomic, retain)   NSString* strTitle;
@property (nonatomic, retain)   NSString* strTimer;
@property (nonatomic, retain)   NSString* strDetail;
@end
