//
//  WizAbstractData.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAbstractData : NSObject
{
    NSAttributedString* text;
    UIImage*            image;
}
@property (nonatomic, retain) NSAttributedString* text;
@property (nonatomic, retain) UIImage*              image;
@end