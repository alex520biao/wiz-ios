//
//  WizGlobalError.h
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WizErrorDomain      @"error.wiz.cn"
#define NSParseErrorDomain  @"come.effigent.iphone.parseerror"
#define WizNetWorkMaxAttempts     5
enum WizErrorCode {
    CodeOfTokenUnActiveError    = 301,
    NSParseErrorCode            = -101,
    NSInvaildUrlErrorCode       = -1000,
    NSOvertimeErrorCode         = -1001,
    WizGuidIsNilErrorCode       = 6001,
    NSUserCancelError           = 10000,
    WizCanNoteResloceErrorCode  = 1718
};
@interface WizGlobalError : NSObject
+ (NSError*) tokenUnActiveError;
+ (NSError*) canNotResloceError;
@end
