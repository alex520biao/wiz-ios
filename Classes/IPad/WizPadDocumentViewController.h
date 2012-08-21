//
//  WizPadDocumentViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "WizPadCheckAttachmentDelegate.h"
#import "WizPadEditorNavigationDelegate.h"
#import "WizUiTypeIndex.h"
@class UIBadgeView;

@interface WizPadDocumentViewController : UIViewController <UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,WizPadCheckAttachmentDelegate,UIWebViewDelegate,UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate, WizPadEditorNavigationDelegate>
{
    NSUInteger listType;
    NSString* documentListKey;
    NSMutableArray* documentsArray;
    WizDocument* initDocument;
}
@property  NSUInteger listType;
@property (nonatomic, retain) NSString* documentListKey;
@property (nonatomic, retain) NSMutableArray* documentsArray;
@property (nonatomic, retain) WizDocument* initDocument;
- (void) shrinkDocumentWebView;
- (void) zoomDocumentWebView;
@end
