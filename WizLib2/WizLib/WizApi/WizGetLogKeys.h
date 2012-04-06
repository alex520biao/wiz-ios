//
//  WizGetLogKeys.h
//  WizLib
//
//  Created by 朝 董 on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"

@interface WizGetLogKeys : WizApi
- (void) onClientLogin:(id)ret;
-(BOOL) getLoginKeys;
@end
