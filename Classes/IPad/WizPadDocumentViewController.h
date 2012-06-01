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
@class UIBadgeView;

@interface WizPadDocumentViewController : UIViewController <UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,WizPadCheckAttachmentDelegate,UIWebViewDelegate,UITableViewDelegate, UITableViewDataSource,UIAlertViewDelegate>
{
    NSUInteger listType;
    NSString* documentListKey;
    NSMutableArray* documentsArray;
}
@property  NSUInteger listType;
@property (nonatomic, retain) NSString* documentListKey;
@property (nonatomic, retain) NSMutableArray* documentsArray;
- (void) shrinkDocumentWebView;
- (void) zoomDocumentWebView;
@end
