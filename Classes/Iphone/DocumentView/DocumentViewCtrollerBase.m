//
//  DocumentViewCtrollerBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-1.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentViewCtrollerBase.h"
#import "WizIndex.h"
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

#define NOSUPPOURTALERT 199

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



@implementation DocumentViewCtrollerBase
@synthesize  web;
@synthesize  accountUserID;
@synthesize doc;


@synthesize downloadActivity;
@synthesize attachmentBarItem;
@synthesize infoBarItem;
@synthesize editBarItem;
@synthesize searchItem;
@synthesize searchDocumentBar;
@synthesize conNotDownloadAlert;
@synthesize download;
@synthesize isEdit;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) dealloc
{
    self.searchItem = nil;
    self.web = nil;
    self.download = nil;
    self.accountUserID =nil;
    self.doc = nil;
    self.attachmentBarItem = nil;
    self.infoBarItem = nil;
    self.editBarItem = nil;
    self.searchDocumentBar = nil;
    self.conNotDownloadAlert = nil;
    self.downloadActivity = nil;
    [super dealloc];
}


- (NSString*) addMetaJs
{
    NSString* ret = @"var meta= document.createElement(\"meta\"); \n\
        meta.setAttribute('name','viewport'); \n\
        meta.setAttribute('content','width=device-width')    \n\
        meta.setAttribute('initial-scale','1.0') \n\
        meta document.getElementsByTagName(\"head\")[0].appendChild(meta);";
    return ret;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    
    if ([index isMoblieView]) {
        NSString* jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%d%%'",[index webFontSize]];
        [self.web stringByEvaluatingJavaScriptFromString:jsString];
        [jsString release];
        [self.web stringByEvaluatingJavaScriptFromString:[self addMetaJs]];
    }
    [self.downloadActivity stopAnimating];
    self.downloadActivity.hidden = YES;
    self.searchItem.enabled = YES;
    self.editBarItem.enabled = YES;
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

-(void) fontSizeChanged:(float)size
{
    NSString* jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='%d%%'",(int)size];
    [self.web stringByEvaluatingJavaScriptFromString:jsString];
    [jsString release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (IBAction)viewAttachments:(id)sender
{
    WizCheckAttachments* checkAttach = [[WizCheckAttachments alloc] init];
    checkAttach.documentGUID = self.doc.guid;
    checkAttach.accountUserId = accountUserID;
    [self.navigationController pushViewController:checkAttach animated:YES];
    [checkAttach release];
}

- (void)editCurrentDocument
{
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    NewNoteView* newNote= [[NewNoteView alloc]initWithAccountId:self.accountUserID];
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


- (IBAction) editDocument: (id)sender
{
	BOOL b = [web containImages];
	//
	if (b || ![self.doc.type isEqualToString:@"note"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Edit note", nil) 
														message:NSLocalizedString(@"If you choose to edit this document, images and text-formatting will be lost.", nil) 
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:NSLocalizedString(@"Continue editing", nil),WizStrCancel, nil];
		
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
    NSDictionary* userInfo = [nc userInfo];
    NSString* methodName = [userInfo objectForKey:@"sync_method_name"];

    if (![methodName isEqualToString:SyncMethod_DownloadObject]) {
        return;
    }
//    [self.downloadProcessView setProgress:0.9*([current floatValue]/[total floatValue]) animated:YES];
    return;
}

- (IBAction)viewDocumentInfo:(id)sender
{
    DocumentInfoViewController* infoView = [[DocumentInfoViewController alloc] initWithStyle:UITableViewStyleGrouped];
    infoView.doc = self.doc;
    infoView.accountUserId = self.accountUserID;
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

- (IBAction)searchDocument:(id)sender
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
    self.download = [[[WizDownloadDocument alloc] initWithAccount:self.accountUserID password:@""] autorelease];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDocumentDone) name:[self.download notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix ] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProcess:) name:[self.download notificationName:WizGlobalSyncProcessInfo] object:nil];
    [self.download downloadDocument:self.doc.guid];
    return;
}
- (void) checkDocument
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    NSString* documentFileName = [index documentViewFilename:self.doc.guid];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    [self.web loadRequest:req];
    [req release];
    [url release];
}
- (void) displayEncryInfo
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(WizStrError, nil)
                                                    message:NSLocalizedString(@"This version of WizNote does not support decryption!", nil)
                                                   delegate:self 
                                          cancelButtonTitle:@"ok" 
                                          otherButtonTitles:nil];
    alert.tag = NOSUPPOURTALERT;
    [alert show];
    [alert release];
    return;
}
- (void) downloadDocumentDone
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    NSString* documentFileName = [index documentViewFilename:self.doc.guid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[index updateObjectDateTempFilePath:self.doc.guid]]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentFileName]) {
            [self checkDocument];
        }
    }
    else {
        [self displayEncryInfo];
    }
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

-(void) viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    NSString* documentFileName = [index documentViewFilename:self.doc.guid];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[index updateObjectDateTempFilePath:self.doc.guid]]) {
        if ([index documentServerChanged:self.doc.guid]) {
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
    else {
        if (![WizGlobals checkFileIsEncry:[index updateObjectDateTempFilePath:doc.guid]]) {
            [self downloadDocument];
        }
        else {
            [self displayEncryInfo]; 
        }
    }

}

-(void) viewWillAppear:(BOOL)animated
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.doc = [index documentFromGUID:self.doc.guid];
    UIBadgeView* count = [[UIBadgeView alloc] initWithFrame:CGRectMake(125  , 370, 20, 20)];
    count.badgeString = [NSString stringWithFormat:@"%d",[index attachmentCountOfDocument:self.doc.guid]];
    [self.view addSubview:count];
    [count release];
    int size = [index webFontSize];
    [self fontSizeChanged:size];
    self.title = self.doc.title;
    if (self.isEdit) {
        [self.web reload];
        self.title = self.doc.title;
        self.isEdit = NO;
    }
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (nil == self.downloadActivity) {
        self.downloadActivity = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(150, 150, 20, 20)] autorelease];
        [self.downloadActivity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [self.view addSubview:self.downloadActivity];
    }
    
    self.editBarItem.image = [UIImage imageNamed:@"edit"];
    self.infoBarItem.image = [UIImage imageNamed:@"detail"];
    self.attachmentBarItem.image = [UIImage imageNamed:@"newNoteAttach"];
    if(nil == self.web)
    {
        self.web = [[[UIWebView alloc] init] autorelease];
        self.web.opaque = NO;
    }
    self.web.delegate = self;
    
    self.searchDocumentBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 40)] autorelease];
    self.searchDocumentBar.delegate = self;
    [self.view addSubview:self.searchDocumentBar];
    self.searchDocumentBar.hidden = YES;
    self.editBarItem.enabled = NO;
    self.searchItem.enabled = NO;
    [self.downloadActivity startAnimating];
 }

@end

