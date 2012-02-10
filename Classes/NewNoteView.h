//
//  NewNoteView.h
//  Wiz
//
//  Created by dong zhao on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@class WizDocument;

@class AVAudioRecorder;
@class AVAudioSession;
@class VoiceRecognition;
@interface NewNoteView : UIViewController <AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>{
    AVAudioRecorder *recorder;
	AVAudioSession *session;
    NSString* accountUserId;
    NSTimer* timer;
    UILabel* recoderLabel;
    UITextField* titleTextFiled;
    UITextView* bodyTextField;
    UILabel* attachmentsCountLabel;
    NSMutableString* currentRecodingFilePath;
    NSMutableString* documentTags;
    NSMutableString* documentFloder;
    BOOL            isNewDocument;
    NSString* documentGUID;
    UIButton* attachmentsTableviewEntryButton;
    UIView* addAttachmentView;
    UIView* addDocumentInfoView;
    UIView* inputContentView;
    UIImageView* keyControl;
    NSMutableArray* AddAttachments;
    float  currentTIme;
    VoiceRecognition* voiceInput;
    id firtResponser;
}
@property (retain) AVAudioSession           *session;
@property (retain) AVAudioRecorder          *recorder;
@property (retain)  VoiceRecognition* voiceInput;
@property (retain) NSTimer* timer;
@property (nonatomic, retain) NSString      *accountUserId;
@property (nonatomic, retain) UILabel*      recoderLabel;
@property (nonatomic, retain) UITextField*  titleTextFiled;
@property (nonatomic, retain) UITextView*   bodyTextField;
@property (nonatomic, retain) UILabel*      attachmentsCountLabel;
@property (nonatomic, retain) NSMutableString* documentTags;
@property (nonatomic, retain) NSMutableString* documentFloder;
@property (nonatomic, retain) NSMutableString* currentRecodingFilePath;
@property (nonatomic, retain) NSString*         documentGUID;
@property (nonatomic, retain) NSMutableArray* AddAttachments;
@property (nonatomic, retain) UIImageView* keyControl;

@property (nonatomic, retain) UIView* addAttachmentView;
@property (nonatomic, retain) UIView* addDocumentInfoView;
@property (nonatomic, retain) UIView* inputContentView;
@property (nonatomic, retain)     UIButton* attachmentsTableviewEntryButton;
@property (nonatomic, retain) id firtResponser;
@property  BOOL          isNewDocument;
@property float currentTime;

-(BOOL) startAudioSession;
-(void) updateAttachment:(NSString*) filePath;
- (void) addDocumentInfoViewAnimation;
- (void) addAttachmentsViewAnimation;
- (void) startVoiceInput;
- (void) voiceInputOver:(NSString*)result;
@end
