//
//  WizSyncSearch.m
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncSearch.h"
#import "WizDbManager.h"

@implementation WizSyncSearch
@synthesize keyWord;
@synthesize searchDelegate;
@synthesize isSearching;
- (void) dealloc
{
    [keyWord release];
    [searchDelegate release];
    [super dealloc];
}
- (void) onDocumentsByKey:(id)retObject
{
    busy = NO;
    NSArray* obj = retObject;
	[[[WizDbManager shareDbManager] shareDataBase] updateDocuments:obj];
    [self.searchDelegate didSearchSucceed];
    isSearching = NO;
    self.searchDelegate = nil;
    [self.apiManagerDelegate didApiSyncDone:self];
}
- (BOOL) start
{
    busy = YES;
    isSearching = YES;
    return [self callDocumentsByKey:self.keyWord];
}
- (void) onError:(id)retObject
{
    busy = NO;
    NSError* error = (NSError*)retObject;
    if (error.code != CodeOfTokenUnActiveError && error.code != NSInvaildUrlErrorCode) {
        isSearching = NO;
        [self.searchDelegate didSearchFild];
        self.searchDelegate = nil;
    }
    [super onError:retObject];
}
@end
