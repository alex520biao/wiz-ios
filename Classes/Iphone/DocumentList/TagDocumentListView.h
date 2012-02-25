//
//  TagDocumentListView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewControllerBaseNew.h"
@class WizTag;
@interface TagDocumentListView : DocumentListViewControllerBaseNew
{
    WizTag* tag;
}
@property (nonatomic, retain) WizTag* tag;
- (void) onSyncEnd;
- (void) displayProcessInfo;
- (void) refresh;
@end
