//
//  WizPadListTableControllerBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSMutableArray+WizDocuments.h"
#import "WizPadListCell.h"
#import "WizPadViewDocumentDelegate.h"
#import "WizSyncDescriptionDelegate.h"
@interface WizPadListTableControllerBase : UITableViewController <WizSyncDescriptionDelegate,WizPadCellSelectedDocumentDelegate>
{
    WizDocumentsMutableArray* tableArray;
    BOOL isLandscape;
    int kOrderIndex;
    id <WizPadViewDocumentDelegate> checkDocumentDelegate;
}
@property (nonatomic, assign) id <WizPadViewDocumentDelegate> checkDocumentDelegate;
@property (atomic, retain) WizDocumentsMutableArray* tableArray;
@property int kOrderIndex;
@property (assign) BOOL isLandscape;
- (void) didSelectedDocument:(WizDocument*)doc;
- (void) reloadAllData;
- (NSArray*) reloadDocuments;
@end
