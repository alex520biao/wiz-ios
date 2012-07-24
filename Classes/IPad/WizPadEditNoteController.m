//
//  WizPadEditNoteController.m
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadEditNoteController.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "SelectFloderView.h"
#import "WizSelectTagViewController.h"
#import "WizPadNotificationMessage.h"
#import "WizDictionaryMessage.h"
#import "UIBadgeView.h"
#import "WizPadCheckAttachments.h"
#import "WizNotification.h"
#import "WizDbManager.h"
#import "WizDocument.h"
#import "WizEditorBaseViewController.h"

#define titleInputTextFieldFrame CGRectMake(0.0,0.0,768,44)
#define folderLabelFrame CGRectMake(0.0, 45, 768, 44)
#define tagLabelFrame CGRectMake(0.0, 90, 768, 44)
#define bodyInputTextViewFrame CGRectMake(0.0, 135, 768, 592)
#define bodyInputTextViewPotraitFrame CGRectMake(0.0, 135, 768, 845)
#define backgroudScrollViewLandscapeFrame CGRectMake(0.0,0.0,1024,768)
#define backgroudScrollViewPotraitFrame CGRectMake(0.0,0.0,768,1024)


@interface WizPadEditNoteController ()
{
    UITextView* bodyInputTextView;
    UITextField* titleInputTextField;
    UITextField* tagTextField;
    UITextField* folderTextField;
    UIScrollView* backgroudScrollView;
    CGFloat  bodyInputViewHeigth;
    UIPopoverController* currentPopoverController;
    UIImageView* timerView;
    BOOL isNewDocument;
    UIBadgeView* attachmentsCountView;
}

@property (nonatomic, retain) UIPopoverController* currentPopoverController;
@end


@implementation WizPadEditNoteController
@synthesize currentPopoverController;
@synthesize navigateDelegate;
@synthesize editorNavigateDelegate;

- (void) dealloc
{
    editorNavigateDelegate = nil;
    navigateDelegate = nil;
    [WizNotificationCenter removeObserver:self];
    [timerView release];
    [currentPopoverController release];
    [bodyInputTextView release];
    [titleInputTextField release];
    [tagTextField release];
    [folderTextField release];
    [backgroudScrollView release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAttachments:) name:MessageOfDeleteAttachments object:nil];
        [self buildView];
    }
    return self;
}
- (void) displayAttachmentsCount
{
    [attachmentsCountView setBadgeString:[NSString stringWithFormat:@"%d",[self.attachmentsArray count]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) didSelectedFolderString:(NSString *)folderString
{
    folderTextField.text = folderString;
    self.docEdit.location = folderString;
}
- (NSString*) selectedFolderOld
{
    return self.docEdit.location;
}
- (void) popverViewController:(UIViewController*)contentViewController  fromRect:(CGRect)rect   permittedArrowDirections:(UIPopoverArrowDirection)direction
{
    if (nil != self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:YES];
        self.currentPopoverController = nil;
    }
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    self.currentPopoverController = pop;
    [pop release];
    [self.currentPopoverController presentPopoverFromRect:rect inView:backgroudScrollView permittedArrowDirections:direction animated:YES ];
}
- (void) folderViewSelected:(id)sender
{
    SelectFloderView*  floderView = [[SelectFloderView alloc] initWithStyle:UITableViewStyleGrouped];
    floderView.selectDelegate = self;
    [self popverViewController:floderView fromRect:CGRectMake(750, 0.0, 320, backgroudScrollView.contentOffset.y+132) permittedArrowDirections:UIPopoverArrowDirectionRight];
    [floderView release];
}

- (NSString*) displayTagName:(NSString*)tagName
{
    return [NSString stringWithFormat:@"%@%@%@%@",@"\"",tagName,@"\"",@","];
}
- (void) didSelectedTags:(NSArray *)tags
{
    [self.docEdit setTagWithArray:tags];
    tagTextField.text = [self.docEdit tagDisplayString];
}
- (NSArray*) selectedTagsOld
{
    return [self.docEdit tagDatas];
}
- (void) tagViewSelected
{
    WizSelectTagViewController* tagView = [[WizSelectTagViewController alloc]initWithStyle:UITableViewStyleGrouped];
    tagView.selectDelegate = self;
    [self popverViewController:tagView fromRect:CGRectMake(750, 0.0, 320, backgroudScrollView.contentOffset.y+220) permittedArrowDirections:UIPopoverArrowDirectionRight];
    [tagView release];
}

- (void) setBackgroudScrollViewFrame:(UIInterfaceOrientation)interface
{
    if (UIInterfaceOrientationIsLandscape(interface)) {
        backgroudScrollView.frame = backgroudScrollViewLandscapeFrame;
        backgroudScrollView.contentSize = CGSizeMake(1024, 1024);
    }
    else
    {
        backgroudScrollView.frame = backgroudScrollViewPotraitFrame;
        backgroudScrollView.contentSize = CGSizeMake(768, 1324);
    }
}

- (void) buildInputView
{
    UIFont* font = [UIFont systemFontOfSize:17];
    
    bodyInputTextView = [[UITextView alloc] initWithFrame:bodyInputTextViewFrame];
    [backgroudScrollView addSubview:bodyInputTextView];
    bodyInputTextView.font = font;
    [bodyInputTextView setContentMode:UIViewContentModeBottom];
    
    titleInputTextField = [[UITextField alloc] initWithFrame:titleInputTextFieldFrame];
    [backgroudScrollView addSubview:titleInputTextField];
    titleInputTextField.backgroundColor = [UIColor whiteColor];
    NSString* titleRemindText = [NSString stringWithFormat:@"%@:",WizStrTitle];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0.0, [titleRemindText sizeWithFont:font].width +10, 44)];
    titleLabel.text = titleRemindText;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = font;
    titleInputTextField.leftView = titleLabel;
    titleLabel.textColor= [UIColor grayColor];
    [titleLabel release];
    titleInputTextField.leftViewMode = UITextFieldViewModeAlways;
    titleInputTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    tagTextField = [[UITextField alloc] initWithFrame:tagLabelFrame];
    tagTextField.delegate = self;
    [backgroudScrollView addSubview:tagTextField];
    NSString* tagRemindText = [NSString stringWithFormat:@"%@:",WizStrTags];
    UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, [tagRemindText sizeWithFont:font].width + 10, 44)];
    tagTextField.leftViewMode = UITextFieldViewModeAlways;
    tagTextField.leftView = tagLabel;
    tagTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tagLabel.font = font;
    tagLabel.textAlignment = UITextAlignmentCenter;
    tagLabel.text = tagRemindText;
    [tagTextField setBackgroundColor:[UIColor whiteColor]];
    tagLabel.textColor = [UIColor grayColor];
    UIButton* tagButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [tagButton addTarget:self action:@selector(tagViewSelected) forControlEvents:UIControlEventTouchUpInside];
    tagTextField.rightViewMode = UITextFieldViewModeAlways;
    tagTextField.rightView = tagButton;
    [tagLabel release];

    
    folderTextField = [[UITextField alloc] initWithFrame:folderLabelFrame];
    [backgroudScrollView addSubview:folderTextField];
    folderTextField.delegate = self;
    NSString* folderRemindText = [NSString stringWithFormat:@"%@:",WizStrFolders];
    UILabel* folderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, [folderRemindText sizeWithFont:font].width+10, 44)];
    folderTextField.leftView = folderLabel;
    folderTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    folderTextField.leftViewMode = UITextFieldViewModeAlways;
    folderLabel.textColor = [UIColor grayColor];
    folderLabel.text = folderRemindText;
    folderLabel.font = font;
    folderLabel.textAlignment = UITextAlignmentCenter;
    folderTextField.backgroundColor = [UIColor whiteColor];
    UIButton* folderButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [folderButton addTarget:self action:@selector(folderViewSelected:) forControlEvents:UIControlEventTouchUpInside];
    folderTextField.rightView = folderButton;
    folderTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [folderLabel release];

    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        bodyInputTextView.frame = bodyInputTextViewFrame;
    }
    else
    {
        bodyInputTextView.frame = bodyInputTextViewPotraitFrame;
    }
    bodyInputViewHeigth = bodyInputTextView.frame.size.height;
    [self displayAttachmentsCount];
}
- (void) keyboardWillShow:(NSNotification*)nc
{
    BOOL selfViewIsFirstResponser = NO;
    for (UIView* each in  backgroudScrollView.subviews) {
        if ([each isFirstResponder]) {
            selfViewIsFirstResponser = YES;
        }
    }
    if (!selfViewIsFirstResponser ) {
        return;
    }
    NSDictionary* userInfo = [nc userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat width = kbSize.width > kbSize.height?kbSize.height:kbSize.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:bodyInputTextView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    bodyInputTextView.frame = CGRectMake(0.0, 135, 768, bodyInputTextView.frame.size.height-width+backgroudScrollView.contentOffset.y);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        bodyInputViewHeigth = bodyInputTextViewFrame.size.height-width;
    }
    else
    {
        bodyInputViewHeigth = bodyInputTextViewPotraitFrame.size.height-width;
    }
    [UIView setAnimationDuration:0.5];
    [UIView commitAnimations];

}

- (void) keyboardWillHide:(NSNotification*)nc
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    NSDictionary* userInfo = [nc userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat width = kbSize.width > kbSize.height?kbSize.height:kbSize.width;
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:bodyInputTextView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    bodyInputTextView.frame = CGRectMake(0.0, 135, bodyInputTextView.frame.size.width, bodyInputTextView.frame.size.height+width);
    bodyInputViewHeigth = bodyInputTextView.frame.size.height;
    bodyInputViewHeigth = bodyInputTextView.frame.size.height;
    [UIView setAnimationDuration:1.0];
    [UIView commitAnimations];

}
- (void) actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        return;
    }
    else if (buttonIndex == 0)
    {
        [self.navigationController dismissModalViewControllerAnimated:YES];
    }
}
- (void) autoSaveDocument
{
    if (self.docEdit) {
        NSString* body = [bodyInputTextView.text toHtml];
        NSString* title = titleInputTextField.text;
        self.docEdit.title = title;
        self.docEdit.localChanged = WizEditDocumentTypeAllChanged;
        
        NSString* modelFile = [WizEditorBaseViewController editingDocumentModelFilePath];
        NSDictionary* dic = [self.docEdit getModelDictionary];
        if (![dic writeToFile:modelFile atomically:YES])
        {
            NSLog(@"write model error");
        }
        NSString* indexFilePath = [WizEditorBaseViewController editingIndexFilePath];
        NSString* html = [NSString stringWithFormat:@"<html><body>%@</body></html>",body];
        NSError* error = nil;
        if (![html writeToFile:indexFilePath useUtf8Bom:YES error:&error]) {
            NSLog(@"error %@",error);
        }
    }
}

- (void) cancelSave
{
    [self stopAutoSaveDocument];
    [self audioStopRecord];
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrAreyousureyouwanttoquit delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:WizStrQuitwithoutsaving otherButtonTitles:nil, nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    [actionSheet release];
}
- (void) saveDocument
{
    [self stopAutoSaveDocument];
    [self audioStopRecord];
    self.docEdit.title = titleInputTextField.text;
    [self.docEdit saveWithData:bodyInputTextView.text attachments:self.attachmentsArray];
    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigateDelegate newNoteWillDisappear];
    [self.editorNavigateDelegate didEditCurrentDocumentDone];
}

- (float) updateTime
{
    float time = [super updateTime];
    for (UIView* each in timerView.subviews) {
        if ([each isKindOfClass:[UILabel class]]) {
            UILabel* timeLabel = (UILabel*)each;
            timeLabel.text = [WizGlobals timerStringFromTimerInver:time];
        }
    }
    return 0;
}

- (void) buildNavigationItems
{
    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelSave)];
    self.navigationItem.leftBarButtonItem = cancel;
    [cancel release];
    
    UIBarButtonItem* save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveDocument)];
    self.navigationItem.rightBarButtonItem = save;
    [save release];
}

- (void) stopRecorder:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"attachRecorderPad"] forState:UIControlStateNormal];
    [btn removeTarget:self action:@selector(stopRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:timerView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    timerView.alpha = 0.0;
    for (UIView* each in timerView.subviews) {
        if ([each isKindOfClass:[UILabel class]]) {
            UILabel* timeLabel =(UILabel*)each;
            [timeLabel setText:@"00:00"];
        }
    }
    [UIView commitAnimations];
    [self audioStopRecord];
}
- (void) startRecorder:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"stopRecorder"] forState:UIControlStateNormal];
    [btn removeTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(stopRecorder:) forControlEvents:UIControlEventTouchUpInside];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:timerView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    timerView.alpha = 1.0;
    [UIView commitAnimations];
    [self audioStartRecode];
}
- (void) attachmentAddDone
{
    [self displayAttachmentsCount];
}
- (void) checkAttachments:(id)sender
{
    WizPadCheckAttachments* checkAttachments = [[WizPadCheckAttachments alloc] init];
    checkAttachments.source = self.attachmentsArray;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:checkAttachments];
    [checkAttachments release];
    [self popverViewController:nav fromRect:CGRectMake(630, 0.0, 0.1, 10) permittedArrowDirections:UIPopoverArrowDirectionUp];
    [currentPopoverController setContentViewController:nav animated:YES];
    [nav release];
}
- (void) prepareForEdit:(NSString*)body attachments:(NSArray*)attachments
{
    bodyInputTextView.text = body;
    [self.attachmentsArray addObjectsFromArray:attachments];
}
- (BOOL) selectePhotos
{
    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self popverViewController:picker fromRect:CGRectMake(630, 0.0, 0.1, 10) permittedArrowDirections:UIPopoverArrowDirectionUp];
    return YES;
}
- (void) buildNavigtionTitleView
{
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 678, 44)];
    
    UIButton* recorder = [UIButton buttonWithType:UIButtonTypeCustom];
    [recorder setImage:[UIImage imageNamed:@"attachRecorderPad"] forState:UIControlStateNormal];
    recorder.frame = CGRectMake(390, 7, 30, 30);
    [recorder addTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:recorder];
    
    timerView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorderTimeBack"]];
    timerView.frame = CGRectMake(300, 7, 80, 30);
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 30)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = @"00:00";
    [timerView addSubview:timeLabel];
    timeLabel.textAlignment = UITextAlignmentCenter;
    [timeLabel release];
    timerView.alpha = 0.0;
    [titleView addSubview:timerView];
    
    UIButton* selectPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectPhoto setImage:[UIImage imageNamed:@"attachSelectPhotoPad"] forState:UIControlStateNormal];
    selectPhoto.frame = CGRectMake(470, 7, 30, 30);
    [selectPhoto addTarget:self action:@selector(selectePhotos) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:selectPhoto];
    
    UIButton* attachmentsCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [attachmentsCheck setImage:[UIImage imageNamed:@"newNoteAttachG"] forState:UIControlStateNormal];
    [titleView addSubview:attachmentsCheck];
    attachmentsCountView = [[UIBadgeView alloc] initWithFrame:CGRectMake(25, -5, 20, 20)];
    [attachmentsCheck addSubview:attachmentsCountView];
    [attachmentsCheck addTarget:self action:@selector(checkAttachments:) forControlEvents:UIControlEventTouchUpInside];
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        attachmentsCheck.frame = CGRectMake(560, 7, 30, 30);
        UIButton* takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhoto setImage:[UIImage imageNamed:@"attachTakePhotoPad"] forState:UIControlStateNormal];
        takePhoto.frame = CGRectMake(480, 7, 30, 30);
        [takePhoto addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:takePhoto];
        
        selectPhoto.frame = CGRectMake(400, 7, 30, 30);
        recorder.frame = CGRectMake(320, 7, 30, 30);
        timerView.frame = CGRectMake(220, 7, 80, 30);
    }
    else
    {
        attachmentsCheck.frame = CGRectMake(560, 7, 30, 30);
        selectPhoto.frame = CGRectMake(480, 7, 30, 30);
        recorder.frame = CGRectMake(400, 7, 30, 30);
        timerView.frame = CGRectMake(300, 7, 80, 30);
    }
    self.navigationItem.titleView = titleView;
    [titleView release];
}
- (void) buildView
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    backgroudScrollView = [[UIScrollView alloc] init];
    [self.view addSubview:backgroudScrollView];
    backgroudScrollView.delegate = self;
    [self setBackgroudScrollViewFrame:self.interfaceOrientation];
    [self buildInputView];
    [self buildNavigationItems];
    [self buildNavigtionTitleView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [bodyInputTextView becomeFirstResponder];
    if (nil == self.docEdit) {
        WizDocument* doc = [[WizDocument alloc] init];
        self.docEdit = doc;
        [doc release];
    }
    else {
        titleInputTextField.text = docEdit.title;
        folderTextField.text = self.docEdit.location;
        tagTextField.text = [self.docEdit tagDisplayString];
    }
}
- (void) viewDidLoad
{
    [super viewDidLoad];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setBackgroudScrollViewFrame:toInterfaceOrientation];
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        bodyInputTextView.frame = bodyInputTextViewFrame;
    }
    else
    {
        bodyInputTextView.frame = bodyInputTextViewPotraitFrame;
    }
    bodyInputViewHeigth = bodyInputTextView.frame.size.height;
}
// scroll delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect frame = bodyInputTextView.frame;
    bodyInputTextView.frame = CGRectMake(0.0, 135, frame.size.width, bodyInputViewHeigth+offset.y);
}
// textFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == folderTextField) {
        [self folderViewSelected:nil];
    }
    else if (textField == tagTextField)
    {
        [self tagViewSelected];
    }
    [textField resignFirstResponder];
}
@end
