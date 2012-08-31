//
//  WizSyncSearchDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizSyncSearchDelegate <NSObject>
- (void) didSearchFild;
- (void) didSearchSucceed:(NSArray*)array;
@end
