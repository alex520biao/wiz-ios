//
//  NewNoteView.m
//  Wiz
//
//  Created by dong zhao on 11-11-16.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>

#import "NewNoteView.h"
#import "UIView-TagExtensions.h"
#import "SelectFloderView.h"
#import "VoiceRecognition.h"
#import "WizDictionaryMessage.h"
#import "WizPhoneNotificationMessage.h"
#import "WizPadCheckAttachments.h"
#import "WizPadNotificationMessage.h"
#import "WizSelectTagViewController.h"
#import "WizEditItemBackgroudView.h"
#import "WizNotification.h"
#define KEYHIDDEN               209
#define HIDDENTTAG              300
#define NOHIDDENTTAG            301
#define INFOVIEWHEIGN           68
#define ATTACHMENTSVIEWHEIGH    105

#define AudioRecoderStartTag    1200
#define AudioRecoderStopTag     1201
@interface NewNoteView()
{
    //audio
    UILabel* recoderLabel;
    UITextField* titleTextFiled;
    UITextView* bodyTextField;
    UILabel* attachmentsCountLabel;
    BOOL            isNewDocument;
    UIButton* attachmentsTableviewEntryButton;
    UIView* addAttachmentView;
    UIView* addDocumentInfoView;
    UIView* inputContentView;
    UIImageView* keyControl;
    VoiceRecognition* voiceInput;
    id firtResponser;
}
@property (nonatomic, retain) UILabel*          recoderLabel;
@property (nonatomic, retain) UITextField*      titleTextFiled;
@property (nonatomic, retain) UITextView*       bodyTextField;
@property (nonatomic, retain) UILabel*          attachmentsCountLabel;
@property (nonatomic, retain) UIImageView*      keyControl;
@property (nonatomic, retain) UIView*           addAttachmentView;
@property (nonatomic, retain) UIView*           addDocumentInfoView;
@property (nonatomic, retain) UIView*           inputContentView;
@property (nonatomic, retain) UIButton*         attachmentsTableviewEntryButton;
@property (nonatomic, retain) VoiceRecognition* voiceInput;
@property (nonatomic, retain) id                firtResponser;
@property  BOOL                                 isNewDocument;
- (void) addDocumentInfoViewAnimation;
- (void) addAttachmentsViewAnimation;
- (void) startVoiceInput;
- (void) voiceInputOver:(NSString*)result;
@end


@implementation NewNoteView
@synthesize recoderLabel;
@synthesize titleTextFiled;
@synthesize bodyTextField;
@synthesize attachmentsCountLabel;
@synthesize isNewDocument;
@synthesize keyControl;
@synthesize addAttachmentView;
@synthesize addDocumentInfoView;
@synthesize inputContentView;
@synthesize attachmentsTableviewEntryButton;
@synthesize firtResponser;
@synthesize voiceInput;
-(void) dealloc
{
    [firtResponser release];
    [titleTextFiled release];
    [bodyTextField release];
    [attachmentsCountLabel release];
    [recoderLabel release];
    [voiceInput release];
    [keyControl release];
    [addDocumentInfoView release];
    [addAttachmentView release];
    [inputContentView release];
    [attachmentsTableviewEntryButton release];
    [super dealloc];
}
- (void) attachmentAddDone
{
    NSInteger count = [self.picturesArray count] + [self.audiosArray count];
    NSString* displayString = [NSString stringWithFormat:@"%@: %d",NSLocalizedString(@"Attachments", nil), count];
    [self.attachmentsTableviewEntryButton setTitle:displayString forState:UIControlStateNormal];
}
- (void) startRecoder
{
    UIView* first = (UIView*)[self.view viewWithTag:AudioRecoderStartTag];
    UIView* second = (UIView*) [self.view viewWithTag:AudioRecoderStopTag];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:second cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [first setAlpha:0.0f];
    [second setAlpha:1.0f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(audioStartRecode)];
    [self.view exchangeSubviewAtIndex:[[self.view subviews] indexOfObject:first]
                   withSubviewAtIndex:[[self.view subviews] indexOfObject:second] ];
    [UIView commitAnimations];
}

-(void) stopRecord
{
    UIView* first = (UIView*)[self.view viewWithTag:AudioRecoderStopTag];
    UIView* second = (UIView*) [self.view viewWithTag:AudioRecoderStartTag];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:second cache:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:1.0];
    [first setAlpha:0.0f];
    [second setAlpha:1.0f];
    [self.view exchangeSubviewAtIndex:[[self.view subviews] indexOfObject:first]
                   withSubviewAtIndex:[[self.view subviews] indexOfObject:second] ];
    [UIView commitAnimations];
    [self audioStopRecord];
}
-(UIImage*) imageReduceRect:(NSString*) imageName
{
    UIImage* image = [UIImage imageNamed:imageName];
    return image;
}

-(void) keyHideOrShow
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [self.keyControl layer].transform = CATransform3DMakeRotation(M_PI * 2, 0, 0, 1);
    [self.bodyTextField setFrame:CGRectMake(0.0, 31, self.view.frame.size.width, self.view.frame.size.height-30)];
    [self.keyControl setFrame:CGRectMake( 250, self.view.frame.size.height - 35, 50, 25)];
    [self.voiceInput setFrame:CGRectMake( 250, self.view.frame.size.height - 35, 50, 25)];
    self.voiceInput.hidden = YES;
    self.keyControl.hidden = YES;
    [UIView commitAnimations];
    [self.titleTextFiled resignFirstResponder];
    [self.bodyTextField resignFirstResponder];
}

-(void) attachmentsViewSelect
{
    WizPadCheckAttachments* checkAttachments = [[WizPadCheckAttachments alloc] init];
    [self.navigationController pushViewController:checkAttachments animated:YES];
    [checkAttachments release];
}
-(void) addSelcetorToView:(SEL)sel :(UIView*)view
{
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:sel] autorelease];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired =1;
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
}

 -(void) addAudioRecorderStopView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(10, 11, 100, 48)];
    temp.tag = AudioRecoderStopTag;
    UIImageView* back = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"recorderTimeBack"]];
    back.frame = CGRectMake(10, 5, 80, 24);
    [temp addSubview:back];
    [back release];
    UILabel* stopLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 26, 100, 24)];
    stopLabel.backgroundColor = [UIColor clearColor];
    [stopLabel setFont:[UIFont systemFontOfSize:13]];
    [stopLabel setTextColor:[UIColor grayColor]];
    stopLabel.textAlignment = UITextAlignmentCenter;
    stopLabel.text = NSLocalizedString(@"Tap to stop", nil);
    [temp addSubview:stopLabel];
    UILabel* recoderL = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 80, 24)] ;
    self.recoderLabel = recoderL;
    [temp addSubview:self.recoderLabel];
    recoderL.font = [UIFont systemFontOfSize:15];
    recoderL.textAlignment = UITextAlignmentCenter;
    self.recoderLabel.backgroundColor = [UIColor clearColor];
    [recoderL release];
    [self.addAttachmentView addSubview:temp];
    [temp setTargetAndSelector:self selector:@selector(stopRecord)];
    [temp setAlpha:0.0f];
    [stopLabel release];
    [temp release];
}

- (void) addAudioRecorderStartView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(10, 11, 100, 48)];
    UIImage* image = [UIImage imageNamed:@"attachRecorderPad"];
    temp.imageView.image = image;
    temp.label.text = NSLocalizedString(@"Record", nil);
    [self.addAttachmentView addSubview:temp];
    [temp setTargetAndSelector:self selector:@selector(startRecoder)];
    temp.tag = AudioRecoderStartTag;
    [temp release];
}
- (void) addSelectedPhotoView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(110, 11, 100, 48)];
    UIImage* image = [UIImage imageNamed:@"attachSelectPhotoPad"];
    temp.imageView.image = image;
    temp.label.text = NSLocalizedString(@"Camera roll", nil);
    [self.addAttachmentView addSubview:temp];
    [temp setTargetAndSelector:self selector:@selector(selectePhotos)];
    [temp release];
}
- (void) addTakePhotoView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(210, 11, 100, 48)];
    UIImage* image = [UIImage imageNamed:@"attachTakePhotoPad"];
    temp.imageView.image = image;
    temp.label.text = NSLocalizedString(@"Snapshot", nil);
    [self.addAttachmentView addSubview:temp];
    [temp setTargetAndSelector:self selector:@selector(takePhoto)];
    [temp release];
}
- (void) buildAddAttachmentsView
{
    if (nil == self.addAttachmentView) {
        UIView* addAttach = [[UIView alloc] initWithFrame:CGRectMake(0.0, -ATTACHMENTSVIEWHEIGH, 320, 100)];
        self.addAttachmentView = addAttach;
        [addAttach release];
        self.addAttachmentView.tag = HIDDENTTAG;
        self.addAttachmentView.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0];
    }
    [self addAudioRecorderStopView];
    [self addAudioRecorderStartView];
    // photo
    [self addSelectedPhotoView];
    //takephoto
    [self addTakePhotoView];
    // attachments entry
    UIButton* attachmentsTableEntry = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 300)/2, 74, self.view.frame.size.width - 20, 20)];
    CAGradientLayer* gradient = [CAGradientLayer layer];
    gradient.borderColor = [UIColor colorWithRed:159/256.0 green:159/256.0 blue:159/256.0 alpha:1.0].CGColor;
    gradient.borderWidth = 0.5f;
    gradient.shadowColor = [UIColor whiteColor].CGColor;
    gradient.shadowOffset = CGSizeMake(1, 0.5);
    gradient.shadowOpacity = 0.5;
    gradient.shadowRadius = 0.5;
    gradient.frame = CGRectMake(0.0, 0.0, attachmentsTableEntry.frame.size.width,  20);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor colorWithRed:241/256.0 green:241/256.0 blue:241/256.0 alpha:1.0].CGColor,
                       (id)[UIColor colorWithRed:207/256.0 green:207/256.0 blue:207/256.0 alpha:1.0].CGColor,
                       
                       nil];
    
    gradient.cornerRadius = 2;
    gradient.masksToBounds = YES;
    
    [attachmentsTableEntry.layer insertSublayer:gradient atIndex:0];
    self.attachmentsTableviewEntryButton = attachmentsTableEntry;
    [self.attachmentsTableviewEntryButton setTitle:@"ddd" forState:UIControlStateNormal];
    [self.attachmentsTableviewEntryButton addTarget:self action:@selector(attachmentsViewSelect) forControlEvents:UIControlEventTouchUpInside];
    attachmentsTableEntry.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    attachmentsTableEntry.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    attachmentsTableEntry.titleLabel.font = [UIFont systemFontOfSize:13];
    attachmentsTableEntry.titleLabel.textColor = [UIColor grayColor];
    [self.addAttachmentView addSubview:self.attachmentsTableviewEntryButton];
    [self.view addSubview:self.addAttachmentView];
    [attachmentsTableEntry release];
}

- (void) addAttachemntsViewDisappear
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.addAttachmentView cache:YES];
    [UIView setAnimationDuration:0.4];
    self.addAttachmentView.frame = CGRectMake(0.0, -ATTACHMENTSVIEWHEIGH, self.view.frame.size.width, ATTACHMENTSVIEWHEIGH);
    self.inputContentView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 400);
    self.addAttachmentView.tag = HIDDENTTAG;
    [UIView commitAnimations];
}

- (void) addAttachmentsViewAppear
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.addAttachmentView cache:YES];
    [UIView setAnimationDuration:0.4];
    if (HIDDENTTAG != self.addDocumentInfoView.tag) {
        self.addDocumentInfoView.frame = CGRectMake(0.0, -INFOVIEWHEIGN, self.view.frame.size.width, INFOVIEWHEIGN);
        self.addDocumentInfoView.tag = HIDDENTTAG;
    }
    self.addAttachmentView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, ATTACHMENTSVIEWHEIGH);
    self.inputContentView.frame = CGRectMake(0.0, ATTACHMENTSVIEWHEIGH, self.view.frame.size.width, self.view.frame.size.height - ATTACHMENTSVIEWHEIGH);
    [self.view bringSubviewToFront:addAttachmentView];
    [self keyHideOrShow];
    self.addAttachmentView.tag = NOHIDDENTTAG;
    [UIView commitAnimations];
}

- (void) addAttachmentsViewAnimation
{
    if (HIDDENTTAG == self.addAttachmentView.tag) {
        [self addAttachmentsViewAppear ];
    }
    else
    {
        [self addAttachemntsViewDisappear];
    }
}


- (void) addDocumentInfoDisappear
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.addAttachmentView cache:YES];
    [UIView setAnimationDuration:0.4];
    self.addDocumentInfoView.frame = CGRectMake(0.0, -INFOVIEWHEIGN, self.view.frame.size.width, INFOVIEWHEIGN-10);
    self.inputContentView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 400);
    self.addDocumentInfoView.tag = HIDDENTTAG;
    [UIView commitAnimations];
}

- (void) addDocumentInfoAppear
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.addAttachmentView cache:YES];
    [UIView setAnimationDuration:0.4];
    if (HIDDENTTAG != self.addAttachmentView.tag) {
        self.addAttachmentView.frame = CGRectMake(0.0, -ATTACHMENTSVIEWHEIGH, self.view.frame.size.width, ATTACHMENTSVIEWHEIGH);
        self.addAttachmentView.tag = HIDDENTTAG;
    }
    self.addDocumentInfoView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, INFOVIEWHEIGN);
    self.inputContentView.frame = CGRectMake(0.0, INFOVIEWHEIGN, self.view.frame.size.width, 250);
    [self.view bringSubviewToFront:addDocumentInfoView];
    [self keyHideOrShow];
    self.addDocumentInfoView.tag = NOHIDDENTTAG;
    [UIView commitAnimations];
    
    
}

- (void) addDocumentInfoViewAnimation
{
    if (HIDDENTTAG == self.addDocumentInfoView.tag) {
        [self addDocumentInfoAppear];
    }
    else
    {
        [self addDocumentInfoDisappear];
    }
}
- (NSArray*) selectedTagsOld
{
    return [self.docEdit tagDatas];
}
- (void) willSelecteTags
{
    WizSelectTagViewController* sTag = [[WizSelectTagViewController alloc] init];
    sTag.selectDelegate = self;
    [self.navigationController pushViewController:sTag animated:YES];
    [sTag release];
}
- (void) didSelectedTags:(NSArray*)tags
{
    NSMutableString* tagsGuid = [NSMutableString stringWithCapacity:0];
    for (WizTag* tag in tags) {
        [tagsGuid appendFormat:@"%@*",tag.guid];
    }
    if (tagsGuid.length >0) {
        tagsGuid = [NSMutableString stringWithString:[tagsGuid substringToIndex:tagsGuid.length -1]];
    }
    self.docEdit.tagGuids = tagsGuid;
}
- (NSString*) selectedFolderOld
{
    return self.docEdit.location;
}

- (void) didSelectedFolderString:(NSString *)folderString
{
    self.docEdit.location = folderString;
}
- (void) willSelectedFolder
{
    SelectFloderView* sFolder = [[SelectFloderView alloc] init];
    sFolder.selectDelegate = self;
    [self.navigationController pushViewController:sFolder animated:YES];
    [sFolder release];
}
- (void) addFolderSelecteView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(110, 11, 100, 48)];
    UIImage* image = [UIImage imageNamed:@"newNoteFolder"];
    temp.imageView.image = image;
    temp.label.text = WizStrFolders;
    [temp setTargetAndSelector:self selector:@selector(willSelectedFolder)];
    [self.addDocumentInfoView addSubview:temp];
    [temp release];
}
- (void) addTagSelecteView
{
    WizEditItemBackgroudView* temp = [[WizEditItemBackgroudView alloc] initWithFrame:CGRectMake(210, 11, 100, 48)];
    UIImage* image = [UIImage imageNamed:@"newNoteTag"];
    temp.imageView.image = image;
    temp.label.text = WizStrTags;
    [temp setTargetAndSelector:self selector:@selector(willSelecteTags)];
    [self.addDocumentInfoView addSubview:temp];
    [temp release];
}

- (void) fitAttachmentItemFrame
{
    float start = (self.view.frame.size.width-300)/2;
    float stepStart = start;
    for (UIView* each in self.addAttachmentView.subviews) {
        if ([each isKindOfClass:[WizEditItemBackgroudView class]]) {
            if (each.tag == AudioRecoderStartTag || each.tag == AudioRecoderStopTag) {
                each.frame = CGRectMake(start, 11, 100, 40);
                continue;
            }
            stepStart+=100;
            each.frame = CGRectMake(stepStart, 11, 100, 40);
        }
    }
}

- (void) fitInfoItemFrame
{
    float start = (self.view.frame.size.width-200)/2;
    for (UIView* each in self.addDocumentInfoView.subviews) {
        if ([each isKindOfClass:[WizEditItemBackgroudView class]]) {
            each.frame = CGRectMake(start, 11, 100, 40);
            start+=100;
        }
    }
}
- (void) buildAddDocumentInfoView
{
    if (nil == self.addDocumentInfoView) {
        self.addDocumentInfoView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, -INFOVIEWHEIGN, 320, INFOVIEWHEIGN)] autorelease];
        self.addDocumentInfoView.tag = HIDDENTTAG;
        self.addDocumentInfoView.backgroundColor = [UIColor colorWithRed:215.0/255 green:215.0/255 blue:215.0/255 alpha:1.0];
        [self.view addSubview:self.addDocumentInfoView];
    }
    [self addFolderSelecteView];
    [self addTagSelecteView];
    
}
- (void) buildNavigationButtons
{
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(self.navigationItem.titleView.frame.size.width/2 - 40, 0, 90, 30)];
	UIButton *btnNormal = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnNormal setImage:[UIImage imageNamed:@"newNoteAttach"] forState:UIControlStateNormal];
	[btnNormal setFrame:CGRectMake(0, 0, 40, 30)];
	[btnNormal addTarget:self action:@selector(addAttachmentsViewAnimation) forControlEvents:UIControlEventTouchUpInside];
	[btnNormal setTitle:@"Normal" forState:UIControlStateNormal];
	[titleView addSubview:btnNormal];
	//Create Builtin type UIButton
	UIButton *btnBuiltinType = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[btnBuiltinType setFrame:CGRectMake(45, 0, 40, 30)];
	[btnBuiltinType addTarget:self action:@selector(addDocumentInfoViewAnimation) forControlEvents:UIControlEventTouchUpInside];
	[titleView addSubview:btnBuiltinType];
	//Set to titleView
	self.navigationItem.titleView = titleView;
	[titleView release];
}

- (void) setUserInterfaceEnableSelf:(BOOL)enable
{
    for (UIView* each in [self.navigationItem.titleView subviews]) {
        if ([each isKindOfClass:[UIButton class]]) {
            each = (UIButton*)each;
            each.userInteractionEnabled = enable;
        }
    }
    self.navigationItem.leftBarButtonItem.enabled = enable;
    self.navigationItem.rightBarButtonItem.enabled = enable;
    self.titleTextFiled.enabled = enable;
    self.bodyTextField.userInteractionEnabled = enable;
    self.keyControl.userInteractionEnabled = enable;
}

- (void) buildInputContentView
{
    if (nil == self.inputContentView) {
        self.inputContentView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 400)] autorelease];
        self.inputContentView.backgroundColor = [UIColor whiteColor];
    }
    //titile input
    self.titleTextFiled = [[[UITextField alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 30)] autorelease];
    self.titleTextFiled.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.titleTextFiled.placeholder = NSLocalizedString(@"Untitled", nil);
    self.titleTextFiled.delegate = self;
    [self.inputContentView addSubview:self.titleTextFiled];
    //body text input
    UIView* breakLine = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 30, 480, 1)] autorelease];
    breakLine.backgroundColor = [UIColor lightGrayColor];
    [self.inputContentView addSubview:breakLine];
    UITextView* edit = [[UITextView alloc] initWithFrame:CGRectMake(0.0, 31, 320, self.view.frame.size.height - 31)];
	edit.returnKeyType = UIReturnKeyDefault;
	[self.inputContentView addSubview:edit];
    edit.font = [UIFont systemFontOfSize:17];
	self.bodyTextField = edit;
    self.bodyTextField.delegate = self;
	[edit release];
    [self.view addSubview:self.inputContentView];
}

- (float) updateTime
{
    float time = [super updateTime];
    self.recoderLabel.text = [WizGlobals timerStringFromTimerInver:time];
    return time;
}
- (NSString*) insertStringToOldWithRange:(NSString*)oldString inserString:(NSString*) insertString range:(NSRange)selectedRange
{
    NSString* newBody = nil;
    if (insertString == nil) {
        insertString= @"";
    }
    NSUInteger location = selectedRange.location;
    NSUInteger selectedLength = selectedRange.length;
    NSRange preRange = NSMakeRange(0, location);
    if (selectedLength == 0) {
        if (location > 0) {
            NSRange nextRange = NSMakeRange(location, oldString.length - location);
            NSString* preStr = [oldString substringWithRange:preRange];
            NSString* nextStr = [oldString substringWithRange:nextRange];
            newBody = [NSString stringWithFormat:@"%@%@%@",preStr,insertString,nextStr];
        }
        else
        {
            newBody = [NSString stringWithFormat:@"%@%@",insertString,oldString];
        }
    }
    else
    {
        NSRange preRange = NSMakeRange(0, location);
        NSRange nextRange = NSMakeRange(location + selectedLength, oldString.length - location- selectedLength);
        NSString* preStr = [oldString substringWithRange:preRange];
        NSString* nextStr = [oldString substringWithRange:nextRange];
        newBody = [NSString stringWithFormat:@"%@%@%@",preStr,insertString,nextStr];
    }
    return newBody;
}
- (void) startVoiceInput
{
    if ([self.titleTextFiled isFirstResponder]) {
        self.firtResponser = self.titleTextFiled;
    }
    else if ([self.bodyTextField isFirstResponder])
    {
        self.firtResponser = self.bodyTextField;
    }
    [self.voiceInput startRecognition];
    [self setUserInterfaceEnableSelf:NO];
    [self keyHideOrShow];
}



- (void) voiceInputOver:(NSString *)result
{
    [self setUserInterfaceEnableSelf:YES];
    if (self.firtResponser == self.titleTextFiled) {
        self.titleTextFiled.text = result;
    }
    if (self.firtResponser == self.bodyTextField) {
      NSString* string =   [self insertStringToOldWithRange:self.bodyTextField.text inserString:result range:self.bodyTextField.selectedRange];
        self.bodyTextField.text = string;
    }
}
-(void) buildInterface
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self buildAddAttachmentsView];
    [self buildAddDocumentInfoView];
    [self buildNavigationButtons];
    [self buildInputContentView];
    //key control
    self.keyControl = [[[UIImageView alloc] initWithFrame:CGRectMake(250 , self.view.frame.size.height - 35, 50, 25)] autorelease];
    self.keyControl.image = [UIImage imageNamed:@"keyHidden"];
    [self.view addSubview:self.keyControl];
    keyControl.tag = KEYHIDDEN;
    UITapGestureRecognizer* keyHide = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyHideOrShow)] autorelease];
    keyHide.numberOfTapsRequired =1;
    keyHide.numberOfTouchesRequired =1;
    [keyControl addGestureRecognizer:keyHide];
    keyControl.userInteractionEnabled = YES;
    VoiceRecognition* reg = [[VoiceRecognition alloc] initWithFrame:CGRectMake(200, 100, 50 , 25) parentView:self.view];
    [self addSelcetorToView:@selector(startVoiceInput) :reg.image];
    self.voiceInput = reg;
    self.voiceInput.hidden = YES;
    reg.owner = self;
    [self.view addSubview:reg];
    [reg release];
}

- (void) postSelectedMessageToPicker
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfMainPickSelectedView object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:TypeOfMainPickerViewIndex]];
}
- (NSString*) documentBody
{
    return self.bodyTextField.text;
}
-(void) saveDocument
{
    [self audioStopRecord];
    self.docEdit.title = self.titleTextFiled.text;
    [self.docEdit saveWithData];
    [self postSelectedMessageToPicker];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfTagViewVillReloadData object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfFolderViewVillReloadData object:nil userInfo:nil];
    [self.navigationController dismissModalViewControllerAnimated:YES];
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

- (void) cancelSave
{
    [self audioStopRecord];
    if (self.titleTextFiled.text == nil || [self.titleTextFiled.text isEqualToString:@""]  ) {
        if ( self.bodyTextField.text == nil || [self.bodyTextField.text isEqualToString:@""]) {
            if ([self.picturesArray count] == 0 || 0 == [self.audiosArray count]) {
                [self postSelectedMessageToPicker];
                [self.navigationController dismissModalViewControllerAnimated:YES];
                return;
            }
        }
    }
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:WizStrAreyousureyouwanttoquit delegate:self cancelButtonTitle:WizStrCancel destructiveButtonTitle:WizStrQuitwithoutsaving otherButtonTitles:nil, nil];
    [actionSheet showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:YES];
    [actionSheet release];
}
- (id) init
{
    self = [super init];
    if (self) {
        [self buildInterface];
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:WizStrSave style:UIBarButtonItemStyleDone target:self action:@selector(saveDocument)];
        self.navigationItem.rightBarButtonItem = editButton;
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStyleDone target:self action:@selector(cancelSave)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [editButton release];
        [cancelButton release];
    }
    return self;
}
- (void) printRect:(CGRect) rect
{
    NSLog(@"rect is %f %f %f %f",rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}
- (void) keyboardWillShow:(NSNotification*) nc
{
    NSDictionary* userInfo = [nc userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    CGFloat kbHeight = kbSize.height < kbSize.width?kbSize.height:kbSize.width;
    self.bodyTextField.frame = CGRectMake(0.0,31,self.view.frame.size.width,self.view.frame.size.height - kbHeight - 70);
    [self printRect:self.bodyTextField.frame];
    [self.keyControl setFrame:CGRectMake( self.view.frame.size.width - 50, self.view.frame.size.height - kbHeight - 35, 50, 25)];
    [self.voiceInput setFrame:CGRectMake( self.view.frame.size.width - 100, self.view.frame.size.height - kbHeight - 35, 50, 25)];
    self.voiceInput.hidden = NO;
    self.keyControl.hidden = NO;
    [UIView commitAnimations];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:TypeOfSelectedTag object:nil];
    [nc removeObserver:self name:TypeOfUnSelectedTag object:nil];
    
    if (self.addAttachmentView.tag == HIDDENTTAG) {
        [self addAttachmentsViewAnimation];
    }
    else  if (self.addDocumentInfoView.tag == HIDDENTTAG) {
        [self addDocumentInfoViewAnimation];
    }
    [self fitInfoItemFrame];
    [self fitAttachmentItemFrame];
    [self printRect:self.view.frame];
    self.attachmentsTableviewEntryButton.frame = CGRectMake((self.view.frame.size.width - 300)/2, 74, 300, 20);
}

- (void) viewWillDisappear:(BOOL)animated
{
    if (self.addDocumentInfoView.tag == NOHIDDENTTAG)
    {
        self.addDocumentInfoView.tag = HIDDENTTAG;
    } else
    {
        self.addDocumentInfoView.tag = NOHIDDENTTAG;
    }
    if (self.addAttachmentView.tag == NOHIDDENTTAG) {
        self.addAttachmentView.tag = HIDDENTTAG;
    }
    else
    {
        self.addAttachmentView.tag = NOHIDDENTTAG;
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self fitInfoItemFrame];
    [self fitAttachmentItemFrame];
    self.addAttachmentView.frame = CGRectMake(self.addAttachmentView.frame.origin.x, self.addAttachmentView.frame.origin.y, self.view.frame.size.width, self.addAttachmentView.frame.size.height);
    self.addDocumentInfoView.frame = CGRectMake(self.addDocumentInfoView.frame.origin.x, self.addDocumentInfoView.frame.origin.y, self.view.frame.size.width, self.addDocumentInfoView.frame.size.height);
    self.bodyTextField.frame = CGRectMake(0.0, 31, self.view.frame.size.width, self.bodyTextField.frame.size.height);
    self.titleTextFiled.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.bodyTextField.frame.size.height);
    self.attachmentsTableviewEntryButton.frame = CGRectMake((self.view.frame.size.width - 300)/2, 74, 300, 20);
}
- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self addAttachemntsViewDisappear];
    self.voiceInput.hidden = NO;
    [self addDocumentInfoDisappear];
}
- (void) textViewDidBeginEditing:(UITextView *)textView
{
    [self addAttachemntsViewDisappear];
     self.voiceInput.hidden = NO;
    [self addDocumentInfoDisappear];
}


@end
