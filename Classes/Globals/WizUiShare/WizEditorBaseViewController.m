//
//  WizEditorBaseViewController.m
//  Wiz
//
//  Created by wiz on 12-7-2.
//
//

#import "WizPhoneNotificationMessage.h"
#import "WizEditorBaseViewController.h"
#import "CommonString.h"
#import <AVFoundation/AVFoundation.h>
#import "WizFileManager.h"
#import "NSArray+WizTools.h"
#import "WizSettings.h"
#import "UIImage+WizTools.h"
#import "WizDocument.h"
#import "WizGlobals.h"
#import "UIBarButtonItem+WizTools.h"
#import "WizDbManager.h"
#import "DocumentInfoViewController.h"

#import "WizRecoderProcessView.h"


#define AudioMaxProcess  40

#define WizEditingDocumentModelFileName  @"editingDocumentModel"
#define WizEditingDocumentFileName  @"editing.html"
#define WizEditingDocumentHTMLModelFileName @"editModel.html"
#define WizEditingDocumentAttachmentDirectory   @"attachment"

enum WizEditActionSheetTag {
    WizEditActionSheetTagCancelSave = 1000,
    WizEditActionSheetTagResumeEditing = 10001
    };
typedef NSInteger WizEditActionSheetTag;

enum WizEditNavigationBarItemTag {
    WizEditNavigationBarItemTagSnapPhoto = 6592,
    WizEditNavigationBarItemTagSelectPhoto,
    WizEditNavigationBarItemTagAttachment,
    WizEditNavigationBarItemTagInfo,
    WizEditNavigationBarItemTagRecorder
    };
typedef NSInteger WizEditNavigationBarItemTag;
@interface WizEditorBaseViewController () <UIWebViewDelegate,AVAudioRecorderDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIActionSheetDelegate, UIPopoverControllerDelegate>
{
    
    AVAudioRecorder *audioRecorder;
    NSTimer* audioTimer;
    CGFloat currentRecoderTime;
    //
    //
    UIView* recorderProcessView;
    UILabel* recorderProcessLabel;
    WizRecoderProcessView* recorderProcessLineView;
    //
    NSTimer* autoSaveTimer;
    //
    
    //
    UIPopoverController* currentPoperController;
    
    BOOL firstAppear;
}
@property (retain) AVAudioRecorder* audioRecorder;
@property (retain) NSTimer* audioTimer;
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@end

@implementation WizEditorBaseViewController
@synthesize audioRecorder;
@synthesize audioTimer;
@synthesize currentDeleteImagePath;
@synthesize docEdit;
@synthesize sourceDelegate;
@synthesize urlRequest;
@synthesize currentPoperController;
@synthesize padEditorNavigationDelegate;
- (void) dealloc
{
    padEditorNavigationDelegate = nil;
    [currentPoperController release];
    //
    [voiceRecognitionView release];
    //
    [audioRecorder release];
    //
    [audioTimer release];
    //
    [docEdit release];
    [attachmentsArray release];
    [deletedAttachmentsArray release];
    [editorWebView release];
    //
    sourceDelegate = nil;
    //
    [urlRequest release];
    [recorderProcessView release];
    [recorderProcessLabel release];
    [recorderProcessLineView release];
    //
    [backGroudScrollView release];
    [titleTextField release];
    //
    
    [attachmentCountView release];
    [super dealloc];
}


//- (void) webViewDidFinishLoad:(UIWebView *)webView
//{
//    NSLog(@"ddd");
//}

- (void) resizeViewWhenKeyboardHeightChanged:(CGFloat)height
{
    
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self]) {
        if ([keyPath isEqualToString:@"currentKeyboradHeigth"]) {
            
        }
    }
}

- (void) buildRecoderProcessView
{
    recorderProcessView = [[UIView alloc]init];
    recorderProcessView.backgroundColor = [UIColor brownColor];
    recorderProcessLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 80, 35)];
    [recorderProcessView addSubview:recorderProcessLabel];
    recorderProcessLabel.backgroundColor = [UIColor clearColor];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:NSLocalizedString(@"Stop", nil) forState:UIControlStateNormal];
    button.frame = CGRectMake(260, 0.0, 60, 40);
    [button addTarget:self action:@selector(stopRecord) forControlEvents:UIControlEventTouchUpInside];
    [recorderProcessView addSubview:button];
    
    recorderProcessLineView = [[WizRecoderProcessView alloc] initWithFrame:CGRectMake(80, 0.0, 200, 40)];
    recorderProcessLineView.maxProcess = AudioMaxProcess;
    [recorderProcessView addSubview:recorderProcessLineView];
}

- (void) resizeBackgrouScrollViewFrame:(CGRect)rect
{
    backGroudScrollView.frame = rect;
}

- (void) resizeBackgrouScrollViewStartY:(CGFloat)startY height:(CGFloat)height
{
    NSLog(@"startY is %f %f %f \n viewFrame is %f %f",startY,self.view.frame.size.width, height, self.view.frame.size.width,self.view.frame.size.height);
    backGroudScrollView.frame = CGRectMake(0.0, startY, self.view.frame.size.width, height);
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [editorWebView resignFirstResponder];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        CGRect mainFrame = [[UIScreen mainScreen] bounds];
        firstAppear = YES;
        attachmentsArray = [[NSMutableArray alloc] init];
        deletedAttachmentsArray = [[NSMutableArray alloc] init];
        editorWebView = [[UIWebView alloc] initWithFrame:mainFrame];
        editorWebView.delegate = self;
        //
        [self buildRecoderProcessView];
        autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(saveToLocal) userInfo:nil repeats:YES];
        
        backGroudScrollView = [[UIScrollView alloc] init];
        backGroudScrollView.contentSize = mainFrame.size;
        backGroudScrollView.backgroundColor = [UIColor blackColor];
        
        backGroudScrollView.frame = [[UIScreen mainScreen] bounds];
        editorWebView.frame = CGRectMake(0.0, 30, mainFrame.size.width, mainFrame.size.height -30);
        editorWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [backGroudScrollView addSubview:editorWebView];
        //
        
        titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0.0, -1, mainFrame.size.width, 31)];
        titleTextField.delegate = self;
        titleTextField.backgroundColor = [UIColor whiteColor];
        titleTextField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

        CALayer* titleLayer = titleTextField.layer;
        titleLayer.cornerRadius = 2;
        titleLayer.borderColor = [UIColor lightGrayColor].CGColor;
        titleLayer.borderWidth = 1;
        //
        attachmentCountView = [[UIBadgeView alloc] init];
    }
    return self;
}

- (void) deleteWebInsideImage
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSError* error = nil;   
    if (currentDeleteImagePath) {
        if ([fileManager fileExistsAtPath:self.currentDeleteImagePath]) {
            if ([fileManager removeItemAtPath:self.currentDeleteImagePath error:&error]) {
                NSLog(@"delete image error %@",error);
            }
        }
    }
    [editorWebView deleteImage];
}

- (void) fixWebInsideImage:(NSString*)filePath
{
    self.currentDeleteImagePath = filePath;
    UIActionSheet* action = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Remove Image", nil) delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:NSLocalizedString(@"Remove Image", nil) otherButtonTitles:nil];
    action.tag =  WizEditActionTagFixImage;
    [action showInView:self.view];
    [action release];
}
- (void) fixWebHttpInsideImage
{
    [self fixWebInsideImage:nil];
}

+ (NSString*)editingFilePath
{
    static NSString* editingFilePath=nil;
    if (nil == editingFilePath) {
        editingFilePath = [[[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:WizEditingDocumentFileName] retain];
    }
    return editingFilePath;
}

+ (NSString*) editingIndexFilePath
{
    static NSString* editingFilePath=nil;
    if (nil == editingFilePath) {
        editingFilePath = [[[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:@"index.html"] retain];
    }
    return editingFilePath;
}

+ (NSString*) editingMobileFilePath
{
    static NSString* editingFilePath=nil;
    if (nil == editingFilePath) {
        editingFilePath = [[[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:@"wiz_mobile.html"] retain];
    }
    return editingFilePath;
}

+ (NSString*) editingHtmlModelFilePath
{
    static NSString* editingFilePath=nil;
    if (nil == editingFilePath) {
        editingFilePath = [[[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:WizEditingDocumentHTMLModelFileName] retain];
    }
    return editingFilePath;
}

+ (NSString*) editingDocumentModelFilePath
{
    static NSString* editingFilePath=nil;
    if (nil == editingFilePath) {
        editingFilePath = [[[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:WizEditingDocumentModelFileName] retain];
    }
    return editingFilePath;
}


- (void) saveToLocal
{
    NSString* editingFilePath = [WizEditorBaseViewController editingDocumentModelFilePath];
    
    NSDictionary* doc = [self.docEdit getModelDictionary];
    
    if (![doc writeToFile:editingFilePath atomically:YES]) {
        [WizGlobals toLog:@"write to editingModelFile error"];
    };
    if ([WizGlobals WizDeviceVersion] < 5) {
        [self autoSaveLessThan5];
    }
    else
    {
        [self autoSaveMoreThan5];
    }
}

- (BOOL) isEditorEnviromentFile:(NSString*)fileName
{
    if ([fileName isEqualToString:@"js"]) {
        return YES;
    }
    else if ([fileName isEqualToString:WizEditingDocumentHTMLModelFileName])
    {
        return YES;
    }
    else if ([fileName isEqualToString:WizEditingDocumentFileName])
    {
        return YES;
    }
    else if ([fileName isEqualToString:WizEditingDocumentModelFileName])
    {
        return YES;
    }
    else if ([fileName isEqualToString:WizEditingDocumentAttachmentDirectory])
    {
        return YES;
    }
    return NO;
}

BOOL (^isWillNotClearFile)(NSString*) = ^(NSString* file)
{
    NSString* fileName = [file fileName];
    if ([fileName isEqualToString:@"js"]) {
        return YES;
    }
    else if ([fileName isEqualToString:WizEditingDocumentHTMLModelFileName])
    {
        return YES;
    }
    return NO;
};

- (void) clearEditorEnviromentLessThan5
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* editorPath = [fileManager editingTempDirectory];
    NSError* error = nil;
    for (NSString* each in [fileManager contentsOfDirectoryAtPath:editorPath error:nil])
    {
        if (!isWillNotClearFile(each)) {
            if (![fileManager removeItemAtPath:[editorPath stringByAppendingPathComponent:each] error:&error]) {
                NSLog(@"error %@",error);
            }
        }
    }
}

- (void) saveToLocalFile:(NSString*)body
{
    NSString* indexFilePath = [WizEditorBaseViewController editingIndexFilePath];
    NSString* moblieFilePath = [WizEditorBaseViewController editingMobileFilePath];
    
    NSString* html = [NSString stringWithFormat:@"<html><body>%@</body></html>",body];
    [html writeToFile:indexFilePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
    [html writeToFile:moblieFilePath atomically:YES encoding:NSUTF16StringEncoding error:nil];
}
- (void) prepareForSave
{
    
}
- (void) autoSaveMoreThan5
{
    NSString* body = [editorWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    [self saveToLocalFile:body];
}
- (void) autoSaveLessThan5
{
    NSString* body = [editorWebView stringByEvaluatingJavaScriptFromString:@"documentEditedBody()"];
    body = [body stringReplaceUseRegular:@"<wiz[^>]*>|</wiz>"];
    body = [body stringReplaceUseRegular:@"<div[^>]*WizStartInsertDivIndentity[^>]*></div>"];
    body = [body stringReplaceUseRegular:@"<div[^>]*WizEndInsertDivIndentity[^>]*></div>"];
    [self saveToLocalFile:body];
}

- (void) saveAttachments
{
    for (WizAttachment* attach in attachmentsArray) {
        if (attach.localChanged == WizAttachmentEditTypeTempChanged) {
            attach.documentGuid = self.docEdit.guid;
            [attach saveData:attach.description];
        }
    }
    for (WizAttachment* each in deletedAttachmentsArray) {
        [WizAttachment deleteAttachment:each.guid];
    }
}

- (BOOL) containsAudio
{
    for (WizAttachment* each in attachmentsArray) {
        if ([WizGlobals checkAttachmentTypeIsAudio:[each.title fileType]]) {
            return YES;
        }
    }
    return NO;
}

- (void) doSaveDocument
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* docPath = [fileManager objectFilePath:self.docEdit.guid];
    NSString* indexFilesPath = [docPath stringByAppendingPathComponent:@"index_files"];
    [fileManager ensurePathExists:docPath];
    [fileManager ensurePathExists:indexFilesPath];
    NSArray* content = [fileManager contentsOfDirectoryAtPath:[fileManager editingTempDirectory] error:nil];
    for (NSString* each in content)
    {
        if (![self isEditorEnviromentFile:each])
        {
            NSString* sourcePath = [[fileManager editingTempDirectory] stringByAppendingPathComponent:each];
            NSString* toPath = [docPath stringByAppendingPathComponent:each];
            NSError* error = nil;
            if ([fileManager fileExistsAtPath:toPath])
            {
                [fileManager removeItemAtPath:toPath error:nil];
            }
            [fileManager moveItemAtPath:sourcePath toPath:toPath error:&error];
            if (error)
            {
                NSLog(@"error %@",error);
            }
        }
    }
    NSString* bodyText = [editorWebView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];
    
    if (nil == titleTextField.text || [titleTextField.text isBlock] || [titleTextField.text isEqualToString:WizStrNoTitle])
    {
        if (bodyText && ![bodyText isBlock]) {
                if (bodyText.length > 20) {
                    bodyText = [bodyText substringToIndex:20];
                }
                self.docEdit.title = bodyText;
        }
        else
        {
            BOOL containsImage = [editorWebView containImages];
            BOOL containsAudio = [self containsAudio];
            if (containsAudio && !containsImage) {
                self.docEdit.title = [NSString stringWithFormat:@"%@ %@",WizStrNewDocumentTitleAudio, [[NSDate date] stringLocal]];
            }
            else if(!containsAudio && containsImage)
            {
                self.docEdit.title = [NSString stringWithFormat:@"%@ %@",WizStrNewDocumentTitleImage, [[NSDate date] stringLocal]];
            }
            else
            {
                self.docEdit.title = [NSString stringWithFormat:@"%@ %@",WizStrNewDocumentTitleNoTitle, [[NSDate date] stringLocal]];
            }
            
        }
    }
    else
    {
        self.docEdit.title = titleTextField.text;
    }
    for (WizAttachment* eachAttach in deletedAttachmentsArray) {
        [WizAttachment deleteAttachment:eachAttach.guid];
        [[[WizDbManager shareDbManager] shareDataBase] addDeletedGUIDRecord:eachAttach.guid type:WizAttachmentKeyString];
    }
    self.docEdit.attachmentCount = [attachmentsArray count];
    [self.docEdit saveWithHtmlBody:@""];
    [self saveAttachments];
    [self clearEditorEnviromentLessThan5];
}

- (void) saveDocument
{
    [self dismissPoperController];
    [autoSaveTimer invalidate];
    [self prepareForSave];
    [self saveToLocal];
    [self doSaveDocument];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    if (self.padEditorNavigationDelegate) {
        [self.padEditorNavigationDelegate didEditCurrentDocumentDone];
    }
}

- (void) changeFonts
{
    NSLog(@"selected");
}

- (void) buildMenu
{
//    UIMenuItem* change = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Changed", nil) action:@selector(changeFonts)];
//    NSMutableArray* array = [NSMutableArray arrayWithArray:[[UIMenuController sharedMenuController] menuItems]];
//    [array addObject:change];
//    [change release];
//    [[UIMenuController sharedMenuController] setMenuItems:array];
    
}

- (void) doSnapPhotoPhone
{
    UIImagePickerController* pick = [self snapPhoto:self];
    [self.navigationController presentModalViewController:pick animated:YES];
}
- (void) doSelectPhotoPhone
{
    UIImagePickerController* pick = [self selectPhoto:self];
    [self.navigationController presentModalViewController:pick animated:YES];
}

- (void) doSelectPhotoPad
{
    UIImagePickerController* pick = [self selectPhoto:self];
    self.currentPoperController = [[[UIPopoverController alloc] initWithContentViewController:pick] autorelease];
    UIBarButtonItem* selectPhotoItem=self.navigationItem.rightBarButtonItem;
    if ([WizGlobals WizDeviceVersion] < 5.0) {
        UIView* titleView = self.navigationItem.titleView;
        if ([titleView isKindOfClass:[UIToolbar class]]) {
            UIToolbar* titleToolBar = (UIToolbar*)titleView;
            for (UIBarButtonItem* eachItem in titleToolBar.items) {
                if (eachItem.tag == WizEditNavigationBarItemTagSelectPhoto) {
                    selectPhotoItem = eachItem;
                }
            }
        }
    }
    else
    {
        for (UIBarButtonItem* each in self.navigationItem.rightBarButtonItems) {
            if (each.tag == WizEditNavigationBarItemTagSelectPhoto) {
                selectPhotoItem = each;
                break;
            }
        }
    }
    [currentPoperController presentPopoverFromBarButtonItem:selectPhotoItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void) doSelectPhoto
{
    if ([WizGlobals WizDeviceIsPad]) {
        [self doSelectPhotoPad];
    }
    else
    {
        [self doSelectPhotoPhone];
        
    }
}

- (void) doRecorderPhone
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    recorderProcessView.frame = CGRectMake(0.0 , 0.0, self.view.frame.size.width, 40);
    
    for (UIView* each in [recorderProcessView subviews]) {
        if ([each isKindOfClass:[UIButton class]]) {
            each.frame = CGRectMake(recorderProcessView.frame.size.width-80, 0.0, 80, 40);
        }
        else if ([each isKindOfClass:[UILabel class]]) {
            each.frame = CGRectMake(0.0, 0.0, 80, 40);
        }
        else if ([each isKindOfClass:[WizRecoderProcessView class]])
        {
            each.frame = CGRectMake(80, 0.0, recorderProcessView.frame.size.width-160, 40);
        }
    }
    
    [self.view addSubview:recorderProcessView];
    [self resizeBackgrouScrollViewStartY:40 height:backGroudScrollView.frame.size.height];
    [self startRecord];
}
- (void) doSetDocumentInfo
{
    DocumentInfoViewController* info = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    info.doc = self.docEdit;
    info.isEditTheDoc = YES;
    [self.navigationController pushViewController:info animated:YES];
    [info release];
}
- (void) buildPhoneNavigationTools
{
    UIBarButtonItem* snap = [UIBarButtonItem barButtonItem:[UIImage imageNamed:@"attachTakePhotoPad"] hightImage:[UIImage imageNamed:@"edit"] target:self action:@selector(doSnapPhotoPhone)];
    snap.tag = WizEditNavigationBarItemTagSnapPhoto;
    
    UIBarButtonItem* select = [UIBarButtonItem barButtonItem:[UIImage imageNamed:@"attachSelectPhotoPad"] hightImage:[UIImage imageNamed:@"edit"] target:self action:@selector(doSelectPhoto)];
    select.tag = WizEditNavigationBarItemTagSelectPhoto;
    
    UIBarButtonItem* recoder = [UIBarButtonItem barButtonItem:[UIImage imageNamed:@"attachRecorderPad"] hightImage:[UIImage imageNamed:@"edit"] target:self action:@selector(doRecorderPhone)];
    recoder.tag = WizEditNavigationBarItemTagRecorder;
    
    UIBarButtonItem* info = [UIBarButtonItem barButtonItem:[UIImage imageNamed:@"detail_gray"] hightImage:[UIImage imageNamed:@"edit"] target:self action:@selector(doSetDocumentInfo)];
    info.tag = WizEditNavigationBarItemTagInfo;
    
    UIBarButtonItem* attachments = [UIBarButtonItem barButtonItem:[UIImage imageNamed:@"newNoteAttach_gray"] hightImage:[UIImage imageNamed:@"newNoteAttach_gray"] target:self action:@selector(checkAttachment)];
    attachments.tag = WizEditNavigationBarItemTagAttachment;
    attachmentCountView.frame = CGRectMake(20, -10, 20, 20);
    attachmentCountView.badgeString = @"0";
    [attachments.customView addSubview:attachmentCountView];
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray* tools = [NSMutableArray array];
    [tools addObject:flex];
    [tools addObject:info];
    [tools addObject:flex];
    if ([self canSnapPhotos]) {
        [tools addObject:snap];
        [tools addObject:flex];
    }
    
    [tools addObject:select];
    [tools addObject:flex];
    if ([self canRecord]) {
        [tools addObject:recoder];
        [tools addObject:flex];
    }
    [tools addObject:attachments];
    [tools addObject:flex];
    if ([WizGlobals WizDeviceVersion] >= 5.0)
    {
        [tools insertObject:self.navigationItem.rightBarButtonItem atIndex:0];
        self.navigationItem.rightBarButtonItems = tools;
    }
    else
    {
        UIToolbar* navigationToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 40)];
        navigationToolBar.items = tools;
        navigationToolBar.backgroundColor = [UIColor clearColor];
        self.navigationItem.titleView = navigationToolBar;
        [navigationToolBar release];
    }
   
    [flex release];
}


- (void) copyJSModelToEditorEnviromentLessThan5:(NSString*)name  type:(NSString*)type
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* editPath = [fileManager editingTempDirectory];
    //js
    NSString* jsPath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    NSString* jsEditPath = [editPath stringByAppendingPathComponent:@"js"];
    [fileManager ensurePathExists:jsEditPath];
    NSString* jsFilePath = [jsEditPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",name,type]];
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
}
- (void) showEditErrorMessage
{
    
}

- (void) buildCommonEditorEnviromentLessThan5
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    [self copyJSModelToEditorEnviromentLessThan5:@"jquery" type:@"js"];
    NSError* error = nil;
    NSString* editorModelPath = [[NSBundle mainBundle] pathForResource:@"editModel" ofType:@"html"];
    NSString* editorModelHtmlPath = [WizEditorBaseViewController editingHtmlModelFilePath];
    if ([fileManager fileExistsAtPath:editorModelHtmlPath]) {
        if(![fileManager removeItemAtPath:editorModelHtmlPath error:&error]);
        {
            NSLog(@"error %@",error);
        }
    }
    NSStringEncoding encoding;
    NSString* string = [NSString stringWithContentsOfFile:editorModelPath usedEncoding:&encoding error:&error];
    if (string) {
       if (![string writeToFile:editorModelHtmlPath atomically:YES encoding:encoding error:&error])
       {
           NSLog(@"%@",error);
       }
    }
}

- (BOOL) copySourceFileToEditDirectory:(WizDocument*)doc
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* documentObjectPath = [fileManager objectFilePath:self.docEdit.guid];
    NSString* editPath = [fileManager editingTempDirectory];
    NSError* error = nil;
    for (NSString* each in [fileManager contentsOfDirectoryAtPath:documentObjectPath error:nil]  ) {
        NSString* sourcePath = [documentObjectPath stringByAppendingPathComponent:each];
        NSString* toPath = [editPath stringByAppendingPathComponent:each];
        if ([fileManager fileExistsAtPath:toPath]) {
            if (![fileManager removeItemAtPath:toPath error:&error]) {
                NSLog(@"error %@",error);
                return NO;
            };
        }
        if(![fileManager copyItemAtPath:sourcePath toPath:toPath error:&error])
        {
            NSLog(@"coyp edit source error error is %@",error);
            return NO;
        }
    }
    return YES;
}

- (BOOL) prepareEditingFileL5:(NSString*)sourcePath
{
    NSStringEncoding contentEncoding;
    NSError* error = nil;
    NSString* content =[NSString stringWithContentsOfFile:sourcePath usedEncoding:&contentEncoding error:&error];
    if (!content) {
        content = @"";
    }
    NSString* editingFile = [WizEditorBaseViewController editingFilePath];
    NSString* modelFile = [WizEditorBaseViewController editingHtmlModelFilePath];
    NSMutableString* modelContent = [NSMutableString stringWithContentsOfFile:modelFile usedEncoding:nil error:&error];
    
    content  =  [modelContent stringByReplacingOccurrencesOfString:@"IOSWizEditor" withString:[content processHtml]];
    NSLog(@"%@",content);
    if (![content writeToFile:editingFile useUtf8Bom:YES error:&error])
    {
        NSLog(@"write error%@",error);
        return NO;
    }
    return YES;
}

- (NSURL*) buildEditorEnviromentLessThan5
{
    [self buildCommonEditorEnviromentLessThan5];
    NSURL* ret = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"errorModel" ofType:@"html"]];
    if (self.docEdit)
    {
        if ([self copySourceFileToEditDirectory:self.docEdit])
        {
            if ([self prepareEditingFileL5:[WizEditorBaseViewController editingIndexFilePath]] ) {
                ret = [NSURL fileURLWithPath:[WizEditorBaseViewController editingFilePath]];
            }
        }
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
        ret = [NSURL fileURLWithPath:toUrl];
    }
    return ret;
}

- (NSURL*) buildEditorEnviromentMoreThan5
{
    NSURL* ret = nil;
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* editPath = [fileManager editingTempDirectory];
    NSString* editingFilePath = [editPath stringByAppendingPathComponent:WizEditingDocumentFileName];
    
    NSError* error = nil;
    if (self.docEdit) {
        
        NSString* documentObjectPath = [fileManager objectFilePath:self.docEdit.guid];

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
        NSString* documentIndex = [editPath stringByAppendingPathComponent:@"index.html"];
        if ([fileManager fileExistsAtPath:editingFilePath]) {
            if (![fileManager removeItemAtPath:editingFilePath error:&error]) {
                NSLog(@"error %@",error);
            }
        }
        if (![fileManager moveItemAtPath:documentIndex toPath:editingFilePath error:&error]) {
            NSLog(@"error %@",error);
        }
        ret = [NSURL fileURLWithPath:editingFilePath];
    }
    else
    {
        self.docEdit = [[[WizDocument alloc] init] autorelease];
        NSString* content = [NSString stringWithFormat:@"<html><body></body></html>"];
        if (![content writeToFile:editingFilePath useUtf8Bom:YES error:&error]) {
            NSLog(@"error %@",error);
        }
        ret = [NSURL fileURLWithPath:editingFilePath]; 
    }
    return ret;
}

- (id) initWithWizDocument:(WizDocument*)doc
{
    self = [super init];
    if (self) {
        self.docEdit = doc;
    }
    return self;
}

- (void) postSelectedMessageToPicker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfMainPickSelectedView object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:TypeOfMainPickerViewIndex]];
}
- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == WizEditActionTagFixImage) {
        switch (buttonIndex) {
            case 0:
                [self deleteWebInsideImage];
                return;
            default:
                return;
        }
    }
    else
    {
        if (buttonIndex == 1) {
            return;
        }
        else if (buttonIndex == 0)
        {
            if (autoSaveTimer) {
                [autoSaveTimer invalidate];
            }
            [self clearEditorEnviromentLessThan5];
            [self postSelectedMessageToPicker];
            [self.navigationController dismissModalViewControllerAnimated:YES];
            
            if (self.padEditorNavigationDelegate) {
                [self.padEditorNavigationDelegate didEditCurrentDocumentCancel];
            }
        }
    }
    
}

- (void) dismissPoperController
{
    if (currentPoperController) {
        [currentPoperController dismissPopoverAnimated:YES];
    }
}

- (void) cancelSaveDocument
{
    [self dismissPoperController];
    [self stopRecord];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrAreyousureyouwanttoquit delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:WizStrQuitwithoutsaving otherButtonTitles:nil, nil];
    actionSheet.tag = WizEditActionSheetTagCancelSave;
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
    
    [self buildPhoneNavigationTools];
    titleTextField.frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen] bounds].size.width, 31);
    
    [backGroudScrollView addSubview:titleTextField];
    
    [cancelBtn release];
    [saveBtn release];
    //
    backGroudScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:backGroudScrollView];
    titleTextField.text = self.docEdit.title;
    [editorWebView loadRequest:self.urlRequest];
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
    [self.audioRecorder updateMeters];
    [recorderProcessLineView setCurrentProcess:(AudioMaxProcess - ABS([self.audioRecorder peakPowerForChannel:0]))];
    
    currentRecoderTime+=0.1f;
    recorderProcessLabel.text = [WizGlobals timerStringFromTimerInver:currentRecoderTime];
}
- (NSString*) getAttachmentEditingFileName
{
    NSString* attachmentpath = [[[WizFileManager shareManager] editingTempDirectory] stringByAppendingPathComponent:WizEditingDocumentAttachmentDirectory];
    [[WizFileManager shareManager] ensurePathExists:attachmentpath];
    return [attachmentpath stringByAppendingPathComponent:[WizGlobals genGUID]];
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
    NSString* audioFileName = [[self getAttachmentEditingFileName] stringByAppendingString:@".aif"];
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
- (void) showAttachmentCount
{
    attachmentCountView.badgeString = [NSString stringWithFormat:@"%d",[attachmentsArray count]];
}
- (void) addAttachmentDone:(NSString*)path
{
    [attachmentsArray addAttachmentBySourceFile:path];
    [self showAttachmentCount];
}
- (NSMutableArray*) sourceAttachmentsArray
{
    NSLog(@"a coutn %d",[attachmentsArray count]);
    return attachmentsArray;
}
- (NSMutableArray*) deletedAttachmentsArray
{
    return deletedAttachmentsArray;
}
- (void) deletedAttachmentsDone
{
    [self  showAttachmentCount];
}

- (void) checkAttachment
{
    WizEditorCheckAttachmentViewController* checkAttach = [[WizEditorCheckAttachmentViewController alloc] init];
    checkAttach.attachmetsSourceDelegate = self;
    [self.navigationController pushViewController:checkAttach animated:YES];
    [checkAttach release];
}
- (void) willAddAudioDone:(NSString *)audioPath
{
    [self addAttachmentDone:audioPath];
    recorderProcessView.frame = CGRectMake(-900, 0.0, 0.0, 0.0);
//    [editorWebView insertAudio:audioPath];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self resizeBackgrouScrollViewStartY:0.0 height:backGroudScrollView.frame.size.height];
}
- (BOOL) isRecording
{
    if (nil == self.audioRecorder)
    {
        return NO;
    }
    return [self.audioRecorder isRecording];
}
- (BOOL) stopRecord
{
    if (nil == self.audioRecorder || ![self.audioRecorder isRecording]) {
        return YES;
    }
    [self.audioRecorder stop];
    [self.audioTimer invalidate];
    currentRecoderTime = 0.0f;
    [self willAddAudioDone:self.audioRecorder.url.relativePath];
    return YES;
}


//
- (void) willAddPhotoDone:(NSString *)photoPath
{
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
    [self willAddPhotoDone:fileNamePath];
    [self.currentPoperController dismissPopoverAnimated:YES];
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
- (void) resumeLastEditong
{
    WizFileManager* fileManager = [WizFileManager shareManager];
    NSString* editingPath = [fileManager editingTempDirectory];
    NSString* editingFile = [editingPath stringByAppendingPathComponent:WizEditingDocumentFileName];
    NSString* editingDocumentModel = [editingPath stringByAppendingPathComponent:WizEditingDocumentModelFileName];
    self.docEdit = [[[WizDocument alloc] initFromDictionaryModel:[NSDictionary dictionaryWithContentsOfFile:editingDocumentModel]] autorelease];
    if ([WizGlobals WizDeviceVersion] < 5) {
        [self prepareEditingFileL5:[WizEditorBaseViewController editingIndexFilePath]];
    }
    self.urlRequest = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:editingFile]];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (firstAppear) {
        NSArray* attachs = [self.docEdit attachments];
        for (WizAttachment* each in attachs) {
            [attachmentsArray addWizObjectUnique:each];
        }
        firstAppear = NO;
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showAttachmentCount];
}

@end
