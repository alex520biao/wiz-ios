//
//  DocumentListViewControllerBaseNew.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#define kOrderDate                  1
#define kOrderReverseDate           2
#define kOrderFirstLetter           3
#define kOrderReverseFirstLetter    4
@class WizDocument;

@protocol WizDocumentListMethod <NSObject>
@optional
- (void) reloadDocuments;
@end

@interface DocumentListViewControllerBaseNew : PullRefreshTableViewController <UINavigationControllerDelegate,WizDocumentListMethod>
{
    NSMutableArray* tableArray;
    NSMutableArray* sourceArray;
    NSString* accountUserID;
    int             kOrder;
    WizDocument* currentDoc;
    BOOL        isReverseDateOrdered;
    NSIndexPath* lastIndexPath;
    UIAlertView* assertAlerView;
}
@property (nonatomic, retain) NSMutableArray* tableArray;
@property (nonatomic, retain) NSString* accountUserID;
@property (nonatomic, retain) WizDocument* currentDoc;
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) UIAlertView* assertAlerView;
@property (nonatomic, retain) NSMutableArray* sourceArray;
@property (assign)  BOOL        isReverseDateOrdered;
@property int       kOrder;
- (void) reloadAllData;
- (void) orderByDate;
- (void) orderByFirstLetter;
-(void)displayProcessInfo;
-(void) syncGoing:(NSNotification*) nc;
-(void) refresh;
@end
