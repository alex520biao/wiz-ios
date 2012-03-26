//
//  WizTag.h
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizTag : NSObject
{
	NSString* name;
	NSString* guid;
	NSString* parentGUID;
	NSString* description;
	NSString* namePath;
    int       localChanged;
    NSString*   dtInfoModified;
}
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* guid;
@property (nonatomic, retain) NSString* parentGUID;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* namePath;
@property (nonatomic, retain) NSString*   dtInfoModified;
@property int localChanged;
@end