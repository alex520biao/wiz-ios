//
//  WizSearch.m
//  Wiz
//
//  Created by wiz on 12-7-20.
//
//

#import "WizSearch.h"

@implementation WizSearch
@synthesize isSearchLocal;
@synthesize keyWords;
@synthesize nNotesNumber;
@synthesize searchDate;
- (void) dealloc
{
    [keyWords release];
    [searchDate release];
    [super dealloc];
}
@end
