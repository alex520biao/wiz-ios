//
//  WizSearch.m
//  Wiz
//
//  Created by wiz on 12-7-20.
//
//

#import "WizSearch.h"


@interface WizSSS : NSProxy
- (void) test;
@end

@implementation WizSSS

- (void) test{
    
}

@end


@interface WizS : WizSSS

@end

@implementation WizS

- (void) test
{
    
}

@end

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

