//
//  WizPadEditNoteController.h
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizEditNoteBase.h"
#import "WizSelectTagViewController.h"
#import "WizFolderSelectDelegate.h"
@class UIBadgeView;
@interface WizPadEditNoteController : WizEditNoteBase <UIActionSheetDelegate,UIScrollViewDelegate,UIPopoverControllerDelegate,UITextFieldDelegate,WizSelectTagDelegate,WizFolderSelectDelegate>
- (void) prepareForEdit:(NSString*)body attachments:(NSArray*)attachments;
@end
