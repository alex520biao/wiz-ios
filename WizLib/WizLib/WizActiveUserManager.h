//
//  WizActiveUserManager.h
//  WizLib
//
//  Created by wiz on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface WizActiveUserManager : NSObject
+ (void) registerActive:(NSString*)userId;
+ (NSString*) activeAccountUserId;
+ (void) setActiveApiInfo:(NSString*)kbguid  token:(NSString*)token apiUrl:(NSURL*)apiUrl;
@end
