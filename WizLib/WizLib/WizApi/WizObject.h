//
//  WizObject.h
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizObject : NSObject
{
    NSString* guid;
}
@property (nonatomic, retain) NSString* guid;
- (NSString*) directoryPath;
- (NSString*) downloadTempFilePath;
@end
