//
//  WizChangePasswordDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WizChangePasswordDelegate <NSObject>
- (void) didChangedPasswordSucceed;
- (void) didChangedPasswordFaild;
@end
