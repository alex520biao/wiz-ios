//
//  DocumentInfoViewController.h
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-19.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WizFolderSelectDelegate.h"
#import "WizSelectTagDelegate.h"
@class WizDocument;
@interface DocumentInfoViewController : UITableViewController <WizFolderSelectDelegate,WizSelectTagDelegate>
{
    WizDocument* doc;
    BOOL isEditTheDoc;
}
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, assign) BOOL isEditTheDoc;
@end
