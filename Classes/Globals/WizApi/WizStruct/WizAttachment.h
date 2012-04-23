//
//  WizAttachment.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject.h"

@interface WizAttachment : WizObject
{
    NSString* type;
    NSString* dateMd5;
    NSString* description;
    NSDate*     dateModified;
    NSString* documentGuid;
    BOOL      serverChanged;
    BOOL      localChanged;
}
@property (nonatomic, retain)     NSString* type;
@property (nonatomic, retain)     NSString* dateMd5;
@property (nonatomic, retain)     NSString* description;
@property (nonatomic, retain)     NSDate*     dateModified;
@property (nonatomic, retain)     NSString* documentGuid;
@property (assign) BOOL      serverChanged;
@property (assign) BOOL      localChanged;
- (id) initFromGuid:(NSString*)attachmentGuid;
- (NSString*) attachmentFilePath;
- (BOOL) saveInfo;
- (BOOL) saveData:(NSString*)filePath;
@end
