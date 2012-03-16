//
//  WizTableAbstractView.m
//  Wiz
//
//  Created by wiz on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "WizTableAbstractView.h"
#import <CoreText/CoreText.h>
#import "WizGlobalData.h"

@implementation WizTableAbstractView
@synthesize documentGuid, accountUserId;
- (void) dealloc
{
    accountUserId = nil;
    self.documentGuid = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame userId:(NSString*)userId
{
    self = [super initWithFrame:frame];
    if (self) {
        accountUserId = userId;
    }
    return self;
}
@end
