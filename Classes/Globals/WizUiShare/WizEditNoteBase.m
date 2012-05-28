//
//  WizEditNoteBase.m
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizEditNoteBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizApi.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "WizFileManager.h"
#import "WizSettings.h"



@interface WizEditNoteBase()
{
    AVAudioRecorder *recorder;
	AVAudioSession *session;
    NSTimer* timer;
    NSMutableString* currentRecodingFilePath;
    
    
    
}
@property (retain) AVAudioRecorder* recorder;
@property (retain) AVAudioSession* session;
@property (retain) NSTimer* timer;

@property (nonatomic, retain)  NSMutableString* currentRecodingFilePath;

@end

@implementation WizEditNoteBase
@synthesize session;
@synthesize recorder;
@synthesize docEdit;
@synthesize timer;
@synthesize currentRecodingFilePath;
@synthesize currentTime;
@synthesize attachmentsArray;
- (void) dealloc
{
    [attachmentsArray release];
    [currentRecodingFilePath release];
    [session release];
    [recorder release];
    [super dealloc];
}
- (void) attachmentAddDone
{
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        attachmentsArray = [[NSMutableArray array] retain];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void) stopRecording
{
    if (nil == self.recorder || ![self.recorder isRecording]) {
        return;
    }
    [self.recorder stop];
    [self.timer invalidate];
    currentTime = 0.0f;
    [self.attachmentsArray addAttachmentBySourceFile:self.currentRecodingFilePath];
    [self attachmentAddDone];
}

-(BOOL) startAudioSession
{
    NSError* error;
    self.session = [AVAudioSession sharedInstance];
    if(![self.session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error])
    {
        return NO;
    }
    if(![self.session setActive:YES error:&error])
    {
        return NO;
    }
    return self.session.inputIsAvailable;
}

-(float) updateTime
{
    currentTime += 0.1f;
    return self.currentTime;
}

-(BOOL) record
{
    NSError* error;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt:1 ] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    NSString* audioFileName = [[[WizFileManager shareManager] getAttachmentSourceFileName] stringByAppendingString:@".aif"];
    self.currentRecodingFilePath = [[audioFileName mutableCopy] autorelease];
    NSURL* url = [NSURL fileURLWithPath:audioFileName];
    self.recorder = [[[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error ] autorelease];
    if(!self.recorder)
    {
        return NO;
    }
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    if(![self.recorder prepareToRecord])
    {
        return NO;
    }
    if(![self.recorder record])
    {
        return NO;
    }
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    currentTime = 0.0f;
    [error release];
    return YES;
}


- (void) audioStartRecode
{
    [self record];
}

-(void) audioStopRecord
{
    [self stopRecording];
}



- (BOOL) takePhoto
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentModalViewController:picker animated:YES];
        return YES;
    }
    return NO;
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image compressedImage:[[WizSettings defaultSettings] imageQualityValue]];
    NSString* fileNamePath = [[[WizFileManager shareManager] getAttachmentSourceFileName] stringByAppendingString:@".jpg"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileNamePath atomically:YES];
    [picker dismissModalViewControllerAnimated:YES];
    //2012-2-26 delete
    //    UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
    [self.attachmentsArray addAttachmentBySourceFile:fileNamePath];
    [self attachmentAddDone];
}

-(BOOL) selectePhotos
{
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    [albumController release];
    [self.navigationController presentModalViewController:elcPicker animated:YES];
    return YES;
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    NSLog(@"image quality %lld",[[WizSettings defaultSettings] imageQualityValue]);
    for(NSDictionary* each in info)
    {
        UIImage* image = [each objectForKey:UIImagePickerControllerOriginalImage];
        image = [image compressedImage:[[WizSettings defaultSettings] imageQualityValue]];
        NSString* fileNamePath = [[[WizFileManager shareManager] getAttachmentSourceFileName] stringByAppendingString:@".jpg"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileNamePath atomically:YES];
        [self.attachmentsArray addAttachmentBySourceFile:fileNamePath];
    }
    [self attachmentAddDone];
    [self elcImagePickerControllerDidCancel:picker];
}
- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
}
@end
