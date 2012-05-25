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

@interface WizPadListTableControllerBase : UITableViewController <WizPadCellSelectedDocumentDelegate>
{
    WizDocumentsMutableArray* tableArray;
    BOOL isLandscape;
    int kOrderIndex;
    
    id <WizPadViewDocumentDelegate> checkDocumentDelegate;
}
@property (nonatomic, assign) id <WizPadViewDocumentDelegate> checkDocumentDelegate;
@property (nonatomic, retain) WizDocumentsMutableArray* tableArray;
@property int kOrderIndex;
@property (assign) BOOL isLandscape;
- (void) didSelectedDocument:(WizDocument*)doc;
- (void) reloadAllData;
- (NSArray*) reloadDocuments;
- (void)onAddNewDocument:(NSNotification*)nc;
@end
