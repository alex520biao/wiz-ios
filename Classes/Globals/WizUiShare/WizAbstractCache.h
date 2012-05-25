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
- (WizAbstract*) documentAbstractForIphone:(WizDocument*)document;
- (void) didReceivedMenoryWarning;
- (NSString*) getFolderAbstract:(NSString*)key;
- (NSString*) getTagAbstract:(NSString*)tagGuid;
@end
