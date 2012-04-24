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

@interface NewNoteView : WizEditNoteBase <UIActionSheetDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
@end
