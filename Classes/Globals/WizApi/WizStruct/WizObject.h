//
//  WizObject.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizObject : NSObject
{
    NSString* guid;
    NSString* title;
}
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* title;
@end
