//
//  WizCheckAttachments.m
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizCheckAttachments.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizDownloadPool.h"
#import "WizGlobals.h"
#import "WizDownloadObject.h"
@implementation WizCheckAttachments

@synthesize documentGUID;
@synthesize accountUserId;
@synthesize attachments;
@synthesize waitAlert;

- (void) dealloc
{
    self.documentGUID = nil;
    self.accountUserId = nil;
    self.attachments = nil;
    self.waitAlert = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.attachments == nil) {
        self.attachments = [NSMutableArray array];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.attachments = nil;
    self.attachments = [NSMutableArray arrayWithArray:[index attachmentsByDocumentGUID:self.documentGUID]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attachments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    WizDocumentAttach* attach = [self.attachments objectAtIndex:indexPath.row];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if ([index attachmentSeverChanged:attach.attachmentGuid]) {
        cell.detailTextLabel.text = NSLocalizedString(@"Tap to download", nil);
    }
    else
    {
        cell.detailTextLabel.text = NSLocalizedString(@"Tap to view", nil);
    }
    if ([WizGlobals checkAttachmentTypeIsAudio:attach.attachmentType]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_video_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsPPT:attach.attachmentType])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_ppt_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsWord:attach.attachmentType])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_word_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsExcel:attach.attachmentType])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_excel_img"];
    }
    else if ([WizGlobals checkAttachmentTypeIsImage:attach.attachmentType])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_image_img"];
    }
    else 
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_file_img"];
    }
    cell.textLabel.text = attach.attachmentName;
    return cell;
}
-(void) checkAttachment:(WizDocumentAttach*) attachment
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (![index attachmentSeverChanged:attachment.attachmentGuid]) {
        NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attachment.attachmentGuid];
        NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attachment.attachmentName];
        UIWebView* webview = [[UIWebView alloc] init];
        webview.multipleTouchEnabled = YES;
        webview.scalesPageToFit = YES;
        webview.userInteractionEnabled = YES;
        NSURL* url = [[NSURL alloc] initFileURLWithPath:attachmentFilePath];
        NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
        [webview loadRequest:req];
        [req release];
        [url release];
        UIViewController* contr = [[UIViewController alloc] init];
        contr.view = webview;
        [self.navigationController pushViewController:contr animated:YES];
        [contr release];
        [webview release];
    }
    else
    {
        WizDownloadPool* downloader = [[WizGlobalData sharedData] globalDownloadPool:self.accountUserId];
        if ([downloader attachmentIsDownloading:attachment.attachmentGuid]) {
            return;
        }
        else
        {
            if (![downloader checkCanProduceAProcess]) {
                return;
            }
            WizDownloadAttachment* download = [downloader getDownloadProcess:attachment.attachmentGuid type:[WizGlobals attachmentKeyString]];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDone:) name:[download notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix ]object:nil];
            [download downloadAttachment:attachment.attachmentGuid];
            UIAlertView* alert = nil;
            [WizGlobals showAlertView:NSLocalizedString(@"Sync attachments", nil) 
                              message:NSLocalizedString(@"Please wait while downloading attachment...!", nil) 
                             delegate:self 
                              retView:&alert];
            self.waitAlert = alert;
            [alert show];
        }
    }
    
}
- (void) downloadDone:(NSNotification*)nc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.waitAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.waitAlert = nil;
    NSDictionary* userInfo = [nc userInfo];
    NSDictionary* ret = [userInfo valueForKey:@"ret"];
    NSString* documentGUID_ = [ret valueForKey:@"document_guid"];
    for (int i = 0; i<[self.attachments count]; i++) {
        WizDocumentAttach* attach = [self.attachments objectAtIndex:i];
        if ([attach.attachmentGuid isEqualToString:documentGUID_]) {
            [self checkAttachment:attach];
        }
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    [self checkAttachment:attch];
}

@end
