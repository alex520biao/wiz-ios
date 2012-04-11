//
//  WizLib.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDocument.h"

@interface WizNote : WizDocument

@end

@interface WizLib : NSObject
+ (void) addAccount:(NSString*)userId password:(NSString*)password;
+ (void) registeAccount:(NSString*)userId;
@end
