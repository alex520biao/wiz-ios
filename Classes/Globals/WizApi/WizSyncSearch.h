//
//  WizSyncSearch.h
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizApi.h"
#import "WizSyncSearchDelegate.h"
@interface WizSyncSearch : WizApi
{
    NSString* keyWord;
    id<WizSyncSearchDelegate> searchDelegate;
}
@property (nonatomic, retain) NSString* keyWord;
@property (nonatomic, retain) id<WizSyncSearchDelegate> searchDelegate;
@end
