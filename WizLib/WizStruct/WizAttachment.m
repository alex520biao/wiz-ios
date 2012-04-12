//
//  WizAttachment.m
//  WizLib
//
//  Created by MagicStudio on 12-4-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizAttachment.h"

@implementation WizAttachment
@synthesize guid;
@synthesize title;
@synthesize description;
@synthesize dateModified;
@synthesize dataMd5;
@synthesize documentGuid;
@synthesize serverChanged;
@synthesize localChanged;
- (id) init
{
    self = [super init];
    if (self) {
        self.guid = [WizGlobals genGUID];
        self.title = WizStrNoTitle;
    }
    return self;
}
@end
