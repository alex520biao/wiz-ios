//
//  WizPadDocumentViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentViewController.h"
#import "WizPadDocumentListController.h"
#import "DocumentListViewControllerBaseNew.h"
#import "WizUiTypeIndex.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "WizDownloadObject.h"
#import "DocumentInfoViewController.h"
#import "DocumentListViewCell.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "CommonString.h"
#import "WizDownloadPool.h"
#import "WizPadEditNoteController.h"
#import "WizDictionaryMessage.h"
#import "WizPadNotificationMessage.h"
#import "UIBadgeView.h"
#import "WizCheckAttachments.h"

#define EditTag 1000
#define NOSUPPOURTALERT 1201

#define TableLandscapeFrame CGRectMake(0.0, 0.0, 320, 660)
#define ToolbarLandscapeFrame CGRectMake(0.0, 660, 1024, 44)
#define WebViewLandscapeFrame CGRectMake(321, 45, 703, 616)
#define HeadViewLandScapeFrame CGRectMake(321, 0.0, 703, 44)
#define TablePortraitFrame   CGRectMake(0.0, 0.0, 0.0, 0.0)
#define HeadViewPortraitFrame     CGRectMake(0.0, 0.0, 768, 44)
#define WebViewPortraitFrame     CGRectMake(0.0, 45, 768, 979)
#define ToolbarPortraitFrame     CGRectMake(0.0, 916, 768, 44)

#define HeadViewLandScapeZoomFrame CGRectMake(0.0, 0.0, 1024, 44)
#define WebViewLandScapeZoomFrame CGRectMake(0.0, 45, 1024, 616)
@interface UIWebView(WizUIWebView) 

- (BOOL) containImages;

@end

@implementation UIWebView(WizUIWebView) 


- (BOOL) containImages
{
	NSString* script = @"function containImages() { var images = document.images; return (images && images.length > 0) ? \"1\" : \"0\"; } containImages();";
	//
	NSString* ret = [self stringByEvaluatingJavaScriptFromString:script];
	//
	if (!ret)
		return NO;
	if ([ret isEqualToString:@"1"])
		return YES;
	if ([ret isEqualToString:@"0"])
		return NO;
	
	//
	return NO;
}

- (NSString*) bodyText
{
	//NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return body.innerHTML.replace(/\\&lt;br\\&gt;/gi,\"\\n\").replace(/(&lt;([^&gt;]+)&gt;)/gi, \"\"); } getBodyText();";
	NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return \"\"; } getBodyText();";
	//
	NSMutableString* ret = [NSMutableString stringWithString: [self stringByEvaluatingJavaScriptFromString:script]];
	if (!ret)
		return [NSString stringWithString: @""];
	//
	/*
     while ([ret rangeOfString:@"\n\n"].location != NSNotFound)
     {
     [ret replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, [ret length])];
     }
     */
	
	//
	return ret;
}


@end

@implementation WizPadDocumentViewController
@synthesize zoomOrShrinkButton;
@synthesize refreshIndicatorView;
@synthesize webView;
@synthesize documentList;
@synthesize headerView;
@synthesize accountUserId;
@synthesize sourceArray;
@synthesize listType;
@synthesize documentListKey;
@synthesize documentsArray;
@synthesize documentNameLabel;
@synthesize selectedDocumentGUID;
@synthesize attachmentBarItem;
@synthesize infoBarItem;
@synthesize editBarItem;
@synthesize searchItem;
@synthesize currentPopoverController;
@synthesize attachmentCountBadge;
- (void) dealloc
{
    self.attachmentCountBadge = nil;
    self.attachmentBarItem = nil;
    self.zoomOrShrinkButton = nil;
    self.infoBarItem = nil;
    self.editBarItem = nil;
    self.searchItem = nil;
    self.refreshIndicatorView = nil;
    self.selectedDocumentGUID = nil;
    self.documentNameLabel = nil;
    self.documentsArray = nil;
    self.listType = -1;
    self.documentListKey = nil;
    self.sourceArray = nil;
    self.accountUserId = nil;
    self.documentList = nil;
    self.headerView = nil;
    self.webView = nil;
    self.currentPopoverController = nil;
    [super dealloc];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
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
    newNote.accountUserId = self.accountUserId;
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    if (TypeOfLocation == self.listType) {
        [data setObject:self.documentListKey forKey:TypeOfSelectedFolder];
    }
    else if ( TypeOfTag == self.listType)
    {
        [data setObject:self.documentListKey forKey:TypeOfSelectedTag];
    }
    [newNote prepareNewDocumentData:data];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    controller.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
}

- (void) setViewsFrame
{
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.documentList.frame = TableLandscapeFrame;
        self.webView.frame = WebViewLandscapeFrame;
        self.headerView.frame = HeadViewLandScapeFrame;
        self.documentNameLabel.frame = CGRectMake(44, 0.0, 680, 44);
        self.zoomOrShrinkButton.hidden = NO;
    }
    else
    {
        self.documentNameLabel.frame = CGRectMake(5.0, 0.0, 768, 44);
        self.zoomOrShrinkButton.hidden = YES;
        self.documentList.frame = TablePortraitFrame;
        self.webView.frame = WebViewPortraitFrame;
        self.headerView.frame = HeadViewPortraitFrame;
    }
}

- (void) shrinkDocumentWebView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.webView cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.headerView cache:YES];
    [UIView setAnimationDuration:0.3];
    self.headerView.frame = HeadViewLandScapeFrame;
    self.webView.frame = WebViewLandscapeFrame;
    self.documentList.frame = TableLandscapeFrame;
    [UIView commitAnimations];
    [self.zoomOrShrinkButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    [self.zoomOrShrinkButton removeTarget:self action:@selector(shrinkDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomOrShrinkButton addTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
}

- (void) zoomDocumentWebView
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.webView cache:YES];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.headerView cache:YES];
    [UIView setAnimationDuration:0.3];
    self.headerView.frame = HeadViewLandScapeZoomFrame;
    self.webView.frame = WebViewLandScapeZoomFrame;
    self.documentList.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
    [UIView commitAnimations];
    [self.zoomOrShrinkButton setImage:[UIImage imageNamed:@"shrink"] forState:UIControlStateNormal];
    [self.zoomOrShrinkButton removeTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [self.zoomOrShrinkButton addTarget:self action:@selector(shrinkDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
}
- (void) buildHeaderView
{
    UIView* headerView_ = [[UIView alloc] init];
    self.headerView = headerView_;
    headerView_.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:headerView_];
    [headerView_ release];
    
    
    UIButton* zoomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    zoomButton.frame = CGRectMake(0.0, 0.0, 44, 44);
    [self.headerView addSubview:zoomButton];
    [zoomButton addTarget:self action:@selector(zoomDocumentWebView) forControlEvents:UIControlEventTouchUpInside];
    [zoomButton setImage:[UIImage imageNamed:@"zoom"] forState:UIControlStateNormal];
    self.zoomOrShrinkButton = zoomButton;
    UILabel* namelabel_ = [[UILabel alloc] initWithFrame:CGRectMake(44, 0.0, 680, 44)];
    [self.headerView addSubview:namelabel_];
    self.documentNameLabel = namelabel_;
    [namelabel_ release];
    
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

- (void) updateTheNavigationTitle
{
     NSString* title_ = [NSString stringWithFormat:NSLocalizedString(@"%d note in %d notes",nil),[self indexOfDocument:self.selectedDocumentGUID],[self.sourceArray count]];
    self.title = title_;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    UILabel* countLabel = [[UILabel  alloc] initWithFrame:CGRectMake(0.0, 5, 230, 20)];
    NSString* title_ = [NSString stringWithFormat:NSLocalizedString(@"%d notes",nil),[self.sourceArray count]];
    countLabel.text = title_;
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.textColor = [UIColor grayColor];
    self.documentList.tableHeaderView = countLabel;
    [countLabel release];
}

- (void) loadArraySource
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    switch (self.listType) {
        case TypeOfKey:
        {
            self.sourceArray = [NSMutableArray arrayWithArray:[index documentsByKey:self.documentListKey]];
            break;
        }
        case TypeOfLocation:
        {
            NSMutableArray* array = [[index documentsByLocation:self.documentListKey] mutableCopy];
            self.sourceArray = array;
            [array release];
            break;
        }
        case TypeOfTag:
        {
            NSMutableArray* array = [[index documentsByTag:self.documentListKey] mutableCopy];
            self.sourceArray = array;
            [array release];
            break;
        }
        default:
        {
            NSMutableArray* array = [[index recentDocuments] mutableCopy];
            self.sourceArray = array;
            self.selectedDocumentGUID = self.documentListKey;
            [array release];
            break;
        }  
    }
}

- (void) documentsOrderedBtMonth:(NSArray*) array
{
    NSRange range = NSMakeRange(0, 7);
    if ([array count] == 1) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        [sectionArray addObject:[array objectAtIndex:0]];
        [self.documentsArray addObject:sectionArray];
        return;
    }
    if ([array count] == 0) {
        return;
    }
    int docIndex = 0;
    for (int i =0; i<12; i++) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        for(int k = docIndex; k <= [array count]-1; k++)
        {
            WizDocument* doc1 = [array objectAtIndex:k];
            WizDocument* doc2 = [array objectAtIndex:k+1];
            if(k == [array count] -2)
            {
                if ([[doc1.dateModified substringWithRange:range] isEqualToString:[doc2.dateModified substringWithRange:range]]) {
                    [sectionArray addObject:doc1];
                    [sectionArray addObject:doc2];
                    [self.documentsArray addObject:sectionArray];
                } else
                {
                    [sectionArray addObject:doc1];
                    NSMutableArray* sectionArr = [NSMutableArray array];
                    [sectionArr addObject:doc2];
                    [self.documentsArray addObject:sectionArray];
                    [self.documentsArray addObject:sectionArr];
                }
                return;
            }
            if ([[doc1.dateModified substringWithRange:range] isEqualToString:[doc2.dateModified substringWithRange:range]]) {
                [sectionArray addObject:doc1];
            } else
            {
                [sectionArray addObject:doc1];
                [self.documentsArray addObject:sectionArray];
                docIndex = k+1;
                break;
            }
            
        }
    }

}

- (void) documentsOrderedByDate
{
    [self documentsOrderedBtMonth:self.sourceArray];
}
- (void) log
{
    NSLog(@"dd");
}

- (void) checkDocumentDtail
{
    
    if (nil != self.currentPopoverController) {
        [currentPopoverController dismissPopoverAnimated:YES];
    }
    
    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:self.selectedDocumentGUID];
    infoView.doc = doc;
    infoView.accountUserId = self.accountUserId;
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:infoView] ;
    pop.popoverContentSize = CGSizeMake(320, 300);
    self.currentPopoverController = pop;
    [currentPopoverController presentPopoverFromBarButtonItem:self.infoBarItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [pop release];
    [infoView release];
}
- (void) onEditDone
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:self.selectedDocumentGUID];
    NSLog(@"doc tag is %@",doc.tagGuids);
    [self.webView reload];
}
- (void) onEditCurrentDocument
{
    WizPadEditNoteController* edit = [[WizPadEditNoteController alloc] init];
    WizDocument* doc = [[[WizGlobalData sharedData] indexData:self.accountUserId] documentFromGUID:selectedDocumentGUID];
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [data setObject:[self.webView bodyText] forKey:TypeOfDocumentBody];
    [data setObject:doc.title forKey:TypeOfDocumentTitle];
    edit.documentGUID = selectedDocumentGUID;
    edit.accountUserId = accountUserId;
    [edit prepareEditingData:data];
    
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:edit];
    [edit release];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self.navigationController presentModalViewController:nav animated:YES];
    [nav release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onEditDone) name:MessageOfEditDocumentDone object:nil];
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
    BOOL b = [self.webView containImages];
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    WizDocument* doc = [index documentFromGUID:self.selectedDocumentGUID]; 
    if (b || ![doc.type isEqualToString:@"note"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Edit note", nil) 
                                                        message:NSLocalizedString(@"If you choose to edit this document, images and text-formatting will be lost.", nil) 
                                                       delegate:self 
                                              cancelButtonTitle:nil 
                                              otherButtonTitles:NSLocalizedString(@"Continue editing", nil),WizStrCancel, nil];
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

- (void) checkAttachment
{
    if (nil != self.currentPopoverController) {
        [currentPopoverController dismissPopoverAnimated:YES];
    }
    WizCheckAttachments* checkAttach = [[WizCheckAttachments alloc] init];
    checkAttach.documentGUID = [NSString stringWithString:selectedDocumentGUID];
    checkAttach.accountUserId = accountUserId;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:checkAttach];
    [checkAttach release];
    nav.contentSizeForViewInPopover = CGSizeMake(320, 500);
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:nav];
    self.currentPopoverController = pop;
    pop.popoverContentSize = CGSizeMake(320, 500);
    [pop release];
    [nav release];
    [currentPopoverController presentPopoverFromBarButtonItem:self.attachmentBarItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (void) buildToolBar
{
    UIButton* editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [editBtn setImage:[UIImage imageNamed:@"edit_gray"] forState:UIControlStateNormal];
    editBtn.frame = CGRectMake(0.0, 0.0, 44, 44);
    [editBtn addTarget:self action:@selector(editCurrentDocument:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* edit =  [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    edit.width = 80;

    UIBadgeView* attachCount = [[UIBadgeView alloc] initWithFrame:CGRectMake(44, 0.0, 20, 20)];
    self.attachmentCountBadge = attachCount;
    [attachCount release];
    UIButton* attach = [UIButton buttonWithType:UIButtonTypeCustom];
    attach.frame = CGRectMake(0.0, 0.0, 44, 44);
    [attach setImage:[UIImage imageNamed:@"newNoteAttach_gray"] forState:UIControlStateNormal];
    [attach addSubview:self.attachmentCountBadge];
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
    UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.frame = CGRectMake(10, 10, 24, 24);
    self.refreshIndicatorView = activityView;
    UIBarButtonItem* activity = [[UIBarButtonItem alloc] initWithCustomView:activityView];
    [activityView setHidesWhenStopped:YES];
    [activityView release];
    
    NSArray* items = [NSArray arrayWithObjects:flex,flex,activity, edit, attachment, detail, flex,newNote, nil];
   
    [self setToolbarItems:items];
    self.editBarItem = edit;
    self.infoBarItem = detail;
    self.attachmentBarItem = attachment;
    [edit release];
    [attachment release];
    [detail release];
    [flex release];
    [newNote release];
    [activity release];
    

}
- (void) downloadDocumentDone:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSDictionary* ret = [userInfo valueForKey:@"ret"];
    NSString* documentGUID = [ret valueForKey:@"document_guid"];
    WizDownloadPool* downloadPool = [[WizGlobalData sharedData] globalDownloadPool:accountUserId];
    [downloadPool removeDownloadProcess:documentGUID type:[WizGlobals documentKeyString]];
    if ([documentGUID isEqualToString:selectedDocumentGUID]) {
        [self.refreshIndicatorView stopAnimating];
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        WizDocument* selectedDocument = [index documentFromGUID:selectedDocumentGUID];
        NSString* documentFileName = [index documentViewFilename:selectedDocument.guid];
        if(![[NSFileManager defaultManager] fileExistsAtPath:documentFileName])
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Does not support", nil)
                                                            message:NSLocalizedString(@"This version of WizNote does not support decryption!", nil)
                                                           delegate:self 
                                                  cancelButtonTitle:@"ok" 
                                                  otherButtonTitles:nil];
            alert.tag = 100;
            [alert show];
            [alert release];
            return;
        }
        NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:40.0f];
        [self.webView loadRequest:req];
        [req release];
        [url release];
    }
}
- (void) downloadProcess:(NSNotification*) nc
{
    
}
- (void) downloadDocument:(NSString*)guid
{
    WizDownloadPool* downloadPool = [[WizGlobalData sharedData] globalDownloadPool:accountUserId];
    if ([downloadPool documentIsDownloading:guid]) {
        return;
    }
    if (![downloadPool checkCanProduceAProcess]) {
        return;
    }
    WizDownloadDocument* download = [downloadPool getDownloadProcess:guid type:[WizGlobals documentKeyString]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDocumentDone:) name:[download notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix ] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProcess:) name:[download notificationName:WizGlobalSyncProcessInfo] object:nil];
    [download downloadDocument:guid];
    [self.refreshIndicatorView startAnimating];
}
- (void) checkDocument:(NSString*)guid
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSString* documentFileName = [index documentViewFilename:guid];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:req];
    [req release];
    [url release];
}
- (void) displayEncryInfo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Does not support", nil)
                                                    message:NSLocalizedString(@"This version of WizNote does not support decryption!", nil)
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
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.selectedDocumentGUID = doc.guid;
    self.documentNameLabel.text = doc.title;
    [self.webView loadHTMLString:@"" baseURL:nil];
    self.attachmentCountBadge.badgeString = [NSString stringWithFormat:@"%d",[index attachmentCountOfDocument:selectedDocumentGUID]];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[index updateObjectDateTempFilePath:doc.guid]]) {
        if ([index documentServerChanged:doc.guid]) {
            [self downloadDocument:doc.guid];
        }
        else {
            WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
            NSString* documentFileName = [index documentViewFilename:doc.guid];
            if ([[NSFileManager defaultManager] fileExistsAtPath:documentFileName]) {
                [self checkDocument:doc.guid];
            }
            else {
                [self downloadDocument:doc.guid];
            }
        }
    }
    else {
        if (![WizGlobals checkFileIsEncry:[index updateObjectDateTempFilePath:doc.guid]]) {
            [self downloadDocument:doc.guid];
        }
        else {
           [self displayEncryInfo]; 
        }
        
    }
    [self updateTheNavigationTitle];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self didSelectedDocument:doc];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (nil != self.selectedDocumentGUID && ![selectedDocumentGUID isEqualToString:@""]) {
        for (int i = 0; i < [self.documentsArray count]; i++) {
            for (int j = 0; j < [[self.documentsArray objectAtIndex:i] count]; j++) {
                WizDocument* doc = [[self.documentsArray objectAtIndex:i] objectAtIndex:j];
                if ([doc.guid isEqualToString:selectedDocumentGUID]) {
                    [self didSelectedDocument:[[self.documentsArray objectAtIndex:i] objectAtIndex:j] ];
                    [self.documentList scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                }
            }
        }
    }
    else
    {
        if (self.documentsArray == nil || ![self.documentsArray count]) {
            return;
        }
        WizDocument* doc = [[self.documentsArray objectAtIndex:0] objectAtIndex:0];
        if (nil != doc) {
            [self didSelectedDocument:doc];
        }
    }
}
//- (void) popSelf
//{
//    [self.navigationController popViewControllerAnimated:YES];
//}
- (void) viewDidLoad
{
    [super viewDidLoad];
    UITableView* tableViw = [[UITableView alloc] init];
    self.documentList = tableViw;
    [self.view addSubview:self.documentList];
    [tableViw release];
    [self buildHeaderView];
    UIWebView* webView_ = [[UIWebView alloc] init];
    self.webView = webView_;
    webView_.userInteractionEnabled = YES;
    webView_.multipleTouchEnabled = YES;
    webView_.scalesPageToFit = YES;
    webView_.dataDetectorTypes = UIDataDetectorTypeAll;
    [self.view addSubview:webView_];
    [webView_ release];
    if (documentsArray == nil) {
        self.documentsArray = [NSMutableArray array] ;
    }
    self.documentList.dataSource = self;
    self.documentList.delegate = self;
    [self setViewsFrame];
    [self loadArraySource];
    [self documentsOrderedByDate];
    self.view.backgroundColor = [UIColor blackColor];
    [self buildToolBar];
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
    WizDocument* doc = [[self.documentsArray objectAtIndex:section] objectAtIndex:0];
    NSDate* date = [WizGlobals sqlTimeStringToDate:doc.dateModified];
    return [WizGlobals dateToLocalString:date];
}

- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DocumentCell";
    DocumentListViewCell *cell = (DocumentListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[DocumentListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accoutUserId = accountUserId;
    }
    cell.doc = doc;
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
    label.text = [self tableView:self.documentList titleForHeaderInSection:section];
    return sectionView;
}
@end
