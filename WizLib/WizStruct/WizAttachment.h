//
//  WizAttachment.h
//  WizLib
//
//  Created by MagicStudio on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizAttachment : NSObject
{
    NSString* guid;
    NSString* title;
    NSString* documentGuid;
    NSString* dataMd5;
    BOOL      localChanged;
    BOOL      serverChanged;
    NSDate*   dateModified;
    NSString* description;
}
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* documentGuid;
@property (nonatomic, retain) NSString* dataMd5;
@property (nonatomic, retain) NSDate* dateModified;
@property (nonatomic, retain) NSString* description;
@property BOOL serverChanged;
@property BOOL localChanged;
- (id) initFromGUID:(NSString*)guid;
@end
