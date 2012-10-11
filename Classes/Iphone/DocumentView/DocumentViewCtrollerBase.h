//
//  DocumentViewCtrollerBase.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ATMHudDelegate.h"

#import "WizReadDocumentDelegate.h"


@interface DocumentViewCtrollerBase : UIViewController <MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIActionSheetDelegate,UIWebViewDelegate, UISearchBarDelegate, UIGestureRecognizerDelegate,ATMHudDelegate>
{
    WizDocument* doc;
}
@property (nonatomic , assign) id<WizReadDocumentDelegate> listDelegate;
@property (nonatomic, assign,getter = getDocument) WizDocument* doc;
@end
