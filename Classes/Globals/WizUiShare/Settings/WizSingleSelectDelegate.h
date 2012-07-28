//
//  WizSingleSelectDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizSingleSelectDelegate <NSObject>
- (void) didSelectedIndex:(NSInteger)index;
@end
