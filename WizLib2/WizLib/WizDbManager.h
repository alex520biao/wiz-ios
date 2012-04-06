//
//  WizDbManager.h
//  WizLib
//
//  Created by 朝 董 on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WizDbManager : NSObject
- (BOOL) isOpen;
- (BOOL) openDb;
- (void) close;
- (int64_t) documentVersion;
- (BOOL) setDocumentVersion:(int64_t)ver;
- (BOOL) updateDocument: (NSDictionary*) doc;
- (BOOL) updateDocuments: (NSArray*) documents;
- (NSArray*) recentDocuments;
+ (id) shareDbManager;
@end
