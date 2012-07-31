//
//  NewNoteView.h
//  Wiz
//
//  Created by dong zhao on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "WizEditNoteBase.h"
#import "WizSelectTagViewController.h"
#import "WizFolderSelectDelegate.h"
#import "MBProgressHUD.h"
@protocol WizSelectTagDelegate;
@interface NewNoteView : WizEditNoteBase <UIActionSheetDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate,WizSelectTagDelegate,WizFolderSelectDelegate,MBProgressHUDDelegate>
- (void) prepareForEdit:(NSString*)body attachments:(NSArray*)attachments;
@end





