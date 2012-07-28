//
//  WizDeletedGUID.m
//  Wiz
//
//  Created by wiz on 12-6-15.
//
//

#import "WizDeletedGUID.h"

@implementation WizDeletedGUID
@synthesize guid;
@synthesize type;
@synthesize dateDeleted;
-(void) dealloc
{
    [guid release];
    [type release];
    [dateDeleted release];
    [super dealloc];
}

@end
