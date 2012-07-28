//
//  NSArray+WizTools.h
//  Wiz
//
//  Created by 朝 董 on 12-4-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizObject;
@interface NSMutableArray (WizTools)
- (void) addObjectUnique:(id)object;
- (void) addWizObjectUnique:(WizObject*)objcet;
- (void) addAttachmentBySourceFile:(NSString*)source;
- (NSArray*) attachmentTempSourceFile;
- (BOOL) hasWizObject:(WizObject*)obj;
@end
