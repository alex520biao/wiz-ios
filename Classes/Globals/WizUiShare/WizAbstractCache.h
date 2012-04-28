//
//  WizAbstractCache.h
//  Wiz
//
//  Created by MagicStudio on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizGenDocumentAbstract.h"
@protocol WizGenDocumentAbstractDelegate;
@interface WizAbstractCache : NSObject <WizGenDocumentAbstractDelegate>
+ (id) shareCache;
- (void) genDocumentAbstract:(NSString*)documentGuid    isUpdate:(BOOL)isUpdate;
- (WizAbstract*) documentAbstractForIphone:(WizDocument*)document;
- (void) didReceivedMenoryWarning;
- (WizAbstract*) folderAbstractForIpad:(NSString*)folderKey     userID:(NSString*)userId;
@end
