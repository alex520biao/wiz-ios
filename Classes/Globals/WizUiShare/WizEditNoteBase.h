//
//  WizEditNoteBase.h
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define ATTACHMENTTEMPFLITER @"attchmentTempFliter"

@class ELCImagePickerController;
@interface WizEditNoteBase : UIViewController<AVAudioRecorderDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    @private
    AVAudioRecorder *recorder;
	AVAudioSession *session;
    NSTimer* timer;
    NSMutableString* currentRecodingFilePath;
    float currentTime;
    NSMutableArray* attachmentSourcePath;
    @public
    NSString* accountUserId;
    NSString* editDocumentGuid;
}
@property (retain) AVAudioRecorder* recorder;
@property (retain) AVAudioSession* session;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain)  NSString* editDocumentGuid;
@property (retain) NSTimer* timer;
@property (nonatomic, retain)  NSMutableString* currentRecodingFilePath;
@property (nonatomic, retain) NSMutableArray* attachmentSourcePath;
@property float currentTime;
- (void) audioStartRecode;
-(void) audioStopRecord;
-(float) updateTime;
-(void) updateAttachment:(NSString*) filePath;
-(UIImagePickerController*) takePhotoViewSelcevted;
-(ELCImagePickerController*) photoViewSelected;
@end
