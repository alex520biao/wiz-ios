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
#import "WizCheckAttachment.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"
@implementation WizCheckAttachments

@synthesize documentGUID;
@synthesize accountUserId;
@synthesize attachments;
@synthesize waitAlert;
@synthesize checkNav;

- (void) dealloc
{
    self.checkNav = nil;
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
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
- (void) documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
    NSLog(@"ddd");
}
- (void) checkInWiz:(WizDocumentAttach*)attachment
{
    NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attachment.attachmentGuid];
    NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attachment.attachmentName];
    WizCheckAttachment* check = [[WizCheckAttachment alloc] initWithNibName:nil bundle:nil];;
    NSURL* url = [[NSURL alloc] initFileURLWithPath:attachmentFilePath];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    check.req = req;
    [req release];
    [url release];
    if (WizDeviceIsPad()) {
        [self.checkNav pushViewController:check animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfCheckAttachment object:nil userInfo:nil];
    }
    else {
        [self.navigationController pushViewController:check animated:YES];
    }
}
- (void) checkInOtherApp:(WizDocumentAttach*)attachment
{
    NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attachment.attachmentGuid];
    NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attachment.attachmentName];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:attachmentFilePath];
    UIDocumentInteractionController* preview = [UIDocumentInteractionController interactionControllerWithURL:url];
    preview.delegate = self;
    CGRect nav = self.navigationController.navigationBar.frame;
    nav.size = CGSizeMake(1500.0f, 40.0f);
    [preview presentOptionsMenuFromRect:nav inView:self.view animated:YES];
    [preview retain];
    [url release];
}
-(void) checkAttachment:(WizDocumentAttach*) attachment inWiz:(BOOL)inWiz
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (![index attachmentSeverChanged:attachment.attachmentGuid]) {
        if (inWiz) {
            [self checkInWiz:attachment];
        }
        else {
            [self checkInOtherApp:attachment];
        }
        
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
            [self checkAttachment:attach inWiz:YES];
        }
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    [self checkAttachment:attch inWiz:YES];
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    [self checkAttachment:attch inWiz:NO];
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (nil != self.checkNav) {
        [self.checkNav willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

@end
