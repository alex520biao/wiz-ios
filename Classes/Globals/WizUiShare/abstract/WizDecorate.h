//
//  WizDecorate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@interface WizDecorate : NSObject

+ (UIFont*) nameFont;
+ (NSString*) nameToDisplay:(NSString*)str   width:(CGFloat)width;
@end
