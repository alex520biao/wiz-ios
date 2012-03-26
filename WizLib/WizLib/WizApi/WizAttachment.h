//
//  WizAttachment.h
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizObject.h"
@interface WizAttachment : WizObject {
    NSString* type;
    NSString* title;
    NSString* dataMd5;
    NSString* description;
    NSString* dateModified;
    NSString* documentGUID;
    BOOL      serverChanged;
    BOOL      localChanged;
}
@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* dataMd5;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* dateModified;
@property (nonatomic, retain) NSString* documentGUID;
@property (assign) BOOL      serverChanged;
@property (assign) BOOL      localChanged;
@end