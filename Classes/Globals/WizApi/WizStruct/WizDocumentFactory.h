//
//  WizDocumentFactory.h
//  Wiz
//
//  Created by 朝 董 on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WizDocument;
@interface WizDocumentFactory : NSObject
+ (NSArray*) recentDocuments;
+ (NSArray*) documentsByTag: (NSString*)tagGUID;
+ (NSArray*) documentsByKey: (NSString*)keywords;
+ (NSArray*) documentsByLocation: (NSString*)parentLocation;
+ (NSArray*) documentForUpload;
+ (WizDocument*) documentFromGuid:(NSString*)guid;
@end
