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

#define EditTag 1000
#define NOSUPPOURTALERT 1201
#define TableLandscapeFrame CGRectMake(0.0, 0.0, 320, 660)
#define WebViewLandscapeFrame CGRectMake(320, 45, 704, 620)
#define HeadViewLandScapeFrame CGRectMake(320, 0.0, 704, 45)
//
#define TablePortraitFrame   CGRectMake(0.0, 0.0, 0.0, 0.0)
#define HeadViewPortraitFrame     CGRectMake(0.0, 0.0, 768, 45)
#define WebViewPortraitFrame     CGRectMake(0.0, 45, 768, 980)


#define HeadViewLandScapeZoomFrame CGRectMake(0.0, 0.0, 1024, 44)
#define WebViewLandScapeZoomFrame CGRectMake(0.0, 45, 1024, 616)
@interface WizPadDocumentViewController ()
{
    UIWebView* webView;
    UIView* headerView;
    UITableView* documentList;
    WizDocument* selectedDocument;
    WizDocumentsMutableArray* documentsArray;
    WizTableOrder kOrderIndex;
    UILabel* documentNameLabel;
    UIBadgeView* attachmentCountBadge;
    UIPopoverController* currentPopoverController;
    UIButton* zoomOrShrinkButton;
    
    UIBarButtonItem* editItem;
    UIBarButtonItem* newNoteItem;
    UIBarButtonItem* detailItem;
    UIBarButtonItem* attachmentsItem;
}
@property (nonatomic, retain) WizDocumentsMutableArray* documentsArray;
@property (nonatomic, retain) WizDocument* selectedDocument;
@property (nonatomic, retain)  UIPopoverController* currentPopoverController;
@end
@implementation WizPadDocumentViewController
@synthesize listType;
@synthesize documentListKey;
@synthesize documentsArray;
@synthesize selectedDocument;
@synthesize currentPopoverController;
- (void) dealloc
{
    //
    editItem = nil;
    newNoteItem = nil;
    detailItem = nil;
    attachmentsItem = nil;
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


- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void) onDeleteDocument:(NSNotification*)nc
{
    WizDocument* document = [WizNotificationCenter getWizDocumentFromNc:nc];
    if (document == nil) {
        return;
    }
    NSIndexPath* docIndex = [self.documentsArray removeDocument:document];
    if (docIndex != nil) {
        if (docIndex.row == WizDeletedSectionIndex) {
            [documentList beginUpdates];
            [documentList deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationTop];
            [documentList endUpdates];
        }
        else {
            [documentList beginUpdates];
            [documentList deleteRowsAtIndexPaths:[NSArray arrayWithObject:docIndex] withRowAnimation:UITableViewRowAnimationTop];
            [documentList endUpdates];
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
    UITableView* tableViw = [[UITableView alloc] init];
    tableViw.dataSource = self;
    tableViw.delegate = self;
    UIViewController* con = [[UIViewController alloc] init];
    con.view = tableViw;
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:con];
    [pop presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    self.currentPopoverController = pop;
    [tableViw release];
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
//
- (NSIndexPath*) indexPathOfDocument:(NSString*)docuemtGUID
{
    for (int i = 0; i < [self.documentsArray count]; i++) {
        NSArray* arr = [documentsArray objectAtIndex:i];
        for (int docIndex =0; docIndex < [arr count]; docIndex++) {
            WizDocument* doc = [arr objectAtIndex:docIndex];
            if ([doc.guid isEqualToString:docuemtGUID]) {
                return [NSIndexPath indexPathForRow:docIndex inSection:i];
            }
        }
    }
    return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
}
- (NSUInteger) indexOfDocument:(NSString*)guid
{
    NSInteger index = 0;
    for (int i = 0; i < [self.documentsArray count]; i++) {
        NSArray* arr = [documentsArray objectAtIndex:i];
        for (WizDocument* each in arr) {
            index++;
            if ([each.guid isEqualToString:guid]) {
                return index;
            }
        }
    }
    
    return -1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [self setViewsFrame];
    UILabel* count =(UILabel*)documentList.tableHeaderView;

}
- (void) loadArraySource
{
    [self.documentsArray removeAllObjects];
    switch (self.listType) {
        case WizPadCheckDocumentSourceTypeOfRecent:
        {
            [self.documentsArray addObject:[NSMutableArray arrayWithArray:[WizDocument recentDocuments]]];
//            if (![self.sourceArray count]) {
//                [WizGlobals reportWarningWithString:[NSString stringWithFormat:NSLocalizedString(@"Cannot find %@", nil),self.documentListKey]];
//            }
            break;
        }
        case WizPadCheckDocumentSourceTypeOfFolder:
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument documentsByLocation:self.documentListKey]];
            [self.documentsArray addObject:array];
            break;
        }
        case WizPadCheckDocumentSourceTypeOfTag:
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument documentsByTag:self.documentListKey]];
            [self.documentsArray addObject:array];
            break;
        }
        default:
        {
            NSMutableArray* array = [NSMutableArray arrayWithArray:[WizDocument recentDocuments]];
            [self.documentsArray addObject:array];
            self.selectedDocument = [WizDocument documentFromDb:self.documentListKey];
            break;
        }  
    }
    [self.documentsArray sortDocumentByOrder:[[WizSettings defaultSettings] userTablelistViewOption]];
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
    UIButton* editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"edit_gray"] forState:UIControlStateNormal];
    editBtn.frame = CGRectMake(0.0, 0.0, 44, 44);
    [editBtn addTarget:self action:@selector(editCurrentDocument:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* edit =  [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    edit.width = 80;

    attachmentCountBadge = [[UIBadgeView alloc] initWithFrame:CGRectMake(44, 0.0, 60, 20)];
    UIButton* attach = [UIButton buttonWithType:UIButtonTypeCustom];
    attach.frame = CGRectMake(0.0, 0.0, 44, 44);
    [attach setImage:[UIImage imageNamed:@"newNoteAttach_gray"] forState:UIControlStateNormal];
    [attach addSubview:attachmentCountBadge];
    [attach addTarget:self action:@selector(checkAttachment) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* attachment = [[UIBarButtonItem alloc]initWithCustomView:attach];
    attachment.width = 80;
    UIButton* detailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [detailBtn setImage:[UIImage imageNamed:@"detail_gray"] forState:UIControlStateNormal];
    [detailBtn addTarget:self action:@selector(checkDocumentDtail) forControlEvents:UIControlEventTouchUpInside];
    detailBtn.frame = CGRectMake(0.0, 0.0, 44, 44);
    UIBarButtonItem* detail = [[UIBarButtonItem alloc] initWithCustomView:detailBtn];
    detail.width = 80;
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    flex.width = 344;
    UIBarButtonItem* newNote =[[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];    
    NSArray* items = [NSArray arrayWithObjects:newNote, flex,flex, edit, attachment, detail, flex,nil];
   
    [self setToolbarItems:items];
    //
    newNoteItem = newNote;
    editItem = edit;
    attachmentsItem = attachment;
    detailItem = detail;
    //
    [edit release];
    [attachment release];
    [detail release];
    [flex release];
    [newNote release];
}
- (void) downloadDocumentDone:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter downloadGuidFromNc:nc];
    NSLog(@"%@",documentGUID);
    NSArray* visibleCells = [documentList visibleCells];
    for (DocumentListViewCell* each in visibleCells) {
        if ([each.doc.guid isEqualToString:documentGUID]) {
            [each prepareForAppear];
        }
    }
    if ([documentGUID isEqualToString:self.selectedDocument.guid]) {
        
        NSString* documentFileName = [self.selectedDocument documentIndexFile];
        if(![[NSFileManager defaultManager] fileExistsAtPath:documentFileName])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning
                                                            message:WizStrThisversionofWizNotdoesnotsupportdecryption
                                                           delegate:self 
                                                  cancelButtonTitle:WizStrOK 
                                                  otherButtonTitles:nil];
            alert.tag = 100;
            [alert show];
            [alert release];
            return;
        }
        NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:40.0f];
        [webView loadRequest:req];
        [req release];
        [url release];
    }
}
- (void) downloadDocument:(WizDocument*)document
{
    WizSyncManager* share = [WizSyncManager shareManager];
    [share downloadWizObject:document];
}
- (void) checkDocument:(WizDocument*)document
{
    NSString* documentFileName = [document documentIndexFile];
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
//    if (![[NSFileManager defaultManager] fileExistsAtPath:[index updateObjectDateTempFilePath:doc.guid]]) {
//        if ([index documentServerChanged:doc.guid]) {
//            [self downloadDocument:doc.guid];
//        }
//        else {
//            WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//            NSString* documentFileName = [index documentViewFilename:doc.guid];
//            if ([[NSFileManager defaultManager] fileExistsAtPath:documentFileName]) {
//                [self checkDocument:doc.guid];
//            }
//            else {
//                [self downloadDocument:doc.guid];
//            }
//        }
//    }
//    else {
//        if (![WizGlobals checkFileIsEncry:[index updateObjectDateTempFilePath:doc.guid]]) {
//            [self downloadDocument:doc.guid];
//        }
//        else {
//           [self displayEncryInfo]; 
//        }
//        
//    }
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self didSelectedDocument:doc];
    [documentList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [documentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (kOrderIndex != [[WizSettings defaultSettings] userTablelistViewOption]) {
        [self loadArraySource];
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
        [WizDocument deleteDocument:doc];
    }
}
@end
