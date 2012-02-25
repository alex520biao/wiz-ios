//
//  WizDowdloadDocumentAttachment.m
//  Wiz
//
//  Created by dong zhao on 11-10-26.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WizDowdloadDocumentAttachment.h"


@implementation WizDowdloadDocumentAttachment
@synthesize attachGuid, documentGuid, busy;

-(void) dealloc {

    [attachGuid release];
    [documentGuid release];
    [super dealloc];
}


@end
