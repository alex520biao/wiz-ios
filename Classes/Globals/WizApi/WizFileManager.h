//
//  WizFileManger.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizFileManager : NSFileManager
{
    NSString* accountUserId;
}
@property (nonatomic, retain) NSString* accountUserId;
+ (id) shareManager;
- (NSString*) accountPath;
- (NSString*) dbPath;
- (NSString*) tempDbPath;
@end
