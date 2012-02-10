//
//  DocumentListViewControllerBase.h
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PullRefreshTableViewController.h"
@class WizDocument;
@interface DocumentListViewControllerBase : PullRefreshTableViewController {
	NSString* accountUserId;
	NSMutableArray* documents;
	//
	UIAlertView* waitAlertView;
	WizDocument* currentDocument;
	//
	UIBarButtonItem* syncButton;
	UIBarButtonItem* activeButton;
}

@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) NSMutableArray* documents;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) WizDocument* currentDocument;
@property (nonatomic, retain) UIBarButtonItem* syncButton;
@property (nonatomic, retain) UIBarButtonItem* activeButton;

- (NSArray*) reloadDocuments;
- (BOOL) isBusy;
- (BOOL) canSync;
- (NSString*) titleForView;
- (void) syncDocuments;
- (NSString*) syncDocumentsXmlRpcMethod;
-(void)displayProcessInfo;
-(void) syncGoing:(NSNotification*) nc;
@end
