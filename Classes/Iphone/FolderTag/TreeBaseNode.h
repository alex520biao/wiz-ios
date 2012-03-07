//
//  TreeBaseNode.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TreeBaseNode : NSObject
{
    int deep;
    BOOL isExpand;
    BOOL isHaseChild;
    id owner;
    BOOL isHidden;
    int index;
}
@property int deep;
@property (assign) BOOL isExpand;
@property (retain, nonatomic) id owner;
@property (assign) BOOL isHaseChild;
@property (assign) BOOL isHidden;
@property (assign) int  index;
@end
