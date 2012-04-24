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
- (NSString*) attachmentFilePath;
- (BOOL) saveData:(NSString*)filePath;
+ (void) deleteAttachment:(NSString*)attachmentGuid;
+ (WizAttachment*) attachmentFromDb:(NSString*)attachmentGuid;
+ (void) setAttachmentLocalChanged:(NSString*)attachmentGuid changed:(BOOL)changed;
+ (void) setAttachServerChanged:(NSString*)attachmentGUID changed:(BOOL)changed;
@end
