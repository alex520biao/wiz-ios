//
//  WizObject+WizSync.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizObject+WizSync.h"
#import "WizDocument.h"
#import "WizAttachment.h"
@implementation WizObject (WizSync)
- (NSString*) objectType
{
    if ([self isKindOfClass:[WizDocument class]]) {
        return WizDocumentKeyString;
    }
    else if ([self isKindOfClass:[WizAttachment class]])
    {
        return WizAttachmentKeyString;
    }
    else {
        return nil;
    }
}
@end
