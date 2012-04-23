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


@implementation WizEditNoteBase
@synthesize session;
@synthesize editDocumentGuid;
@synthesize recorder;
@synthesize accountUserId;
@synthesize timer;
@synthesize currentRecodingFilePath;
@synthesize currentTime;
@synthesize attachmentSourcePath;
- (void) dealloc
{
    [attachmentSourcePath release];
    [currentRecodingFilePath release];
    [session release];
    [editDocumentGuid release];
    [recorder release];
    [accountUserId release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) updateAttachment:(NSString*) filePath
{    
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    [[index newAttachment:filePath documentGUID:self.editDocumentGuid] autorelease];
}

-(void) stopRecording
{
    [self.recorder stop];
    [self.timer invalidate];
    self.currentTime = 0.0f;
    [self.attachmentSourcePath addObject:self.currentRecodingFilePath];
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
    self.currentTime += 0.1f;
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
//    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:ATTACHMENTTEMPFLITER];
//    [WizGlobals ensurePathExists:objectPath];
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString* dateString = [formatter stringFromDate:[NSDate date]];
//    [formatter release];
//    NSString* audioFileName = [objectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aif",dateString]];
    NSString* audioFileName = [[WizGlobals getAttachmentSourceFileName:self.accountUserId] stringByAppendingString:@".aif"];
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
    self.currentTime = 0.0f;
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

-(ELCImagePickerController*) photoViewSelected
{
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    [albumController release];
    return [elcPicker autorelease];
}



-(UIImagePickerController*) takePhotoViewSelcevted
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        return [picker autorelease];
    }
    return nil;
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

@end
