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
#import "WizApi.h"
#import "WizDownloadObject.h"
#import "DocumentInfoViewController.h"
#import "CommonString.h"
#import "UIBadgeView.h"
#import "WizDictionaryMessage.h"
#import "WizCheckAttachments.h"
#import "WizNotification.h"
#import "WizSyncManager.h"
#import "WizSettings.h"

#define NOSUPPOURTALERT 199

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
    UIActivityIndicatorView* downloadActivity;
    BOOL isEdit;
}
@property (nonatomic, retain) IBOutlet UIWebView* web;
@property (nonatomic, retain)  UISearchBar* searchDocumentBar;
@property (nonatomic, retain)  UIAlertView* conNotDownloadAlert;
@property (nonatomic, retain)  UIActivityIndicatorView* downloadActivity;
@property (assign) BOOL isEdit;
@property (nonatomic, retain) NSString* fontWidth;
- (void) downloadDocumentDone;
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
@synthesize searchDocumentBar;
@synthesize conNotDownloadAlert;
@synthesize isEdit;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIWebView* webView = [[UIWebView alloc] init];
        self.web = webView;
        [webView release];
    }
    return self;
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
    [super dealloc];
}


- (void) changeWebViewWidth
{
    NSString* ret = [NSString stringWithFormat:@"var meta= document.createElement(\"meta\"); \n\
                     meta.setAttribute('name','viewport'); \n\
                     meta.setAttribute('content','width=%@,initial-scale=1.0'); \n\
                     document.getElementsByTagName(\"head\")[0].appendChild(meta);",self.fontWidth];
    [self.web stringByEvaluatingJavaScriptFromString:ret];
}


//-(void) webViewDidFinishLoad:(UIWebView *)webView
//{
//    [self.downloadActivity stopAnimating];
//    self.downloadActivity.hidden = YES;
//    self.searchItem.enabled = YES;
//    self.editBarItem.enabled = YES;
//    self.attachmentBarItem.enabled = YES;
//    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
//    [nc removeObserver:self];
//    [self changeWebViewWidth];
//}
- (void) setDeviceWidth
{
    self.fontWidth = @"device-width";
}

- (void) setZoomWidth
{
    self.fontWidth = @"768";
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
    checkAttach.documentGUID = self.doc.guid;
    checkAttach.checkNav = self.navigationController;
    [self.navigationController pushViewController:checkAttach animated:YES];
    [checkAttach release];
}

- (void)editCurrentDocument
{
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    NewNoteView* newNote= [[NewNoteView alloc]init];
    [data setObject:self.doc.title forKey:TypeOfDocumentTitle];
    [data setObject:self.doc.guid forKey:TypeOfDocumentGUID];
    [data setObject:[self.web bodyText] forKey:TypeOfDocumentBody];
    [newNote prepareForEdit:data];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
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

- (void) editDocument
{
	BOOL b = [web containImages];
	//
	if (b || ![self.doc.type isEqualToString:@"note"])
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


- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText == nil || [searchText isEqualToString:@""]) {
        return;
    }
    [self.web highlightAllOccurencesOfString:searchText];
}

- (void)searchDocument
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.searchDocumentBar cache:NO];
    if (self.searchDocumentBar.hidden == YES) {
        [self.web removeAllHighlights];
    }
    self.searchDocumentBar.hidden = !self.searchDocumentBar.hidden;
    [UIView commitAnimations];
}
- (void) downloadDocument
{
    [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(downloadDocumentDone)];
    [self.doc download];
    return;
}
- (void) checkDocument
{
    self.web.scalesPageToFit = YES;
    NSString* documentFileName = [self.doc documentIndexFile];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    if ([[WizSettings defaultSettings] isMoblieView]) {
        [self setDeviceWidth];
        if (![self.doc isExistMobileViewFile]) {
            NSString* documentType = self.doc.type;
            if (documentType!=nil) {
                if ([documentType compare:@"webnote" options:NSCaseInsensitiveSearch] == 0) {
                    [self setZoomWidth];
                }
            }
            else
            {
                NSString* url = self.doc.url;
                if (url != nil && url.length > 4) {
                    if ([[url substringToIndex:4] compare:@"http" options:NSCaseInsensitiveSearch] == 0) {
                        [self setZoomWidth];
                    }
                }
            }
            
        }
    }
    else {
        [self setZoomWidth];
        NSString* url = self.doc.url;
        NSString* type = self.doc.type;
        if ((url == nil || [url isEqualToString:@""])  || ((type == nil || [type isEqualToString:@""]) && url.length>4) ||(([[url substringToIndex:4] compare:@"http" options:NSCaseInsensitiveSearch] != 0) && ([type compare:@"webnote" options:NSCaseInsensitiveSearch] != 0))) {
            [self setDeviceWidth];
        }
        if ([type isEqualToString:@"webnote"]) {
            if ([self.doc isNewWebnote]) {
                [self setDeviceWidth];
            }
        }
    }
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
- (void) downloadDocumentDone
{
    [self checkDocument];
}

- (void)viewDidUnload
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc removeObserver:self.web];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
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
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.doc = [WizDocument documentFromDb:self.doc.guid];
    NSUInteger attachmentsCount = self.doc.attachmentCount;
    if (attachmentsCount > 0) {
        UIBadgeView* count = [[UIBadgeView alloc] initWithFrame:CGRectMake(125  , 370, 20, 20)];
        count.badgeString = [NSString stringWithFormat:@"%d",attachmentsCount];
        [self.view addSubview:count];
        [count release];
    }
    self.title = self.doc.title;
    if (self.isEdit) {
        [self.web reload];
        self.title = self.doc.title;
        self.isEdit = NO;
    }
    
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
    UIBarButtonItem* edit = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(editDocument)];
    
    UIBarButtonItem* info = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"detail"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewDocumentInfo)];
    
    UIBarButtonItem* attachment = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"newNoteAttach"] style:UIBarButtonItemStyleBordered target:self action:@selector(viewAttachments)];
    
    UIBarButtonItem* search = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchDocument)];
    search.style = UIBarButtonItemStyleBordered;
    
    UIBarButtonItem* flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray* array = [NSArray arrayWithObjects:edit,flex,attachment,flex,info,flex,search, nil];
    [edit release];
    [flex release];
    [info release];
    [attachment release];
    [search release];
    
    [self setToolbarItems:array];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view = self.web;
    if (nil == self.downloadActivity) {
        self.downloadActivity = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 150, 20, 20)] autorelease];
        [self.downloadActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.downloadActivity];
    }
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
@end

