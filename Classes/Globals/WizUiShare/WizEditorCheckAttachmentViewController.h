//
//  WizEditorCheckAttachmentViewController.h
//  Wiz
//
//  Created by wiz on 12-7-18.
//
//

#import <UIKit/UIKit.h>
@protocol WizEditorCheckAttachmentSourceDelegate
- (NSMutableArray*) sourceAttachmentsArray;
- (NSMutableArray*) deletedAttachmentsArray;
- (void) deletedAttachmentsDone;
@end
@interface WizEditorCheckAttachmentViewController : UITableViewController
{
    id<WizEditorCheckAttachmentSourceDelegate> attachmetsSourceDelegate;
}
@property (nonatomic, assign) id<WizEditorCheckAttachmentSourceDelegate> attachmetsSourceDelegate;
@end
