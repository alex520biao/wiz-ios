//
//  WizCheckAttachments.h
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WizCheckAttachments : UITableViewController <UIAlertViewDelegate,UIDocumentInteractionControllerDelegate>
{
    WizDocument* doc;
}
@property (nonatomic, retain) WizDocument* doc;
- (void) downloadDone:(NSNotification*)nc;
@end
