//
//  DocumentViewCtrollerBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewCtrollerBase.h"
#import "NewNoteView.h"
#import "TFHpple.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "WizDownloadObject.h"
#import "DocumentInfoViewController.h"
#import "UIBadgeView.h"
#import "WizDictionaryMessage.h"
#import "WizCheckAttachments.h"
#import "WizNotification.h"
#import "WizSyncManager.h"
#import "WizSettings.h"
#import "WizFileManager.h"

#import "WizPhoneEditorViewControllerL5.h"
#import "WizPhoneEditViewControllerM5.h"
#import <UIKit/UIKit.h>
#import "ATMHud.h"

#define NOSUPPOURTALERT 199

#define AttachmentCountBadgeViewLandscapeFrame CGRectMake(150  ,0.0 , 20, 20)
#define AttachmentCountBadgeViewPotraitFrame    CGRectMake(100  , 0.0 , 20, 20)

@interface DocumentViewCtrollerBase()
{
    NSString* fontWidth;
    UIWebView* web;
    UISlider* webFontSizeSlider;
    UIBarItem* attachmentBarItem;
    UIBarItem* infoBarItem;
    UIBarItem* editBarItem;
    UIBarItem* searchItem;
    UISearchBar* searchDocumentBar;
    UIAlertView* conNotDownloadAlert;
    ATMHud* downloadActivity;
    UIBadgeView* attachmentCountBadgeView;
    BOOL isEdit;
}
@property (nonatomic, retain)  UIWebView* web;
@property (nonatomic, retain)  UIAlertView* conNotDownloadAlert;
@property (nonatomic, retain)  ATMHud* downloadActivity;
@property (assign) BOOL isEdit;
@property (nonatomic, retain) NSString* fontWidth;
-(void)editDocument;
-(void)viewAttachments;
-(void)viewDocumentInfo;
-(void)searchDocument;
@end

@implementation DocumentViewCtrollerBase
@synthesize  web;
@synthesize doc;
@synthesize fontWidth;
@synthesize downloadActivity;
@synthesize conNotDownloadAlert;
@synthesize isEdit;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        web = [[UIWebView alloc] init];
        web.delegate = self;
        downloadActivity = [[ATMHud alloc] initWithDelegate:self];
        searchDocumentBar = [[UISearchBar alloc] init];
        searchDocumentBar.delegate = self;
        attachmentCountBadgeView = [[UIBadgeView alloc] init];
    }
    return self;
}
- (void) loadView
{
    self.view = self.web;
    self.web.frame = [[UIScreen mainScreen] bounds];
}

-(void) dealloc
{
    [searchItem release];
    [web release];
    [doc release];
    [attachmentBarItem release];
    [infoBarItem release];
    [editBarItem release];
    [searchDocumentBar release];
    [conNotDownloadAlert release];
    [downloadActivity release];
    [attachmentCountBadgeView release];
    
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void) shareFromEmail
{
    MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
    NSString* string = [NSString stringWithContentsOfFile:[self.doc documentIndexFile] usedEncoding:nil error:nil];
    emailController.mailComposeDelegate = self;
     NSString* title = [NSString stringWithFormat:@"%@ %@",self.doc.title,WizStrShareByWiz];
     [emailController setSubject:title];
    [emailController setMessageBody:string isHTML:YES];
    [self presentModalViewController:emailController animated:YES];
    [emailController release];
}
- (void) shareImagesFromEmail
{
    MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSString* title = [NSString stringWithFormat:@"%@ %@",self.doc.title,WizStrShareByWiz];
    [emailController setSubject:title];
    NSArray* contents = [[WizFileManager shareManager] contentsOfDirectoryAtPath:[self.doc documentIndexFilesPath] error:nil];
    for (NSString* each in contents) {
        NSString* fileDirPath = [self.doc documentIndexFilesPath];
        NSString* filePath = [fileDirPath stringByAppendingPathComponent:each];
        if ([WizGlobals checkAttachmentTypeIsImage:[each fileType]]) {
            NSData* data = [NSData dataWithContentsOfFile:filePath];
            if (nil != data) {
                [emailController addAttachmentData:data mimeType:@"image" fileName:each];
            }
        }
    }
    [emailController setMessageBody:[web bodyText] isHTML:YES];
    [self presentModalViewController:emailController animated:YES];
    [emailController release];
}
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void) shareFromEms
{
    MFMessageComposeViewController* messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    NSString* title = [NSString stringWithFormat:@"%@ %@",self.doc.title,WizStrShareByWiz];
    [messageController setTitle:title];
    [messageController setBody:[[web bodyText] stringByAppendingFormat:@"\n%@",WizStrShareByWiz]];
    [self presentModalViewController:messageController animated:YES];
    [messageController release];
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:WizStrShareByEmail]) {
        [self shareFromEmail];
    }
    else if ([buttonTitle isEqualToString:WizstrShareImagesByEmail])
    {
        [self shareImagesFromEmail];
    }
    else if ([buttonTitle isEqualToString:WizStrShareByEms])
    {
        [self shareFromEms];
    }
    else {
        
    }
}

- (void) shareCurrentDocument
{
    UIActionSheet* shareSheet = [[UIActionSheet alloc]
                                 initWithTitle:NSLocalizedString(@"Share", nil)
                                 delegate:self
                                 cancelButtonTitle:nil
                                 destructiveButtonTitle:nil
                                 otherButtonTitles:nil];
    if ([MFMailComposeViewController canSendMail]) {
        [shareSheet addButtonWithTitle:WizStrShareByEmail];
        if ([self.doc isIosDocument]) {
            if ([web containImages]) {
                [shareSheet addButtonWithTitle:WizstrShareImagesByEmail];
            }
        }
    }
    if ([MFMessageComposeViewController canSendText]) {
        [shareSheet addButtonWithTitle:WizStrShareByEms];
    }
    [shareSheet addButtonWithTitle:WizStrCancel];
    UIBarButtonItem* item = [self.toolbarItems objectAtIndex:4];
    shareSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [shareSheet showFromBarButtonItem:item animated:YES];
    [shareSheet release];
}

- (void) loadReadJs
{
    NSString* url = self.doc.url;
    NSString* type = self.doc.type;
    NSString* width = nil;
    
    [self.navigationController.toolbar bringSubviewToFront:attachmentCountBadgeView];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        width = UIWebViewWidthForIphoneLandscape;
        attachmentCountBadgeView.frame = AttachmentCountBadgeViewLandscapeFrame;
    }
    else {
        width = UIWebViewWidthForIphonePotrait;
        attachmentCountBadgeView.frame = AttachmentCountBadgeViewPotraitFrame;
    }
    
    if ([[WizSettings defaultSettings] isMoblieView])
    {
        [web setCurrentPageWidth:width];
    }else {
        if ([self.doc isIosDocument] || (url == nil || [url isEqualToString:@""])  || ((type == nil || [type isEqualToString:@""]) && url.length>4) ||(([[url substringToIndex:4] compare:@"http" options:NSCaseInsensitiveSearch] != 0) && ([type compare:@"webnote" options:NSCaseInsensitiveSearch] != 0))) {
            [web setCurrentPageWidth:width];
        }
    }
    if ([self.doc isIosDocument]) {
        [web setTableAndImageWidth:width];
    }
}
-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    [webView loadReadJavaScript];
    [self.downloadActivity hide];

    [self loadReadJs];

    
}
- (void) webViewDidStartLoad:(UIWebView *)webView
{
    [self setToolbarItemsEnable:YES];
}
- (void) setDeviceWidth
{
    self.fontWidth = @"320px";
}

- (void) setZoomWidth
{
    self.fontWidth = @"768px";
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewAttachments
{
    WizCheckAttachments* checkAttach = [[WizCheckAttachments alloc] init];
    checkAttach.doc = self.doc;
    [self.navigationController pushViewController:checkAttach animated:YES];
    [checkAttach release];
}
- (NSString*) oldBodyText
{
    return [self.web bodyText];
}
- (void)editCurrentDocument
{
    self.isEdit = YES;
    if ([WizGlobals WizDeviceVersion] <5 ) {
        WizPhoneEditorViewControllerL5* newNoteController = [[WizPhoneEditorViewControllerL5 alloc] initWithWizDocument:self.doc];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNoteController];
        [self.navigationController presentModalViewController:controller animated:YES];
        [newNoteController release];
        [controller release];
    }
    else
    {
        WizPhoneEditViewControllerM5* newNoteController = [[WizPhoneEditViewControllerM5 alloc] initWithWizDocument:self.doc];
        UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNoteController];
        [self.navigationController presentModalViewController:controller animated:YES];
        [newNoteController release];
        [controller release];
    }
    
//    NewNoteView* newNote= [[NewNoteView alloc]init];
//    WizDocument* edit = self.doc;
//    newNote.docEdit = edit;
//    NSMutableArray* array =[NSMutableArray array];
//    if ([self.doc.type isEqualToString:WizDocumentTypeAudioKeyString] || [self.doc.type isEqualToString:WizDocumentTypeImageKeyString] || [self.doc.type isEqualToString:WizDocumentTypeNoteKeyString]) {
//       [array addObjectsFromArray:[self.doc existPhotoAndAudio]]; 
//    }
//    [array addObjectsFromArray:[self.doc attachments]];
//    [newNote prepareForEdit:[self.web bodyText] attachments:array];
//    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
//    [self.navigationController presentModalViewController:controller animated:YES];
//    [newNote release];
//    [controller release];
    self.isEdit = YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NOSUPPOURTALERT) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
    }
	if( buttonIndex == 0 ) //Edit
	{
		[self editCurrentDocument];
	}
}

- (void) setToolbarItemsEnable:(BOOL)enable
{
    for (UIBarButtonItem* each in self.toolbarItems) {
        [each setEnabled:enable];
    }
}

- (void) editDocument
{
	BOOL b = [web containImages];
	//
	if (b || ![self.doc.type isEqualToString:WizDocumentTypeNoteKeyString])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WizStrEditNote 
														message:WizStrIfyouchoosetoeditthisdocument
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:WizStrContinueediting,WizStrCancel, nil];
		
		[alert show];
		[alert release];
	}
	else 
	{
		[self editCurrentDocument];
	}
}

- (void) downloadProcess:(NSNotification*) nc
{
    return;
}

- (void)viewDocumentInfo
{
    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoView.doc = self.doc;
    [self.navigationController pushViewController:infoView animated:YES];
    [infoView release];
}
- (void) hideSearchBar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:searchDocumentBar cache:NO];
    searchDocumentBar.hidden = YES;
    [UIView commitAnimations];
}
- (void)searchDocument
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:searchDocumentBar cache:NO];
    [web removeAllHighlights];
    searchDocumentBar.hidden = NO;
    [searchDocumentBar becomeFirstResponder];
    [UIView commitAnimations];
}
- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil || [searchText isEqualToString:@""]) {
        return;
    }
    [self.web highlightAllOccurencesOfString:searchText];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton = YES;
}
- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [web removeAllHighlights];
    [self hideSearchBar];
}
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self hideSearchBar];
}

- (void) downloadDocument
{
    [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(downloadDocumentDone:)];
    [self.doc download];
    return;
}
- (void) checkDocument
{
    self.web.scalesPageToFit = YES;
    NSString* documentFileName = [self.doc documentWillLoadFile];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:40.0f];
    [self.web loadRequest:req];
    [req release];
    [url release];
}
- (void) displayEncryInfo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError
                                                    message:WizStrThisversionofWizNotdoesnotsupportdecryption
                                                   delegate:self 
                                          cancelButtonTitle:WizStrOK
                                          otherButtonTitles:nil];
    alert.tag = NOSUPPOURTALERT;
    [alert show];
    [alert release];
    return;
}
- (void) downloadDocumentDone:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter downloadGuidFromNc:nc];
    if (nil == guid || ![guid isEqualToString:self.doc.guid]) {
        return;
    }
    self.doc.serverChanged = NO;
    [self checkDocument];
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
}
-(void) viewWillDisappear:(BOOL)animated
{
    [WizNotificationCenter removeObserverForDownloadDone:self];
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
    [attachmentCountBadgeView removeFromSuperview];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.isEdit) {
        [self.web reload];
        self.doc = [WizDocument documentFromDb:self.doc.guid];
        self.isEdit = NO;
    }
    NSUInteger attachmentsCount = self.doc.attachmentCount;
    if (attachmentsCount > 0) {
        attachmentCountBadgeView.frame = AttachmentCountBadgeViewPotraitFrame;
        attachmentCountBadgeView.badgeString = [NSString stringWithFormat:@"%d",attachmentsCount];
    }
    else {
        attachmentCountBadgeView.hidden = YES;
    }
    self.title = self.doc.title;
    NSString* documentFileName = [self.doc documentIndexFile];
    if (self.doc.protected_) {
        [self displayEncryInfo];
        return;
    }
    if (self.doc.serverChanged) {
        [self downloadDocument];
    }
    else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentFileName]) {
            [self checkDocument];
        }
        else {
            [self downloadDocument];
        }
    }
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController.toolbar addSubview:attachmentCountBadgeView];
    [self setToolbarItemsEnable:NO];
    
    searchDocumentBar.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 44);
    [self.view addSubview:searchDocumentBar];
    searchDocumentBar.hidden = YES;
    [searchDocumentBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
}
- (void) changeToolBarStatue:(UITapGestureRecognizer*)sender
{
    if (self.navigationController.toolbarHidden) {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.navigationController setToolbarHidden:YES animated:YES];
    }
}
- (void) buildToolBar
{
    UIBarButtonItem* edit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(editCurrentDocument)];
    
    UIBarButtonItem* info = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detail"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewDocumentInfo)];
    
    UIBarButtonItem* attachment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNoteAttach"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewAttachments)];
    
    UIBarButtonItem* search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchDocument)];
    search.style = UIBarButtonItemStyleBordered;
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareCurrentDocument)];
    
    NSArray* array = [NSArray arrayWithObjects:edit,flex,attachment,flex,info,flex,search, flex,shareItem, nil];
    [edit release];
    [flex release];
    [info release];
    [attachment release];
    [search release];
    [shareItem release];
    [self setToolbarItems:array];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@" %f",self.view.frame.size.width);
    [self.view addSubview:self.downloadActivity.view];
    [self.downloadActivity setCaption:WizStrLoading];
    [self.downloadActivity setActivity:YES];
    [self.downloadActivity show];
    [self buildToolBar];
}
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if (otherGestureRecognizer.numberOfTouches > 1) {
        return NO;
    }
    return YES;
}
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self loadReadJs];
}

@end

