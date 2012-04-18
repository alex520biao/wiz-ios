//
//  WizGlobalError.h
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WizErrorDomain  @"error.wiz.cn"

enum WizErrorCode {
    CodeOfTokenUnActiveError = 301
};
@interface WizGlobalError : NSObject
- (NSError*) tokenUnActiveError;
@end
