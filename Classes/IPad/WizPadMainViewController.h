//
//  WizPadMainViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WizPadListTableControllerBase;
@class PadFoldersController;
@class PadTagController;
@interface WizPadMainViewController : UIViewController <UIPopoverControllerDelegate,UISearchBarDelegate,UISearchDisplayDelegate,UIAlertViewDelegate>
{
    UISegmentedControl* mainSegment;
    NSString* accountUserId;
    NSMutableArray* controllersArray;
    int selectedController;
    UIPopoverController* currentPoperController;
    UILabel* refreshProcessLabel;
    
    WizPadListTableControllerBase* recentList;
    PadTagController* tagList;
    PadFoldersController* folderList;
    
    UIBarButtonItem* refreshItem;
    UIBarButtonItem* stopRefreshItem;
    @private
    BOOL syncWillStop;
    UIButton* refreshButton;
}
@property (nonatomic, retain) UISegmentedControl* mainSegment;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain)  NSMutableArray* controllersArray;
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@property (nonatomic, retain) UILabel* refreshProcessLabel;
@property (nonatomic, retain) UIBarButtonItem* refreshItem;
@property (nonatomic, retain) UIBarButtonItem* stopRefreshItem;
@property (nonatomic, retain) WizPadListTableControllerBase* recentList;
@property (nonatomic, retain) PadTagController* tagList;
@property (nonatomic, retain) PadFoldersController* folderList;
@property (nonatomic, retain)    UIButton* refreshButton;
@property BOOL syncWillStop;
@property int selectedControllerIndex;
- (void) checkDocument:(NSNotification*)nc;
-(void) syncGoing:(NSNotification*) nc;
- (void) refreshAccountBegin:(id) sender;
@end
