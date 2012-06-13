//
//  WizDbManager.h
//  Wiz
//
//  Created by MagicStudio on 12-4-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizDbManager : NSObject 
+ (id) shareDbManager;
- (WizDataBase*) shareDataBase;
- (WizDataBase*) getWizDataBase:(NSString*)accountUserId  groupId:(NSString*)groupId;
- (void) removeUnactiveDatabase;
@end