//
//  WizSyncByTag.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncBase.h"

@interface WizSyncByTag : WizSyncBase
{
    NSString* tag;
}
@property (nonatomic, retain) NSString* tag;
- (BOOL) callSyncMethod;
@end
