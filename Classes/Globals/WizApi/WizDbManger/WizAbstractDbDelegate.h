//
//  WizAbstractDbDelegate.h
//  Wiz
//
//  Created by 朝 董 on 12-4-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WizAbstract;
@protocol WizAbstractDbDelegate <NSObject>
- (BOOL) openTempDb:(NSString*)tempDbFilePath;
- (BOOL) isTempDbOpen;
- (void) closeTempDb;
- (WizAbstract*) abstractOfDocument:(NSString *)documentGUID;
- (void) extractSummary:(NSString *)documentGUID;
- (BOOL) clearCache;
- (BOOL) deleteAbstractByGUID:(NSString *)documentGUID;
- (WizAbstract*) abstractForGroup:(NSString*)kbguid;
@end
