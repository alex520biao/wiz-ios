//
//  WizLib.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WizDocument.h"
@interface WizLib : NSObject
+ (void) addAccount:(NSString*)userId password:(NSString*)password;
+ (void) registeAccount:(NSString*)userId;
@end
@protocol WizObjectDelegate
@optional
- (BOOL) save;
- (void) upload;
- (void) download;
@end
@interface WizDocument(WizNote) <WizObjectDelegate> 
- (id) initFromGuid:(NSString*)guid;
- (NSString*) documentFilePath;
- (BOOL) saveBody:(NSString*)body;
@end
