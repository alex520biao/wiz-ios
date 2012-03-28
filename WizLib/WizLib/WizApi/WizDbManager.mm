//
//  WizDbManager.m
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizDbManager.h"
#import "index.h"
@interface WizIndexData : NSObject
{
	CIndex _index;
}
-(CIndex&) index;

@end

@implementation WizIndexData

- (CIndex&) index
{
	return _index;
}

@end

@interface WizTempIndexData : NSObject
{
    CTempIndex _tempIndex;
}
- (CTempIndex&) tempIndex;
@end
@implementation WizTempIndexData

- (CTempIndex&) tempIndex
{
    return _tempIndex;
}

@end

@interface WizDbManager()
{
    CIndex index;
    CTempIndex tempIndex;
}
@end
@implementation WizDbManager
static WizDbManager* shareDbManager = nil;
- (id) shareDbManager
{
    @synchronized(shareDbManager)
    {
        if (shareDbManager == nil) {
            shareDbManager = [[super allocWithZone:NULL] init];
        }
        return shareDbManager;
    }
}
- (id) allocWithZone:(NSZone*)zone
- (void) open
{
    CIndex* index = [WizIndexData index];
    [index open];
}
@end
