//
//  WizAbstract.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizAbstract : NSObject
{
    UIImage* image;
    NSString* text;
    BOOL   placAbstract;
}
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, retain) NSString* text;
@property (nonatomic, assign) BOOL   placAbstract;
@end
