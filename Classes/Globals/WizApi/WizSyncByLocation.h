//
//  WizSyncByLocation.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSyncBase.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
@interface WizSyncByLocation : WizSyncBase
{
    NSString* location;
}
@property (nonatomic, retain) NSString* location;
@end
