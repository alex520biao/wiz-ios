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
#import "NSMutableArray+WizDocuments.h"
#import "PullRefreshTableViewController.h"

@interface WizTableViewController : PullRefreshTableViewController <WizSyncDescriptionDelegate>
{
    @private
    WizDocumentsMutableArray* tableSourceArray;
    NSUInteger kOrderIndex;
}
@property(retain, atomic) WizDocumentsMutableArray* tableSourceArray;
@property (atomic)NSUInteger kOrderIndex;
- (NSArray*) reloadAllDocument;
- (NSInteger) documentsCount;
- (void) reloadAllData;
+ (UILabel*) noDocumentsLabel;
+ (UIView*) noDocumentsBackGroudView;
@end

