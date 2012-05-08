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
		return @"";
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
    [attachmentCountBadge release];
    [attachmentBarItem release];
    [zoomOrShrinkButton release];
    [infoBarItem release];
    [editBarItem release];
    [searchItem release];
    [selectedDocumentGUID release];
    [documentNameLabel release];
    [documentsArray release];
    self.listType = -1;
    [documentListKey release];
    [sourceArray release];
    [accountUserId release];
    [documentList release];
    [headerView release];
    [webView release];
    [currentPopoverController release];
    [super dealloc];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

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
    UILabel* countLabel = [[UILabel  alloc] initWithFrame:CGRectMake(0.0, 5, 230, 20)];
    countLabel.textAlignment = UITextAlignmentCenter;
    countLabel.textColor = [UIColor grayColor];
    self.documentList.tableHeaderView = countLabel;
    [countLabel release];
    
}
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

- (void) updateTheNavigationTitle
{
     NSString* title_ = [NSString stringWithFormat:@"%d/%d",[self indexOfDocument:self.selectedDocumentGUID],[self.sourceArray count]];
    self.title = title_;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    [self setViewsFrame];
    UILabel* count =(UILabel*)self.documentList.tableHeaderView;
    count.text= [NSString stringWithFormat:NSLocalizedString(@"%d notes",nil),[self.sourceArray count]];

}

- (void) loadArraySource
{
//       switch (self.listType) {
//        case TypeOfKey:
//        {
//            self.sourceArray = [NSMutableArray arrayWithArray:[index documentsByKey:self.documentListKey]];
//            if (![self.sourceArray count]) {
//                [WizGlobals reportWarningWithString:[NSString stringWithFormat:NSLocalizedString(@"Cannot find %@", nil),self.documentListKey]];
//            }
//            break;
//        }
//        case TypeOfLocation:
//        {
//            NSMutableArray* array = [[index documentsByLocation:self.documentListKey] mutableCopy];
//            self.sourceArray = array;
//            [array release];
//            break;
//        }
//        case TypeOfTag:
//        {
//            NSMutableArray* array = [[index documentsByTag:self.documentListKey] mutableCopy];
//            self.sourceArray = array;
//            [array release];
//            break;
//        }
//        default:
//        {
//            NSMutableArray* array = [[index recentDocuments] mutableCopy];
//            self.sourceArray = array;
//            self.selectedDocumentGUID = self.documentListKey;
//            [array release];
//            break;
//        }  
//    }
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
    
}

- (void) checkDocumentDtail
{
//    [self dismissPoperview];
//
//    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    WizDocument* doc = [index documentFromGUID:self.selectedDocumentGUID];
//    infoView.doc = doc;
//    infoView.accountUserId = self.accountUserId;
//    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:infoView] ;
//    pop.popoverContentSize = CGSizeMake(320, 300);
//    self.currentPopoverController = pop;
//    [currentPopoverController presentPopoverFromBarButtonItem:self.infoBarItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    [pop release];
//    [infoView release];
}
- (void) onEditDone
{
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
//    BOOL b = [self.webView containImages];
//    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
//    WizDocument* doc = [index documentFromGUID:self.selectedDocumentGUID]; 
//    if (b || ![doc.type isEqualToString:@"note"])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:WizStrEditNote
//                                                        message:WizStrIfyouchoosetoeditthisdocument 
//                                                       delegate:self 
//                                              cancelButtonTitle:nil 
//                                              otherButtonTitles:WizStrContinueediting,WizStrCancel, nil];
//        alert.delegate = self;
//        alert.tag = EditTag;
//        [alert show];
//        [alert release];
//    }
//    else 
//    {
//        [self onEditCurrentDocument];
//    }


}

- (void) checkAttachment
{
    [self dismissPoperview];
    WizCheckAttachments* checkAttach = [[WizCheckAttachments alloc] init];
    checkAttach.documentGUID = [NSString stringWithString:selectedDocumentGUID];
    checkAttach.accountUserId = accountUserId;
    checkAttach.checkNav = self.navigationController;
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

    UIBadgeView* attachCount = [[UIBadgeView alloc] initWithFrame:CGRectMake(44, 0.0, 60, 20)];
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
    NSArray* items = [NSArray arrayWithObjects:newNote, flex,flex, edit, attachment, detail, flex,nil];
   
    [self setToolbarItems:items];
    self.editBarItem = edit;
    self.infoBarItem = detail;
    self.attachmentBarItem = attachment;
    [edit release];
    [attachment release];
    [detail release];
    [flex release];
    [newNote release];
}
- (void) downloadDocumentDone:(NSNotification*)nc
{
//    NSDictionary* userInfo = [nc userInfo];
//    NSDictionary* ret = [userInfo valueForKey:@"ret"];
//    NSString* documentGUID = [ret valueForKey:@"document_guid"];
//    WizDownloadPool* downloadPool = [[WizGlobalData sharedData] globalDownloadPool:accountUserId];
//    NSIndexPath* indexPath = [self indexPathOfDocument:documentGUID];
//    if (indexPath.section == NSNotFound) {
//        return;
//    }
//    else {
//        [self.documentList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
//    }
//    [downloadPool removeDownloadProcess:documentGUID type:[WizGlobals documentKeyString]];
//    if ([documentGUID isEqualToString:selectedDocumentGUID]) {
//        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//        WizDocument* selectedDocument = [index documentFromGUID:selectedDocumentGUID];
//        NSString* documentFileName = [index documentViewFilename:selectedDocument.guid];
//        if(![[NSFileManager defaultManager] fileExistsAtPath:documentFileName])
//        {
//            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrWarning
//                                                            message:WizStrThisversionofWizNotdoesnotsupportdecryption
//                                                           delegate:self 
//                                                  cancelButtonTitle:WizStrOK 
//                                                  otherButtonTitles:nil];
//            alert.tag = 100;
//            [alert show];
//            [alert release];
//            return;
//        }
//        NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
//        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:40.0f];
//        [self.webView loadRequest:req];
//        [req release];
//        [url release];
//    }
}
- (void) downloadProcess:(NSNotification*) nc
{
    
}
- (void) downloadDocument:(NSString*)guid
{
//    WizDownloadPool* downloadPool = [[WizGlobalData sharedData] globalDownloadPool:accountUserId];
//    if ([downloadPool documentIsDownloading:guid]) {
//        return;
//    }
//    if (![downloadPool checkCanProduceAProcess]) {
//        return;
//    }
//    WizDownloadDocument* download = [downloadPool getDownloadProcess:guid type:[WizGlobals documentKeyString]];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDocumentDone:) name:[download notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix ] object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProcess:) name:[download notificationName:WizGlobalSyncProcessInfo] object:nil];
//    [download downloadDocument:guid];
}
- (void) checkDocument:(NSString*)guid
{
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    NSString* documentFileName = [index documentViewFilename:guid];
//    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
//    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
//    [self.webView loadRequest:req];
//    [req release];
//    [url release];
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
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//    self.selectedDocumentGUID = doc.guid;
//    self.documentNameLabel.text = doc.title;
//    [self.webView loadHTMLString:@"" baseURL:nil];
//    NSUInteger attachmentsCount = [index attachmentCountOfDocument:selectedDocumentGUID];
//    if (attachmentsCount > 0) {
//        self.attachmentCountBadge.hidden = NO;
//        self.attachmentCountBadge.badgeString = [NSString stringWithFormat:@"%d",attachmentsCount];
//    }
//    else {
//        self.attachmentCountBadge.hidden = YES;
//    }
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
//    [self updateTheNavigationTitle];
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self didSelectedDocument:doc];
    [self.documentList reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.documentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
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
                    [self.documentList selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionTop];
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
- (void) viewDidLoad
{
    [super viewDidLoad];
    UITableView* tableViw = [[UITableView alloc] init];
    self.documentList = tableViw;
    [self.view addSubview:self.documentList];
    self.documentList.dataSource = self;
    self.documentList.delegate = self;
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

    
    [self loadArraySource];
    [self documentsOrderedByDate];
    self.view.backgroundColor = [UIColor blackColor];
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
    WizDocument* doc = [[self.documentsArray objectAtIndex:section] objectAtIndex:0];
    NSDate* date = [doc.dateModified dateFromSqlTimeString];
    return [date stringLocal];
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
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        WizDocument* doc = [[self.documentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
//        [index deleteDocument:doc.guid];
//        [index addDeletedGUIDRecord:doc.guid type:[WizGlobals documentKeyString]];
//        [WizNotificationCenter postDeleteDocumentMassage:doc.guid];
//        if ([[documentsArray objectAtIndex:indexPath.section] count] == 1) {
//            [documentsArray removeObjectAtIndex:indexPath.section];
//            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
//        }
//        else {
//            [[documentsArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
//        }
    }
}
@end
