//
//  WizTableViewController.h
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizNotification.h"
#import "WizSyncDescriptionDelegate.h"

@interface WizTableViewController : UITableViewController <WizSyncDescriptionDelegate>
{
    @private
    NSMutableArray* tableSourceArray;
    NSUInteger kOrderIndex;
}
@property(retain, atomic) NSMutableArray* tableSourceArray;
@property (atomic)NSUInteger kOrderIndex;
- (NSArray*) reloadAllDocument;
- (void) deleteDocument:(NSString*)documentGuid;
- (void) insertDocument:(WizDocument*)doc indexPath:(NSIndexPath*)indexPath;
- (NSInteger) documentsCount;
- (void) reloadAllData;
@end

