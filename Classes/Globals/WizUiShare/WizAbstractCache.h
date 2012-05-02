//
//  WizAbstractCache.h
//  Wiz
//
//  Created by MagicStudio on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface WizAbstractCache : NSObject
+ (id) shareCache;
- (void) genDocumentAbstract:(NSString*)documentGuid    isUpdate:(BOOL)isUpdate;
- (WizAbstract*) documentAbstractForIphone:(WizDocument*)document;
- (void) didReceivedMenoryWarning;
- (WizAbstract*) folderAbstractForIpad:(NSString*)folderKey     userID:(NSString*)userId;
@end
