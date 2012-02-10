//
//  WizPadDocumentViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UIBadgeView;
@interface WizPadDocumentViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
{
    UIWebView* webView;
    UIView* headerView;
    UITableView* documentList;
    NSMutableArray* documentsArray;
    NSMutableArray* sourceArray;
    NSString* accountUserId;
    NSUInteger listType;
    NSString* documentListKey;
    UILabel* documentNameLabel;
    NSString* selectedDocumentGUID;
    UIBarButtonItem* attachmentBarItem;
    UIBarButtonItem* infoBarItem;
    UIBarButtonItem* editBarItem;
    UIBarButtonItem* searchItem;
    
    UIBadgeView* attachmentCountBadge;
    
    UIActivityIndicatorView* refreshIndicatorView;
    
    UIPopoverController* currentPopoverController;
    UIButton* zoomOrShrinkButton;
    @private
    UIAlertView* alertView;
}
@property (nonatomic,retain) UIAlertView* alertView;
@property (nonatomic,retain) UIButton* zoomOrShrinkButton;
@property (nonatomic, retain)  UIWebView* webView;
@property (nonatomic, retain) UIView* headerView;
@property (nonatomic, retain) UITableView* documentList;
@property (nonatomic, retain)  NSString* accountUserId;
@property (nonatomic, retain)   NSMutableArray* sourceArray;
@property (nonatomic, retain) NSString* documentListKey;
@property (nonatomic, retain) NSMutableArray* documentsArray;
@property (nonatomic, retain) UILabel* documentNameLabel;
@property (nonatomic, retain)    NSString* selectedDocumentGUID;
@property (nonatomic, retain)   UIBarButtonItem* attachmentBarItem;
@property (nonatomic, retain)   UIBarButtonItem* infoBarItem;
@property (nonatomic, retain)   UIBarButtonItem* editBarItem;
@property (nonatomic, retain)   UIBarButtonItem* searchItem;
@property (nonatomic, retain)  UIPopoverController* currentPopoverController;
@property (nonatomic, retain)  UIActivityIndicatorView* refreshIndicatorView;
@property (nonatomic, retain) UIBadgeView* attachmentCountBadge;
@property  NSUInteger listType;

- (void) shrinkDocumentWebView;
- (void) zoomDocumentWebView;

@end
