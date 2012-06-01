//
//  WizPadDocumentViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentViewController.h"
#import "WizUiTypeIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "WizDownloadObject.h"
#import "DocumentInfoViewController.h"
#import "DocumentListViewCell.h"
#import "WizGlobalData.h"

#import "CommonString.h"
#import "WizPadEditNoteController.h"
#import "WizDictionaryMessage.h"
#import "WizPadNotificationMessage.h"
#import "UIBadgeView.h"
#import "WizCheckAttachments.h"
#import "WizNotification.h"
#import "NSMutableArray+WizDocuments.h"
#import "WizSyncManager.h"
#import "WizSettings.h"
#import "ATMHud.h"
#import "WizFileManager.h"

#define EditTag 1000
#define NOSUPPOURTALERT 1201
#define TableLandscapeFrame CGRectMake(0.0, 0.0, 320, 660)
#define WebViewLandscapeFrame CGRectMake(320, 45, 704, 620)
#define HeadViewLandScapeFrame CGRectMake(320, 0.0, 704, 45)
//
#define TablePortraitFrame   CGRectMake(0.0, 0.0, 0.0, 0.0)
#define HeadViewPortraitFrame     CGRectMake(0.0, 0.0, 768, 45)
#define WebViewPortraitFrame     CGRectMake(0.0, 45, 768, 936)


#define HeadViewLandScapeZoomFrame CGRectMake(0.0, 0.0, 1024, 44)
#define WebViewLandScapeZoomFrame CGRectMake(0.0, 45, 1024, 616)
@interface WizPadDocumentViewController ()
{
    UIWebView* webView;
    UIView* headerView;
    UITableView* documentList;
    UITableView* potraitTableView;
    //
    WizDocument* selectedDocument;
    
    WizTableOrder kOrderIndex;
    UILabel* documentNameLabel;
    UIBadgeView* attachmentCountBadge;
    UIPopoverController* currentPopoverController;
    UIButton* zoomOrShrinkButton;
    //
    NSInteger readWidth;
    //
    
    UIBarButtonItem* editItem;
    UIBarButtonItem* newNoteItem;
    UIBarButtonItem* detailItem;
    UIBarButtonItem* attachmentsItem;
    UIBarButtonItem* shareItem;
}
@property NSInteger readWidth;
@property (nonatomic, retain) WizDocument* selectedDocument;
@property (nonatomic, retain)  UIPopoverController* currentPopoverController;
@end
@implementation WizPadDocumentViewController
@synthesize listType;
@synthesize documentListKey;
@synthesize documentsArray;
@synthesize selectedDocument;
@synthesize currentPopoverController;
@synthesize readWidth;
- (void) dealloc
{
    //
    editItem = nil;
    newNoteItem = nil;
    detailItem = nil;
    attachmentsItem = nil;
    shareItem = nil;
    //
    [potraitTableView release];
    potraitTableView = nil;
    //
    [attachmentCountBadge release];
    [zoomOrShrinkButton release];
    [selectedDocument release];
    [documentNameLabel release];
    [documentsArray release];
    [documentListKey release];
    [documentList release];
    [headerView release];
    [webView release];
    kOrderIndex = -1;
    [currentPopoverController release];
    [WizNotificationCenter removeObserver:self];
    [super dealloc];

}

- (void) loadReadJs
{
    [webView loadReadJavaScript];
    NSString* url = self.selectedDocument.url;
    NSString* type = self.selectedDocument.type;
    NSString* width = [NSString stringWithFormat:@"%dpx",self.readWidth];
    NSLog(@"width is %@",width);
    if ([[WizSettings defaultSettings] isMoblieView])
    {
        [webView setCurrentPageWidth:width];
    }
    else
    {
        if ([self.selectedDocument isIosDocument] || (url == nil || [url isEqualToString:@""])  || ((type == nil || [type isEqualToString:@""]) && url.length>4) ||(([[url substringToIndex:4] compare:@"http" options:NSCaseInsensitiveSearch] != 0) && ([type compare:@"webnote" options:NSCaseInsensitiveSearch] != 0))) {
            [webView setCurrentPageWidth:width];
        }
    }
    if ([self.selectedDocument isIosDocument]) {
        [webView setTableAndImageWidth:width];
    }
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self loadReadJs];
}

- (void) onDeleteDocument:(NSNotification*)nc
{
    WizDocument* document = [WizNotificationCenter getWizDocumentFromNc:nc];
    if (document == nil) {
        return;
    }
    NSLog(@"document title delete%@",document.title);
    NSLog(@"%d",[[self.documentsArray objectAtIndex:0] count]);
    NSIndexPath* docIndex = [self.documentsArray removeDocument:document];
    NSLog(@"docindex %@",docIndex);
    if (docIndex != nil) {
        if (docIndex.row == WizDeletedSectionIndex)
        {
            [documentList beginUpdates];
            [documentList deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationTop];
            [documentList endUpdates];
            
            [potraitTableView beginUpdates];
            [potraitTableView deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationTop];
            [potraitTableView endUpdates];
        }
        else {
            [documentList beginUpdates];
            [documentList deleteRowsAtIndexPaths:[NSArray arrayWithObject:docIndex] withRowAnimation:UITableViewRowAnimationTop];
            [documentList endUpdates];
//            
            [potraitTableView beginUpdates];
            [potraitTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:docIndex] withRowAnimation:UITableViewRowAnimationTop];
            [potraitTableView endUpdates];
        }
        
    }
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.documentsArray = [NSMutableArray array];
        kOrderIndex = -1;
        [WizNotificationCenter addObserverForDeleteDocument:self selector:@selector(onDeleteDocument:)];
        [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(downloadDocumentDone:)];
    }
    return self;
}
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissModalViewControllerAnimated:YES];
}
- (void) shareFromEmail
{
    MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
    NSString* string = [NSString stringWithContentsOfFile:[self.selectedDocument documentIndexFile] usedEncoding:nil error:nil];
    emailController.mailComposeDelegate = self;
    NSString* title = [NSString stringWithFormat:@"%@ %@",self.selectedDocument.title,WizStrShareByWiz];
    [emailController setSubject:title];
    [emailController setMessageBody:string isHTML:YES];
    [self presentModalViewController:emailController animated:YES];
    [emailController release];
}
- (void) shareImagesFromEmail
{
    MFMailComposeViewController* emailController = [[MFMailComposeViewController alloc] init];
    emailController.mailComposeDelegate = self;
    NSString* title = [NSString stringWithFormat:@"%@ %@",self.selectedDocument.title,WizStrShareByWiz];
    [emailController setSubject:title];
    NSArray* contents = [[WizFileManager shareManager] contentsOfDirectoryAtPath:[self.selectedDocument documentIndexFilesPath] error:nil];
    for (NSString* each in contents) {
        NSString* fileDirPath = [self.selectedDocument documentIndexFilesPath];
        NSString* filePath = [fileDirPath stringByAppendingPathComponent:each];
        if ([WizGlobals checkAttachmentTypeIsImage:[each fileType]]) {
            NSData* data = [NSData dataWithContentsOfFile:filePath];
            if (nil != data) {
                [emailController addAttachmentData:data mimeType:@"image" fileName:each];
            }
        }
    }
    [emailController setMessageBody:[webView bodyText] isHTML:YES];
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
    NSString* title = [NSString stringWithFormat:@"%@ %@",self.selectedDocument.title,WizStrShareByWiz];
    [messageController setTitle:title];
    [messageController setBody:[[webView bodyText] stringByAppendingFormat:@"\n%@",WizStrShareByWiz]];
    [self presentModalViewController:messageController animated:YES];
    [messageController release];
}
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= actionSheet.numberOfButtons | buttonIndex < 0) {
        return;
    }
    NSLog(@"%d %d",actionSheet.numberOfButtons, buttonIndex);
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
        if ([self.selectedDocument isIosDocument]) {
            if ([webView containImages]) {
                [shareSheet addButtonWithTitle:WizstrShareImagesByEmail];
            }
        }
    }
    if ([MFMessageComposeViewController canSendText]) {
        [shareSheet addButtonWithTitle:WizStrShareByEms];
    }
    [shareSheet addButtonWithTitle:WizStrCancel];
    shareSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [shareSheet showFromBarButtonItem:shareItem animated:YES];
    [shareSheet release];
}
- (void) dismissPoperview
{
    if (nil != self.currentPopoverController) {
        [currentPopoverController dismissPopoverAnimated:YES];
    }
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) newNote
{
    WizPadEditNoteController* newNote = [[WizPadEditNoteController alloc] init];
    WizDocument* document = [[WizDocument alloc] init];
    if (self.listType == WizPadCheckDocumentSourceTypeOfFolder) {
        document.location = self.documentListKey;
    }
    else if (self.listType == WizPadCheckDocumentSourceTypeOfTag)
    {
        document.tagGuids = self.documentListKey;
    }
    newNote.docEdit = document;
    [document release];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    controller.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
}
- (void) popTheDocumentList
{
    [self dismissPoperview];
    UIViewController* con = [[UIViewController alloc] init];
    con.view = potraitTableView;
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:con];
    [pop presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    self.currentPopoverController = pop;
    [pop release];
    [con release];
}
- (void) setViewsFrame
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        documentList.frame = TableLandscapeFrame;
        webView.frame = WebViewLandscapeFrame;
        headerView.frame = HeadViewLandScapeFrame;
        documentNameLabel.frame = CGRectMake(44, 0.0, 680, 44);
        zoomOrShrinkButton.hidden = NO;
    }
    else
    {
        documentNameLabel.frame = CGRectMake(5.0, 0.0, 768, 44);
        zoomOrShrinkButton.hidden = YES;
        documentList.frame = TablePortraitFrame;
        webView.frame = WebViewPortraitFrame;
        headerView.frame = HeadViewPortraitFrame;
    }

    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self dismissPoperview];
        self.navigationItem.rightBarButtonItem = nil;
    }
    else {
        UIBarButtonItem* listItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"List", nil) style:UIBarButtonItemStyleDone target:self action:@selector(popTheDocumentList)];
        self.navigationItem.rightBarButtonItem = listItem;
        [listItem release];
    }
}

- (void) shrinkDocumentWebView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:webView cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:headerView cache:YES];
    [UIView setAnimationDuration:0.3];
    headerView.frame = HeadViewLandScapeFrame;
    webView.frame = WebViewLandscapeFrame;
    documentList.frame = TableLandscapeFrame;
    [UIView commitAnimations];
    self.readWidth = 704;
    [self loadReadJs];
    [zoomOrShrinkButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    [zoomOrShrinkButton removeTarget:self action:@selector(shrinkDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [zoomOrShrinkButton addTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
}

- (void) zoomDocumentWebView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:webView cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:headerView cache:YES];
    [UIView setAnimationDuration:0.3];
    headerView.frame = HeadViewLandScapeZoomFrame;
    webView.frame = WebViewLandScapeZoomFrame;
    documentList.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [UIView commitAnimations];
    self.readWidth = 1024;
    [self loadReadJs];
    [zoomOrShrinkButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
    [zoomOrShrinkButton removeTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [zoomOrShrinkButton addTarget:self action:@selector(shrinkDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
}
- (void) buildHeaderView
{
    headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView];
    //
    zoomOrShrinkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    zoomOrShrinkButton.frame = CGRectMake(0.0, 0.0, 44, 44);
    [headerView addSubview:zoomOrShrinkButton];
    [zoomOrShrinkButton addTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [zoomOrShrinkButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    documentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0.0, 680, 44)];
    [headerView addSubview:documentNameLabel];
    UILabel* countLabel = [[UILabel  alloc] initWithFrame:CGRectMake(0.0, 5, 230, 20)];
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.textColor = [UIColor grayColor];
    documentList.tableHeaderView = countLabel;
    [countLabel release];
    //
    [WizGlobals decorateViewWithShadowAndBorder:headerView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [self setViewsFrame];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.readWidth = 704;
    }
    else {
        self.readWidth = 768;
    }
}
- (void) loadArraySource
{
    switch (self.listType) {
        case WizPadCheckDocumentSourceTypeOfRecent:
        {
            if ([self.documentsArray count] == 0) {
                NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument recentDocuments]];
                [self.documentsArray addObject:array];
                [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
            }
            break;
        }
        case WizPadCheckDocumentSourceTypeOfFolder:
        {
            [self.documentsArray removeAllObjects];
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument documentsByLocation:self.documentListKey]];
            [self.documentsArray addObject:array];
            [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
            break;
        }
        case WizPadCheckDocumentSourceTypeOfTag:
        {
            [self.documentsArray removeAllObjects];
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument documentsByTag:self.documentListKey]];
            [self.documentsArray addObject:array];
            [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
            break;
        }
        case WizPadCheckDocumentSourceTypeOfSearch:
        {
            [self.documentsArray removeAllObjects];
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument documentsByKey:self.documentListKey]];
            [self.documentsArray addObject:array];
            [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
            break;
        }
        default:
        {
            [self.documentsArray removeAllObjects];
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument recentDocuments]];
            [self.documentsArray addObject:array];
            self.selectedDocument = [WizDocument documentFromDb:self.documentListKey];
            [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
            break;
        }  
    }
    [documentList reloadData];
}

- (void) checkDocumentDtail
{
    [self dismissPoperview];
    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    WizDocument* doc = selectedDocument;
    infoView.doc = doc;
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:infoView] ;
    pop.popoverContentSize = CGSizeMake(320, 300);
    self.currentPopoverController = pop;
    [currentPopoverController presentPopoverFromBarButtonItem:detailItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [pop release];
    [infoView release];
}
- (void) onEditDone
{
    [webView reload];
}
- (void) onEditCurrentDocument
{
    WizPadEditNoteController* edit = [[WizPadEditNoteController alloc] init];
    edit.docEdit = self.selectedDocument;
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:2];
    if ([self.selectedDocument.type isEqualToString:WizDocumentTypeAudioKeyString] || [self.selectedDocument.type isEqualToString:WizDocumentTypeImageKeyString] || [self.selectedDocument.type isEqualToString:WizDocumentTypeNoteKeyString]) {
        [array addObjectsFromArray:[self.selectedDocument existPhotoAndAudio]];
    }
    [edit prepareForEdit:[webView bodyText] attachments:array];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:edit];
    [edit release];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == EditTag) {
        if( buttonIndex == 0 ) //Edit
        {
            [self onEditCurrentDocument];
        }
    }
    
}

- (IBAction) editCurrentDocument: (id)sender
{
    BOOL b = [webView containImages];
    if (b || ![self.selectedDocument.type isEqualToString:@"note"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WizStrEditNote
                                                        message:WizStrIfyouchoosetoeditthisdocument 
                                                       delegate:self
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:WizStrContinueediting,WizStrCancel, nil];
        alert.delegate = self;
        alert.tag = EditTag;
        [alert show];
        [alert release];
    }
    else 
    {
        [self onEditCurrentDocument];
    }
}
- (void) didPushCheckAttachmentViewController:(UIViewController *)attachement
{
    [self.navigationController pushViewController:attachement animated:YES];
}
- (void) checkAttachment
{
    [self dismissPoperview];
    WizCheckAttachments* checkAttach = [[WizCheckAttachments alloc] init];
    checkAttach.checkAttachmentDelegate = self;
    checkAttach.doc = self.selectedDocument;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:checkAttach];
    [checkAttach release];
    nav.contentSizeForViewInPopover = CGSizeMake(320, 500);
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:nav];
    self.currentPopoverController = pop;
    pop.popoverContentSize = CGSizeMake(320, 500);
    [pop release];
    [nav release];
    [currentPopoverController presentPopoverFromBarButtonItem:attachmentsItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (void) buildToolBar
{
    UIBarButtonItem* edit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(editCurrentDocument:)];
    
    UIBarButtonItem* attachment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNoteAttach_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkAttachment)];
    
    UIBarButtonItem* detail = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detail_gray"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkDocumentDtail)];
    
    
    UIBarButtonItem* share = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleBordered target:self action:@selector(shareCurrentDocument)];
    
    UIBarButtonItem* newNote =[[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flex.width = 344;
   
    UIBarButtonItem* flex2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flex2.width = 40;
    
    
    
    
    NSArray* items = [NSArray arrayWithObjects:newNote, flex,flex, edit,flex2, attachment,flex2, detail,flex2, share,flex,nil];
   
    [self setToolbarItems:items];
    //
    newNoteItem = newNote;
    editItem = edit;
    attachmentsItem = attachment;
    detailItem = detail;
    shareItem = share;
    //
    [edit release];
    [attachment release];
    [detail release];
    [flex release];
    [newNote release];
    [share release];
    [flex2 release];
}
- (void) downloadDocumentDone:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter downloadGuidFromNc:nc];
    WizDocument* document = [WizDocument documentFromDb:documentGUID];
    if (nil == document) {
        return;
    }
     document.serverChanged = NO;
    NSIndexPath* index = [self.documentsArray updateDocument:document];
    if (nil != index) {
        [documentList beginUpdates];
        [documentList reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
        [documentList endUpdates];
        if (!UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            if (nil != potraitTableView) {
                [potraitTableView beginUpdates];
                [potraitTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationFade];
                [potraitTableView endUpdates];
            }
        }
    }
    else {
        return;
    }
    if ([documentGUID isEqualToString:self.selectedDocument.guid]) {
        [self checkDocument:document];
    }
}
- (void) downloadDocument:(WizDocument*)document
{
    WizSyncManager* share = [WizSyncManager shareManager];
    [share downloadWizObject:document];
    [webView loadRequest:nil];
}
- (void) checkDocument:(WizDocument*)document
{
    NSString* documentFileName = [document documentIndexFile];
    if (![[WizFileManager shareManager] fileExistsAtPath:documentFileName]) {
        [self downloadDocument:document];
    }
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [webView loadRequest:req];
    [req release];
    [url release];
}
- (void) displayEncryInfo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning
                                                    message:WizStrThisversionofWizNotdoesnotsupportdecryption
                                                   delegate:self 
                                          cancelButtonTitle:WizStrOK 
                                          otherButtonTitles:nil];
    alert.tag = NOSUPPOURTALERT;
    [alert show];
    [alert release];
    return;
}
- (void) didSelectedDocument:(WizDocument*)doc
{
    self.selectedDocument = doc;
    documentNameLabel.text = doc.title;
    [webView loadHTMLString:@"" baseURL:nil];
    NSUInteger attachmentsCount = doc.attachmentCount;
    if (attachmentsCount > 0) {
        attachmentCountBadge.hidden = NO;
        attachmentCountBadge.badgeString = [NSString stringWithFormat:@"%d",attachmentsCount];
    }
    else {
        attachmentCountBadge.hidden = YES;
    }
    if (doc.serverChanged) {
        [self downloadDocument:doc];
    }
    else {
        [self checkDocument:doc];
    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [self didSelectedDocument:doc];
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (kOrderIndex != [[WizSettings defaultSettings] userTablelistViewOption]) {
        [self loadArraySource];
    }
    
    if (WizPadCheckDocumentSourceTypeOfRecent == self.listType) {
        WizDocument* document = [WizDocument documentFromDb:self.documentListKey];
        if (document != nil) {
            NSIndexPath* indexPath = [self.documentsArray indexPathOfWizDocument:document];
            if (indexPath != nil && indexPath.row != NSNotFound && indexPath.section != NSNotFound) {
                [self tableView:documentList didSelectRowAtIndexPath:indexPath];
            }
        }
    }
    else {
        if ([self.documentsArray count] >0) {
            if ([[self.documentsArray objectAtIndex:0] count] > 0) {
                [self tableView:documentList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        }
    }
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self dismissPoperview];
}

- (void) buildWebView
{
    webView = [[UIWebView alloc] init];
    webView.userInteractionEnabled = YES;
    webView.multipleTouchEnabled = YES;
    webView.scalesPageToFit = YES;
    webView.dataDetectorTypes = UIDataDetectorTypeAll;
    webView.delegate = self;
    [self.view addSubview:webView];
    [WizGlobals decorateViewWithShadowAndBorder:webView];
}

- (void) buildDocumentTable
{
    documentList = [[UITableView alloc] init];
    [self.view addSubview:documentList];
    documentList.dataSource = self;
    documentList.delegate = self;
    
    potraitTableView = [[UITableView alloc] init];
    potraitTableView.dataSource = self;
    potraitTableView.delegate = self;
    
    [WizGlobals decorateViewWithShadowAndBorder:documentList];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    [self buildDocumentTable];
    [self buildHeaderView];
    [self buildWebView];
    [self buildToolBar];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissPoperview) name:MessageOfCheckAttachment object:nil];
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
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        self.readWidth = 768;
    }
    else {
        self.readWidth = 704;
    }
    [self loadReadJs];
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{

    [self setViewsFrame];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfViewWillOrientent object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:toInterfaceOrientation] forKey:TypeOfViewInterface]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.documentsArray objectAtIndex:section] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.documentsArray count];
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.documentsArray objectAtIndex:section] description];
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    DocumentListViewCell* docCell = (DocumentListViewCell*)cell;
//    WizDownloadPool* pool = [[WizGlobalData sharedData] globalDownloadPool:accountUserId];
//    if ([pool documentIsDownloading:doc.guid]) {
//        [docCell.downloadIndicator startAnimating];
//    }
//    else {
//        [docCell.downloadIndicator stopAnimating];
//    }
}
- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DocumentCell";
    DocumentListViewCell *cell = (DocumentListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[DocumentListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.doc = doc;
    if ([[WizSyncManager shareManager] isDownloadingWizobject:doc]) {
        [cell setShowDownloadIndicator:YES];
    }
    [cell performSelectorOnMainThread:@selector(prepareForAppear) withObject:nil waitUntilDone:YES];
    return cell;
}
- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView* sectionView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 20)] autorelease];
    sectionView.image = [UIImage imageNamed:@"tableSectionHeader"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    [label release];
    label.text = [self tableView:documentList titleForHeaderInSection:section];
    return sectionView;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSLog(@"document title %@",doc.title);
        [WizDocument deleteDocument:doc];
        NSLog(@"document title %@",doc.title);
        NSLog(@"ddd");
    }
}
@end
