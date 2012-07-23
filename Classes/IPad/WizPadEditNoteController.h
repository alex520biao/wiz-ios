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
#import "WizPadNewNoteViewNavigationDelegate.h"
#import "WizPadEditorNavigationDelegate.h"

@class UIBadgeView;
@interface WizPadEditNoteController : WizEditNoteBase <UIActionSheetDelegate,UIScrollViewDelegate,UIPopoverControllerDelegate,UITextFieldDelegate,WizSelectTagDelegate,WizFolderSelectDelegate>
{
    id <WizPadNewNoteViewNavigationDelegate> navigateDelegate;
    id <WizPadEditorNavigationDelegate> editorNavigateDelegate;
}
@property (nonatomic, assign) id <WizPadEditorNavigationDelegate> editorNavigateDelegate;
@property (nonatomic, assign) id <WizPadNewNoteViewNavigationDelegate> navigateDelegate;
- (void) prepareForEdit:(NSString*)body attachments:(NSArray*)attachments;
@end
