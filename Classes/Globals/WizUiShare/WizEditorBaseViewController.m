//
//  WizEditorBaseViewController.m
//  Wiz
//
//  Created by wiz on 12-7-2.
//
//

#import "WizPhoneNotificationMessage.h"
#import "WizEditorBaseViewController.h"

#import <AVFoundation/AVFoundation.h>
#import "WizFileManager.h"
#import "NSArray+WizTools.h"
#import "WizSettings.h"
#import "UIImage+WizTools.h"
#import "WizDocument.h"
#import "WizGlobals.h"
@interface WizEditorBaseViewController () <UIWebViewDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate>
{
    NSMutableArray* attachmentsArray;
    
    AVAudioRecorder *audioRecorder;
	AVAudioSession *audioSession;
    NSTimer* audioTimer;
    CGFloat currentRecoderTime;
    //
    NSURLRequest* urlRequest;
    //
    NSTimer* autoSaveTimer;
}
@property (retain) AVAudioRecorder* audioRecorder;
@property (retain) AVAudioSession* audioSession;
@property (retain) NSTimer* audioTimer;
@property (nonatomic, retain) NSURLRequest* urlRequest;
@end

@implementation WizEditorBaseViewController

- (void) dealloc
{
    //
    [audioRecorder release];
    [audioSession release];
    [audioTimer release];
    //
    [docEdit release];
    [attachmentsArray release];
    [editorWebView release];
    //
    sourceDelegate = nil;
    //
    [urlRequest release];
    //
    [super dealloc];
}


//- (void) webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSLog(@"ddd");
//}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        attachmentsArray = [[NSMutableArray alloc] init];
        editorWebView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        editorWebView.delegate = self;
        //
//        autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(saveToLocal) userInfo:nil repeats:YES];
    }
    return self;
}

- (void) saveToLocal
{
    NSString* body = [editorWebView getDocumentBodyHtml];
    NSString* indexFilePath = [[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:@"index.html"];
    NSString* moblieFilePath = [[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:@"wiz_moblie.html"];
    
    NSString* html = [NSString stringWithFormat:@"<html><body>%@</body></html>",body];
    [html writeToFile:indexFilePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
    [html writeToFile:moblieFilePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
}

- (void) saveDocument
{
    [self saveToLocal];
    NSString* string = [editorWebView getDocumentBodyHtml];
    [autoSaveTimer invalidate];
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* docPath = [fileManager objectFilePath:self.docEdit.guid];
    NSString* indexFilesPath = [docPath stringByAppendingPathComponent:@"index_files"];
    [fileManager ensurePathExists:docPath];
    [fileManager ensurePathExists:indexFilesPath];
    NSArray* content = [fileManager contentsOfDirectoryAtPath:[fileManager editingTempDirectory] error:nil];
    for (NSString* each in content) {
        NSString* sourcePath = [[fileManager editingTempDirectory] stringByAppendingPathComponent:each];
        NSString* toPath = [docPath stringByAppendingPathComponent:each];
        NSError* error = nil;
        if ([fileManager fileExistsAtPath:toPath]) {
            [fileManager removeItemAtPath:toPath error:nil];
        }
        [fileManager copyItemAtPath:sourcePath toPath:toPath error:&error];
        if (error) {
            NSLog(@"error %@",error);
        }
    }
    NSLog(@"editor doc is %@",self.docEdit.guid);
    [self.docEdit saveWithHtmlBody:string];
    [fileManager clearEditingTempDirectory];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
//    NSLog(@"%@ %@",string,self.docEdit.guid);
//    
//    [document writeToFile:documentIndexFile atomically:YES encoding:NSUTF16StringEncoding error:nil];
    
}

- (void) changeFonts
{
    NSLog(@"selected");
}

- (void) buildMenu
{
    UIMenuItem* change = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Changed", nil) action:@selector(changeFonts)];
    NSMutableArray* array = [NSMutableArray arrayWithArray:[[UIMenuController sharedMenuController] menuItems]];
    [array addObject:change];
    [change release];
    [[UIMenuController sharedMenuController] setMenuItems:array];
    
}
- (NSString*) editorModelHtmlPath
{
   return [ [[WizFileManager shareManager]editingTempDirectory] stringByAppendingPathComponent:@"editModel.html"];
}
- (NSString*) editingModelHtmlPath
{
    return [ [[WizFileManager shareManager]editingTempDirectory] stringByAppendingPathComponent:@"editing.html"];
}
- (void) buildEditorEnviroment
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* editPath = [fileManager editingTempDirectory];
    //js
    NSString* jsPath = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js"];
    NSString* jsEditPath = [editPath stringByAppendingPathComponent:@"js"];
    [fileManager ensurePathExists:jsEditPath];
    NSString* jsFilePath = [jsEditPath stringByAppendingPathComponent:@"jquery.js"];
    
    NSError* error = nil;
    
    if (![fileManager fileExistsAtPath:jsFilePath]) {
        NSStringEncoding jsEndcoding;
        NSString* jsContent = [NSString stringWithContentsOfFile:jsPath usedEncoding:&jsEndcoding error:&error];
        if (!jsContent) {
            NSLog(@"error %@",error);
        }
        if (![jsContent writeToFile:jsFilePath atomically:YES encoding:jsEndcoding error:&error]) {
            NSLog(@"w e %@",error);
        };
    }
    NSString* editorModelPath = [[NSBundle mainBundle] pathForResource:@"editModel" ofType:@"html"];

    NSString* editorModelHtmlPath = [self editorModelHtmlPath];
    
    if (![fileManager fileExistsAtPath:editorModelHtmlPath]) {
        NSStringEncoding encoding;
        NSString* string = [NSString stringWithContentsOfFile:editorModelPath usedEncoding:&encoding error:nil];
        if (string) {
           if (![string writeToFile:editorModelHtmlPath atomically:YES encoding:encoding error:&error])
           {
               NSLog(@"%@",error);
           }
        }
    }
}

- (id) initWithWizDocument:(WizDocument*)doc
{
    self = [super init];
    if (self) {
        if (doc) {
            [self buildEditorEnviroment];
            self.docEdit = doc;
            WizFileManager* fileManager = [WizFileManager shareManager];
            NSString* documentObjectPath = [fileManager objectFilePath:doc.guid];
            NSString* editPath = [fileManager editingTempDirectory];
            NSError* error = nil;
            

            for (NSString* each in [fileManager contentsOfDirectoryAtPath:documentObjectPath error:nil]  ) {
                NSString* sourcePath = [documentObjectPath stringByAppendingPathComponent:each];
                NSString* toPath = [editPath stringByAppendingPathComponent:each];
                
                if ([fileManager fileExistsAtPath:toPath]) {
                    [fileManager removeItemAtPath:toPath error:nil];
                }
                if(![fileManager copyItemAtPath:sourcePath toPath:toPath error:&error])
                {
                     NSLog(@"error is %@",error);
                }
            }

            
//            
//            NSString* path = [editPath stringByAppendingPathComponent:@"index.html"];
//            NSStringEncoding contentEncoding;
//            
//            NSString* content =[NSString stringWithContentsOfFile:path usedEncoding:&contentEncoding error:&error];
//            
//            
//            if (!content) {
//                NSLog(@"%@",error);
//            }
//            NSLog(@"content encoding is %u",contentEncoding);
//            
//            
//            int64_t indexBBegain = [content indexOf:@"<body>"];
//            NSInteger indexBEnd   = [content indexOf:@"</body>"];
//            if (indexBBegain != NSNotFound && indexBEnd != NSNotFound) {
//                content = [content substringWithRange:NSMakeRange(indexBBegain, indexBEnd-indexBBegain+7)];
//                content = [content stringReplaceUseRegular:@"(<[^>]*>)" withString:@"</wiz>$1<wiz>"];
//                content = [content substringWithRange:NSMakeRange(6, content.length -6 -5)];
//            }
//           
//
//            NSString* editingFile = [self editingModelHtmlPath];
//            NSString* modelFile = [self editorModelHtmlPath];
//            NSMutableString* modelContent = [NSMutableString stringWithContentsOfFile:modelFile usedEncoding:nil error:&error];
//            if (!modelContent) {
//                NSLog(@"%@",error);
//            }
//            NSLog(@"%@=============",content);
//             content  =  [modelContent stringByReplacingOccurrencesOfString:@"<body>IOSWizEditor</body>" withString:content];
//            NSLog(@"model %@",content);
//
//            NSString* string = [NSString stringWithUTF8String:[content UTF8String]];
//            [string writeToFile:editingFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            
            
            NSURL* url = [NSURL fileURLWithPath:editingFile];
            self.urlRequest = [NSURLRequest requestWithURL:url];
            
        }
        else
        {
            WizDocument* doc = [[WizDocument alloc] init];
            doc.guid = [WizGlobals genGUID];
            self.docEdit = doc;
            [doc release];
            NSString* url = [[NSBundle mainBundle] pathForResource:@"editModel" ofType:@"html"];
            NSString* toUrl = [[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:@"index.html"];
            
            NSString* content = [NSString stringWithContentsOfFile:url usedEncoding:nil error:nil];
            NSError* error = nil;
            [content writeToFile:toUrl atomically:YES encoding:NSUTF16StringEncoding error:&error];
            
            if (error) {
                NSLog(@"%@",error);
            }
            
            NSURL* loadUrl = [NSURL fileURLWithPath:toUrl];
            
            if (!loadUrl) {
                NSLog(@"error");
            }
            self.urlRequest = [NSURLRequest requestWithURL:loadUrl];

        }
    }
    return self;
}

- (void) postSelectedMessageToPicker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfMainPickSelectedView object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:TypeOfMainPickerViewIndex]];
}
- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        return;
    }
    else if (buttonIndex == 0)
    {
        [self postSelectedMessageToPicker];
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}
- (void) cancelSaveDocument
{
    [self stopRecord];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrAreyousureyouwanttoquit delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:WizStrQuitwithoutsaving otherButtonTitles:nil, nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    [actionSheet release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    [self buildMenu];
    //
    UIBarButtonItem* saveBtn = [[UIBarButtonItem alloc] initWithTitle:WizStrSave style:UIBarButtonItemStyleBordered target:self action:@selector(saveDocument)];
    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleBordered target:self action:@selector(cancelSaveDocument)];
    
    self.navigationItem.leftBarButtonItem = cancelBtn;
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    [cancelBtn release];
    [saveBtn release];
    //
    [self.view addSubview:editorWebView];
    [editorWebView loadRequest:self.urlRequest];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) canRecord
{
    return YES;
}

- (BOOL) canSnapPhotos
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void) updateTime
{
    currentRecoderTime+=0.1f;
}

- (BOOL) startRecord
{
    NSError* error = nil;
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    [settings setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [settings setValue:[NSNumber numberWithFloat:8000.0] forKey:AVSampleRateKey];
    [settings setValue:[NSNumber numberWithInt:1 ] forKey:AVNumberOfChannelsKey];
    [settings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [settings setValue:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    NSString* audioFileName = [[[WizFileManager shareManager] getAttachmentSourceFileName] stringByAppendingString:@".aif"];
    NSURL* url = [NSURL fileURLWithPath:audioFileName];
    self.audioRecorder = [[[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error ] autorelease];
    if(!self.audioRecorder)
    {
        NSLog(@"%@",error);
        return NO;
    }
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
    if(![self.audioRecorder prepareToRecord])
    {
        return NO;
    }
    if(![self.audioRecorder record])
    {
        return NO;
    }
    self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    currentRecoderTime = 0.0f;
    return YES;
}
- (void) addAttachmentDone:(NSString*)path
{
    [attachmentsArray addAttachmentBySourceFile:path];
}

- (void) willAddAudioDone:(NSString *)audioPath
{
    [self addAttachmentDone:audioPath];
}
- (BOOL) stopRecord
{
    if (nil == self.audioRecorder || ![self.audioRecorder isRecording]) {
        return YES;
    }
    [self.audioRecorder stop];
    [self.audioTimer invalidate];
    currentRecoderTime = 0.0f;
    [self willAddAudioDone:self.audioRecorder.url.absoluteString];
    return YES;
}


//
- (void) willAddPhotoDone:(NSString *)photoPath
{
    [self addAttachmentDone:photoPath];

    [editorWebView insertImage:photoPath];
}

- (UIImagePickerController*) snapPhoto:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)parentController
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    if (!parentController) {
        picker.delegate = self;
    }
    else
    {
        picker.delegate = parentController;
    }
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    return [picker autorelease];
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
    [self willAddPhotoDone:fileNamePath];
}

- (UIImagePickerController*) selectPhoto:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) parentController
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    if (!parentController) {
        picker.delegate = self;
    }
    else
    {
        picker.delegate = parentController;
    }
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    return [picker autorelease];
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}
//
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
@end
