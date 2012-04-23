//
//  WizTag.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

@interface WizTag : WizObject
{
	NSString* parentGUID;
	NSString* description;
	NSString* namePath;
    NSDate*   dateInfoModified;
    BOOL       localChanged;
}
@property (nonatomic, retain) NSString* parentGUID;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* namePath;
@property (nonatomic, retain) NSDate*   dateInfoModified;
@property (assign) BOOL localChanged;
+ (WizTag*) tagFromDb:(NSString*)guid;
+ (void) deleteTag:(NSString*)tagGuid;
@end
