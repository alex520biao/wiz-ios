//
//  WizPadEditNoteController.m
//  Wiz
//
//  Created by wiz on 12-2-2.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadEditNoteController.h"
#import "WizGlobals.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "SelectFloderView.h"
#import "WizSelectTagViewController.h"
#import "WizPadNotificationMessage.h"
#import "WizDictionaryMessage.h"
#import "UIBadgeView.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "WizPadCheckAttachments.h"
#import "WizNotification.h"

#define titleInputTextFieldFrame CGRectMake(0.0,0.0,768,44)
#define folderLabelFrame CGRectMake(0.0, 45, 768, 44)
#define tagLabelFrame CGRectMake(0.0, 90, 768, 44)
#define bodyInputTextViewFrame CGRectMake(0.0, 135, 768, 592)
#define bodyInputTextViewPotraitFrame CGRectMake(0.0, 135, 768, 845)
#define backgroudScrollViewLandscapeFrame CGRectMake(0.0,0.0,1024,768)
#define backgroudScrollViewPotraitFrame CGRectMake(0.0,0.0,768,1024)


@implementation WizPadEditNoteController
@synthesize bodyInputTextView;
@synthesize titleInputTextField;
@synthesize tagTextField;
@synthesize folderTextField;
@synthesize backgroudScrollView;
@synthesize bodyInputViewHeigth;
@synthesize currentPopoverController;
@synthesize documentFloder;
@synthesize selectedTags;
@synthesize documentGUID;
@synthesize timerView;
@synthesize attachmentsCountView;
@synthesize isNewDocument;
- (void) dealloc
{
    self.timerView = nil;
    self.documentGUID = nil;
    self.selectedTags = nil;
    self.documentFloder = nil;
    self.currentPopoverController = nil;
    self.bodyInputTextView = nil;
    self.titleInputTextField = nil;
    self.tagTextField = nil;
    self.folderTextField = nil;
    self.backgroudScrollView = nil;
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
- (void) displayAttachmentsCount
{
    self.attachmentsCountView.badgeString = [NSString stringWithFormat:@"%d",[self.attachmentSourcePath count]];
}
- (void)didReceiveMemoryWarning
{

    [super didReceiveMemoryWarning];

}
- (CGFloat) stringDisplayLength:(NSString*)string :(CGFloat)fontSize
{
    CGSize boundingSize = CGSizeMake(320.0f, CGFLOAT_MAX);
    CGSize requiredSize = [string sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:boundingSize
                                        lineBreakMode:UILineBreakModeWordWrap];
    CGFloat requiredHeight = requiredSize.height;
    return requiredHeight;
}

- (void) addDisplayTagName:(NSString*)tagName
{
    UIFont* font = [UIFont systemFontOfSize:25];
    UIBadgeView* tagLabel = [[UIBadgeView alloc] initWithFrame:CGRectMake(self.tagTextField.leftView.frame.size.width+10, 0.0, [tagName sizeWithFont:font].width+10, 44)];
    tagLabel.badgeString = tagName;
    [self.tagTextField.leftView addSubview:tagLabel];
    CGRect tagFrame = self.tagTextField.leftView.frame;
    self.tagTextField.leftView.frame = CGRectMake(tagFrame.origin.x, tagFrame.origin.y, tagFrame.size.width + [tagName sizeWithFont:font].width +10, 44);
    [self.tagTextField.leftView addSubview:tagLabel];
    [tagLabel release];
}

- (void) folderChanged:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* folder = [userInfo valueForKey:TypeOfFolderKey];
    self.documentFloder = [NSMutableString stringWithString:folder];
    self.folderTextField.text = [WizGlobals folderStringToLocal:folder];
}
- (void) folderViewSelected:(id)sender
{
    SelectFloderView*  floderView = [[SelectFloderView alloc] initWithStyle:UITableViewStyleGrouped];
    floderView.accountUserID = self.accountUserId;
    floderView.selectedFloderString = self.documentFloder;
    if (self.currentPopoverController != nil) {
        [self.currentPopoverController dismissPopoverAnimated:YES];
    }
    UINavigationController* folder = [[UINavigationController alloc] initWithRootViewController:floderView];
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:folder];
    [folder release];
    self.currentPopoverController = pop;
    [pop release];
    self.currentPopoverController.delegate = self;
    [self.currentPopoverController presentPopoverFromRect:CGRectMake(750, 0.0, 320, self.backgroudScrollView.contentOffset.y+132) inView:self.backgroudScrollView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(folderChanged:) name:TypeOfSelectedFolder object:nil];
    [floderView release];
}

- (NSString*) displayTagName:(NSString*)tagName
{
    return [NSString stringWithFormat:@"%@%@%@%@",@"\"",tagName,@"\"",@","];
}

- (void) addTagToDocument:(WizTag*)tag
{
    NSString* text = nil;
    if (nil == self.tagTextField.text) {
        text = @"";
    }
    else
    {
        text = self.tagTextField.text;
    }
//    [self addDisplayTagName:[tag name]];
    self.tagTextField.text = [text stringByAppendingFormat:@"%@",[self displayTagName:[tag name]]];;
}
- (void) addTag:(NSNotification*)nc
{
    NSDictionary* dic = [nc userInfo];
    WizTag* tag = [dic valueForKey:TypeOfTagKey];
    [self.selectedTags addObject:tag];
    [self addTagToDocument:tag];
}

- (NSUInteger) tagIndexAtSlectedArray:(WizTag*)tag
{
    for (int i = 0; i < [self.selectedTags count]; i++) {
        if ([[[self.selectedTags objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
            return i;
        }
    }
    return -1;
}

- (void) removeTag:(NSNotification*)nc
{
    NSDictionary* dic = [nc userInfo];
    WizTag* tag = [dic valueForKey:TypeOfTagKey];
    NSRange range = [self.tagTextField.text rangeOfString:[NSString stringWithFormat:@"%@",[self displayTagName:[tag name]]]] ;
    NSMutableString* text = [NSMutableString stringWithString:self.tagTextField.text];
    if (range.length + range.location > text.length) {
        return;
    }
    [self.selectedTags removeObjectAtIndex:[self tagIndexAtSlectedArray:tag]];
    [text deleteCharactersInRange:range];
    self.tagTextField.text = text;
}
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    if ([popoverController.contentViewController isKindOfClass:[WizSelectTagViewController class]]) {

        [nc removeObserver:self name:TypeOfUnSelectedTag object:nil];
        [nc removeObserver:self name:TypeOfSelectedTag object:nil];
    }
    if ([popoverController.contentViewController isKindOfClass:[SelectFloderView class]]) {
        [nc removeObserver:self name:TypeOfSelectedFolder object:nil];
    }
    if ([popoverController.contentViewController isKindOfClass:[ELCImagePickerController class]]) {

    }
    self.currentPopoverController = nil;
}
- (void) tagViewSelected
{
    WizSelectTagViewController* tagView = [[WizSelectTagViewController alloc]initWithStyle:UITableViewStyleGrouped];
    tagView.accountUserId = self.accountUserId;
    tagView.initSelectedTags = self.selectedTags;
    if (nil != self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:YES];
    }
    
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:tagView];
    self.currentPopoverController = pop;
    [pop release];
    self.currentPopoverController.delegate = self;
    [self.currentPopoverController presentPopoverFromRect:CGRectMake(750, 0.0, 320, self.backgroudScrollView.contentOffset.y+220) inView:self.backgroudScrollView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addTag:) name:TypeOfSelectedTag object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTag:) name:TypeOfUnSelectedTag object:nil];
    [tagView release];
}

- (void) setBackgroudScrollViewFrame:(UIInterfaceOrientation)interface
{
    if (UIInterfaceOrientationIsLandscape(interface)) {
        self.backgroudScrollView.frame = backgroudScrollViewLandscapeFrame;
        self.backgroudScrollView.contentSize = CGSizeMake(1024, 1024);
    }
    else
    {
        self.backgroudScrollView.frame = backgroudScrollViewPotraitFrame;
        self.backgroudScrollView.contentSize = CGSizeMake(768, 1324);
    }
}

- (void) buildInputView
{
    UIFont* font = [UIFont systemFontOfSize:17];
    
    UITextView* body = [[UITextView alloc] initWithFrame:bodyInputTextViewFrame];
    [self.backgroudScrollView addSubview:body];
    self.bodyInputTextView = body;
    body.font = font;
    [body setContentMode:UIViewContentModeBottom];
    [body release];
    
    UITextField* title = [[UITextField alloc] initWithFrame:titleInputTextFieldFrame];
    [self.backgroudScrollView addSubview:title];
    self.titleInputTextField = title;
    title.backgroundColor = [UIColor whiteColor];
    NSString* titleRemindText = [NSString stringWithFormat:@"%@:",WizStrTitle];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0.0, [titleRemindText sizeWithFont:font].width +10, 44)];
    titleLabel.text = titleRemindText;
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.font = font;
    title.leftView = titleLabel;
    titleLabel.textColor= [UIColor grayColor];
    [titleLabel release];
    title.leftViewMode = UITextFieldViewModeAlways;
    title.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [title release];
    
    UITextField* tag = [[UITextField alloc] initWithFrame:tagLabelFrame];
    tag.delegate = self;
    [self.backgroudScrollView addSubview:tag];
    self.tagTextField = tag;
    NSString* tagRemindText = [NSString stringWithFormat:@"%@:",WizStrTags];
    UILabel* tagLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, [tagRemindText sizeWithFont:font].width + 10, 44)];
    tag.leftViewMode = UITextFieldViewModeAlways;
    tag.leftView = tagLabel;
    tag.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tagLabel.font = font;
    tagLabel.textAlignment = UITextAlignmentCenter;
    tagLabel.text = tagRemindText;
    [tag setBackgroundColor:[UIColor whiteColor]];
    tagLabel.textColor = [UIColor grayColor];
    UIButton* tagButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [tagButton addTarget:self action:@selector(tagViewSelected) forControlEvents:UIControlEventTouchUpInside];
    tag.rightViewMode = UITextFieldViewModeAlways;
    tag.rightView = tagButton;
    [tag release];
    [tagLabel release];

    
    UITextField* folder = [[UITextField alloc] initWithFrame:folderLabelFrame];
    [self.backgroudScrollView addSubview:folder];
    folder.delegate = self;
    self.folderTextField = folder;
    NSString* folderRemindText = [NSString stringWithFormat:@"%@:",WizStrFolders];
    UILabel* folderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, [folderRemindText sizeWithFont:font].width+10, 44)];
    folder.leftView = folderLabel;
    folder.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    folder.leftViewMode = UITextFieldViewModeAlways;
    folderLabel.textColor = [UIColor grayColor];
    folderLabel.text = folderRemindText;
    folderLabel.font = font;
    folderLabel.textAlignment = UITextAlignmentCenter;
    folder.backgroundColor = [UIColor whiteColor];
    UIButton* folderButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [folderButton addTarget:self action:@selector(folderViewSelected:) forControlEvents:UIControlEventTouchUpInside];
    folder.rightView = folderButton;
    folder.rightViewMode = UITextFieldViewModeAlways;
    [folder release];
    [folderLabel release];

    
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.bodyInputTextView.frame = bodyInputTextViewFrame;
    }
    else
    {
        self.bodyInputTextView.frame = bodyInputTextViewPotraitFrame;
    }
    self.bodyInputViewHeigth = bodyInputTextView.frame.size.height;
    [self displayAttachmentsCount];
}
- (void) keyboardWillShow:(NSNotification*)nc
{
    BOOL selfViewIsFirstResponser = NO;
    for (UIView* each in  self.backgroudScrollView.subviews) {
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
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.bodyInputTextView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.bodyInputTextView.frame = CGRectMake(0.0, 135, 768, self.bodyInputTextView.frame.size.height-width+self.backgroudScrollView.contentOffset.y);
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.bodyInputViewHeigth = bodyInputTextViewFrame.size.height-width;
    }
    else
    {
        self.bodyInputViewHeigth = bodyInputTextViewPotraitFrame.size.height-width;
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
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.bodyInputTextView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    self.bodyInputTextView.frame = CGRectMake(0.0, 135, self.bodyInputTextView.frame.size.width, self.bodyInputTextView.frame.size.height+width);
    self.bodyInputViewHeigth = self.bodyInputTextView.frame.size.height;
    self.bodyInputViewHeigth = bodyInputTextView.frame.size.height;
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

- (void) cancelSave
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrAreyousureyouwanttoquit delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:WizStrQuitwithoutsaving otherButtonTitles:nil, nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    [actionSheet release];
}

- (void) saveDocument
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];

    NSString* tagGuids = [NSMutableString string];
    if ([self.selectedTags count]) {
        for (int i = 0; i <[self.selectedTags count]-1; i++) {
            WizTag* tag = [self.selectedTags objectAtIndex:i];
            tagGuids = [tagGuids stringByAppendingFormat:@"%@*",[tag guid]];
        }
        tagGuids = [tagGuids stringByAppendingFormat:@"%@",[[self.selectedTags lastObject] guid]];
    }
    NSMutableArray* attachmentsGuid = [NSMutableArray array];
    if ([self.attachmentSourcePath count]) {
        for (NSString* each in self.attachmentSourcePath) {
            NSArray* dir = [each componentsSeparatedByString:@"/"];
            NSString* pathDir = [dir objectAtIndex:[dir count] -2];
            if (![pathDir isEqualToString:ATTACHMENTTEMPFLITER]) {
                [attachmentsGuid addObject:pathDir];
                continue;
            }
            NSString* newAttachmentGuid = [[index newAttachment:each documentGUID:self.documentGUID] autorelease];
            [attachmentsGuid addObject:newAttachmentGuid];
        }
    }
    NSMutableDictionary* documentData = [NSMutableDictionary dictionary];

    if (nil == self.titleInputTextField.text) {
        self.titleInputTextField.text = @"";
    }
    
    if (nil == self.bodyInputTextView.text) {
        self.bodyInputTextView.text = @"";
    }
    [documentData setObject:self.documentGUID forKey:TypeOfDocumentGUID];
    [documentData setObject:self.documentFloder forKey:TypeOfDocumentLocation];
    [documentData setObject:self.bodyInputTextView.text forKey:TypeOfDocumentBody];
    [documentData setObject:attachmentsGuid forKey:TypeOfAttachmentGuids];
    [documentData setObject:self.titleInputTextField.text forKey:TypeOfDocumentTitle];
    [documentData setObject:tagGuids forKey:TypeOfDocumentTags];
    if (isNewDocument) {
        [index  newNoteWithGuidAndData:documentData];
        [WizNotificationCenter postNewDocumentMessage:self.documentGUID];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfEditDocumentDone object:nil userInfo:nil];
        [index editDocumentWithGuidAndData:documentData];
    }
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (float) updateTime
{
    float time = [super updateTime];
    for (UIView* each in self.timerView.subviews) {
        if ([each isKindOfClass:[UILabel class]]) {
            UILabel* timeLabel = (UILabel*)each;
            timeLabel.text = [WizIndex timerStringFromTimerInver:time];
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

- (void) addPhotoAttachment
{
    if (nil != self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:YES];
    }
    
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName:@"ELCAlbumPickerController" bundle:[NSBundle mainBundle]];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
	[elcPicker setDelegate:self];
    [albumController release];
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:elcPicker];
    self.currentPopoverController = pop;
    [pop release];
    [elcPicker release];
    self.currentPopoverController.delegate = self;
    [self.currentPopoverController presentPopoverFromRect:CGRectMake(428, 0.0, 180, 0.0) inView:self.backgroudScrollView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
    [self.currentPopoverController dismissPopoverAnimated:YES];
}
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
    for(NSDictionary* each in info)
    {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        UIImage* image = [each objectForKey:UIImagePickerControllerOriginalImage];
        image = [image compressedImage:[index imageQualityValue]];
        NSString* fileNamePath = [[WizGlobals getAttachmentSourceFileName:self.accountUserId] stringByAppendingString:@".jpg"];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileNamePath atomically:YES];
        [self.attachmentSourcePath addObject:fileNamePath];
        self.attachmentsCountView.badgeString = [NSString stringWithFormat:@"%d",[self.attachmentSourcePath count]];
    }
    [self elcImagePickerControllerDidCancel:picker];
}
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [image compressedImage:[index imageQualityValue]];
    NSString* fileNamePath = [[WizGlobals getAttachmentSourceFileName:self.accountUserId] stringByAppendingString:@".jpg"];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:fileNamePath atomically:YES];
    [picker dismissModalViewControllerAnimated:YES];
    //2012-2-26 delete
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
    [self.attachmentSourcePath addObject:fileNamePath];
    self.attachmentsCountView.badgeString = [NSString stringWithFormat:@"%d",[self.attachmentSourcePath count]];
}
- (void) addNewPhotoAttachment
{
    UIImagePickerController* newPhoto = [self takePhotoViewSelcevted];
    [self presentModalViewController:newPhoto animated:YES];
}
- (void) log
{
    NSLog(@"ddddd");
}
- (void) stopRecorder:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"attachRecorderPad"] forState:UIControlStateNormal];
    [btn removeTarget:self action:@selector(stopRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.timerView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    self.timerView.alpha = 0.0;
    for (UIView* each in self.timerView.subviews) {
        if ([each isKindOfClass:[UILabel class]]) {
            UILabel* timeLabel =(UILabel*)each;
            [timeLabel setText:@"00:00"];
        }
    }
    [UIView commitAnimations];
    [self audioStopRecord];
    self.attachmentsCountView.badgeString = [NSString stringWithFormat:@"%d",[self.attachmentSourcePath count]];
}
- (void) startRecorder:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"stopRecorder"] forState:UIControlStateNormal];
    [btn removeTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [btn addTarget:self action:@selector(stopRecorder:) forControlEvents:UIControlEventTouchUpInside];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.timerView cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    self.timerView.alpha = 1.0;
    [UIView commitAnimations];
    [self audioStartRecode];
}

- (void) checkAttachments:(id)sender
{
    if (nil != self.currentPopoverController) {
        [self.currentPopoverController dismissPopoverAnimated:YES];
    }
    WizPadCheckAttachments* checkAttachments = [[WizPadCheckAttachments alloc] init];
    checkAttachments.source = self.attachmentSourcePath;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:checkAttachments];
    [checkAttachments release];
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    self.currentPopoverController = pop;
    [pop release];
    self.currentPopoverController.delegate = self; 
    [self.currentPopoverController presentPopoverFromRect:CGRectMake(630, 0.0, 0.1, 10) inView:self.backgroudScrollView permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void) buildNavigtionTitleView
{
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 678, 44)];
    
    UIButton* recorder = [UIButton buttonWithType:UIButtonTypeCustom];
    [recorder setImage:[UIImage imageNamed:@"attachRecorderPad"] forState:UIControlStateNormal];
    recorder.frame = CGRectMake(390, 7, 30, 30);
    [recorder addTarget:self action:@selector(startRecorder:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:recorder];
    
    UIImageView* recorderBack = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorderTimeBack"]];
    recorderBack.frame = CGRectMake(300, 7, 80, 30);
    UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 80, 30)];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = @"00:00";
    [recorderBack addSubview:timeLabel];
    timeLabel.textAlignment = UITextAlignmentCenter;
    [timeLabel release];
    self.timerView = recorderBack;
    recorderBack.alpha = 0.0;
    [titleView addSubview:recorderBack];
    [recorderBack release];
    
    UIButton* selectPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectPhoto setImage:[UIImage imageNamed:@"attachSelectPhotoPad"] forState:UIControlStateNormal];
    selectPhoto.frame = CGRectMake(470, 7, 30, 30);
    [selectPhoto addTarget:self action:@selector(addPhotoAttachment) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:selectPhoto];
    
    UIButton* attachmentsCheck = [UIButton buttonWithType:UIButtonTypeCustom];
    [attachmentsCheck setImage:[UIImage imageNamed:@"newNoteAttachG"] forState:UIControlStateNormal];
    [titleView addSubview:attachmentsCheck];
    UIBadgeView* attachmentsCount = [[UIBadgeView alloc] initWithFrame:CGRectMake(25, -5, 20, 20)];
    attachmentsCount.badgeString = [NSString stringWithFormat:@"%d",[self.attachmentSourcePath count]];
    [attachmentsCheck addSubview:attachmentsCount];
    [attachmentsCheck addTarget:self action:@selector(checkAttachments:) forControlEvents:UIControlEventTouchUpInside];
    self.attachmentsCountView = attachmentsCount;
    [attachmentsCount release];
    
    if ( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        attachmentsCheck.frame = CGRectMake(560, 7, 30, 30);
        UIButton* takePhoto = [UIButton buttonWithType:UIButtonTypeCustom];
        [takePhoto setImage:[UIImage imageNamed:@"attachTakePhotoPad"] forState:UIControlStateNormal];
        takePhoto.frame = CGRectMake(480, 7, 30, 30);
        [takePhoto addTarget:self action:@selector(addNewPhotoAttachment) forControlEvents:UIControlEventTouchUpInside];
        [titleView addSubview:takePhoto];
        
        selectPhoto.frame = CGRectMake(400, 7, 30, 30);
        recorder.frame = CGRectMake(320, 7, 30, 30);
        recorderBack.frame = CGRectMake(220, 7, 80, 30);
    }
    else
    {
        attachmentsCheck.frame = CGRectMake(560, 7, 30, 30);
        selectPhoto.frame = CGRectMake(480, 7, 30, 30);
        recorder.frame = CGRectMake(400, 7, 30, 30);
        recorderBack.frame = CGRectMake(300, 7, 80, 30);
    }
    self.navigationItem.titleView = titleView;
    [titleView release];
}
- (void) buildView
{
    self.view.backgroundColor = [UIColor lightGrayColor];
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    self.backgroudScrollView = scrollView;
    self.backgroudScrollView.delegate = self;
    if (nil == self.attachmentSourcePath) {
        self.attachmentSourcePath = [NSMutableArray array];
    }
    [scrollView release];
    [self setBackgroudScrollViewFrame:self.interfaceOrientation];
    [self buildInputView];
    [self buildNavigationItems];
    [self buildNavigtionTitleView];
}
//- (BOOL) checkIsAttachmen:(NSString*)name
//{
//    
//}
- (void) prepareEditingData:(NSDictionary*)data
{
    [self buildView];
    self.isNewDocument = NO;
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* document = [index documentFromGUID:self.documentGUID];
    NSString* documentTitle = [data valueForKey:TypeOfDocumentTitle];
    NSString* documentBody = [data valueForKey:TypeOfDocumentBody];
    self.titleInputTextField.text = documentTitle;
    self.bodyInputTextView.text = documentBody;
    self.selectedTags = [NSMutableArray arrayWithArray:[index tagsByDocumentGuid:self.documentGUID]];
    self.documentFloder = [NSMutableString stringWithString:document.location];
    for (WizTag* each in self.selectedTags) {
        if (nil == each) {
            continue;
        }
        [self addTagToDocument:each];
    }
    
//    NSString* documentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:documentGUID];
//    NSString* indexFiles = [documentPath stringByAppendingPathComponent:@"index_files"];
//    NSArray* attachmentsFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:indexFiles error:nil];
//    for (NSString* eachFile in attachmentsFiles) {
//        NSArray* sepre = [eachFile componentsSeparatedByString:@"."];
//        if ([self checkIsAttachmen:[sepre objectAtIndex:0]]) {
//            
//        }
//    }
    NSArray* attachments = [index attachmentsByDocumentGUID:self.documentGUID];
    for (WizDocumentAttach* eachAttach in attachments) {
        NSString* filePath = [[WizIndex documentFilePath:self.accountUserId documentGUID:eachAttach.attachmentGuid] stringByAppendingPathComponent:eachAttach.attachmentName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            [self.attachmentSourcePath addObject:filePath];
        }

    }
    self.folderTextField.text = [WizGlobals folderStringToLocal:self.documentFloder];
}
- (void) prepareNewDocumentData:(NSDictionary*)data
{
    [self buildView];
    self.isNewDocument = YES;
    self.documentGUID = [WizGlobals genGUID];
    if (nil == self.selectedTags ) {
        self.selectedTags = [NSMutableArray array];
    }
    if (nil == self.documentFloder) {
        self.documentFloder = [NSMutableString string];
    }
    
    NSString* tagGuid = [data valueForKey:TypeOfSelectedTag];
    if (nil != tagGuid) {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        WizTag* tag = [index tagFromGuid:tagGuid];
        [self.selectedTags addObject:tag];
        [self addTagToDocument:tag];
    }
    NSString* documentFolderString = [data valueForKey:TypeOfSelectedFolder];
    if (nil != documentFolderString && ![documentFolderString isEqualToString:@""]) {
        self.documentFloder = [NSMutableString stringWithString:documentFolderString];
        self.folderTextField.text = [WizGlobals folderStringToLocal:self.documentFloder];
    }
}

- (void) deleteAttachments:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* attachmentFilePath = [userInfo valueForKey:TypeOfAttachmentFilePath];
    NSArray* dir = [attachmentFilePath componentsSeparatedByString:@"/"];
    NSString* cDir = [dir objectAtIndex:[dir count]-2];
    NSString* fileName = [dir lastObject];
    if (![cDir isEqualToString:ATTACHMENTTEMPFLITER]) {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        NSString* documentFilePath = [WizIndex documentFilePath:self.accountUserId documentGUID:self.documentGUID];
        NSString* filesPath = [documentFilePath stringByAppendingPathComponent:@"index_files"];
        NSString* filePath = [filesPath stringByAppendingPathComponent:fileName];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError* error = [[NSError alloc]init];
        if(![fileManager removeItemAtPath:filePath error:&error])
        {
            NSLog(@"remove error");
        }
        [error release];
        WizDocumentAttach* attach = [index attachmentFromGUID:cDir];
        [index deleteAttachment:attach.attachmentGuid];
    }
    [self displayAttachmentsCount];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.bodyInputTextView becomeFirstResponder];
}
- (void) viewDidLoad      
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAttachments:) name:MessageOfDeleteAttachments object:nil];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        self.bodyInputTextView.frame = bodyInputTextViewFrame;
    }
    else
    {
        self.bodyInputTextView.frame = bodyInputTextViewPotraitFrame;
    }
    self.bodyInputViewHeigth = bodyInputTextView.frame.size.height;

}
// scroll delegate
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGRect frame = self.bodyInputTextView.frame;
    self.bodyInputTextView.frame = CGRectMake(0.0, 135, frame.size.width, self.bodyInputViewHeigth+offset.y);
    
}
// textFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.folderTextField || textField == self.tagTextField) {
        [textField resignFirstResponder];
    }
    
}
@end
