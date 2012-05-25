//
//  WizRefreshDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizRefreshDelegate <NSObject>
- (void) didRefreshToken:(NSDictionary*)dic;
@end
