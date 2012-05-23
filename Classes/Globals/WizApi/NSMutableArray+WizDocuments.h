//
//  NSMutableArray+WizDocuments.h
//  Wiz
//
//  Created by 朝 董 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define WizNewSectionIndex      -1

typedef NSMutableArray WizDocumentsMutableArray;
@interface NSMutableArray (WizDocuments)
- (void) sortDocumentByOrder:(NSInteger)indexOrder;
- (NSIndexPath*) updateDocument:(WizDocument*)doc;
- (NSIndexPath*) removeDocument:(WizDocument*)doc;
- (NSIndexPath*) insertDocument:(WizDocument*)doc;
@end
