//
//  WizPadListTableControllerBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DocumentListViewControllerBaseNew.h"
@interface WizPadListTableControllerBase : UITableViewController
{

    NSMutableArray* landscapeDocumentsArray;
    NSMutableArray* portraitDocumentsArray;
    NSMutableArray* sourceArray;
    NSMutableArray* tableArray;
    NSString* accountUserID;
    BOOL isLandscape;
    int kOrderIndex;
}
@property (nonatomic, retain) NSMutableArray* tableArray;
@property (nonatomic, retain) NSString* accountUserID;
@property (nonatomic, retain) NSMutableArray* sourceArray;
@property (nonatomic, retain) NSMutableArray* landscapeDocumentsArray;
@property (nonatomic, retain) NSMutableArray* portraitDocumentsArray;
@property int kOrderIndex;
@property (assign) BOOL isLandscape;
- (void) didSelectedDocument:(WizDocument*)doc;
- (void) reloadAllData;
- (void) reloadDocuments;
- (void)onAddNewDocument:(NSNotification*)nc;
@end
