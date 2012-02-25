//
//  FolderListView.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewControllerBaseNew.h"

@interface FolderListView : DocumentListViewControllerBaseNew <WizDocumentListMethod>
{
    NSString* location;
}
@property (nonatomic, retain) NSString* location;
- (void) onSyncEnd;
- (void) displayProcessInfo;
- (void) refresh;
@end
