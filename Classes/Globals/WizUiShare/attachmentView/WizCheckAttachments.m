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
#import "WizGlobals.h"
#import "WizDownloadObject.h"
#import "WizCheckAttachment.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"

@interface WizCheckAttachments ()
{
    BOOL willCheckInWiz;
}
@end

@implementation WizCheckAttachments

@synthesize documentGUID;
@synthesize accountUserId;
@synthesize attachments;
@synthesize waitAlert;
@synthesize checkNav;
@synthesize lastIndexPath;
@synthesize currentPreview;
- (void) dealloc
{
    [currentPreview release];
    [lastIndexPath release];
    [checkNav release];
    [documentGUID release];
    [accountUserId release];
    [attachments release];
    [waitAlert release];
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
    self.lastIndexPath = nil;
    self.currentPreview = [[[UIDocumentInteractionController alloc] init] autorelease];
    self.currentPreview.delegate = self;
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
- (NSURL*) getAttachmentFileURL:(WizDocumentAttach*)attachment
{
    NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attachment.attachmentGuid];
    NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attachment.attachmentName];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:attachmentFilePath];
    return [url autorelease];
}
- (BOOL) checkCanOpenInOtherApp:(WizDocumentAttach*)attach
{
    NSURL* url = [self getAttachmentFileURL:attach];
    [currentPreview setURL:url];
    if ([[currentPreview icons] count]) {
        return YES;
    }
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizDocumentAttach* attach = [self.attachments objectAtIndex:indexPath.row];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if (attach.attachmentType == nil || [attach.attachmentType isEqualToString:@""]) {
        attach.attachmentType = @"noneType";
    }
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void) checkInWiz:(WizDocumentAttach*)attachment
{
    WizCheckAttachment* check = [[WizCheckAttachment alloc] initWithNibName:nil bundle:nil];;
    NSURL* url = [self getAttachmentFileURL:attachment];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    check.req = req;
    [req release];
    if (WizDeviceIsPad()) {
        [self.checkNav pushViewController:check animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfCheckAttachment object:nil userInfo:nil];
    }
    else {
        [self.navigationController pushViewController:check animated:YES];
    }
    [check release];
}
- (void) checkInOtherApp:(WizDocumentAttach*)attachment
{
    NSURL* url = [self getAttachmentFileURL:attachment];
    [currentPreview setURL:url];
    CGRect nav = CGRectMake(0.0, 40*(lastIndexPath.row+1), 320, 40);
    if (![currentPreview presentOptionsMenuFromRect:nav inView:self.view  animated:YES]) {
        [WizGlobals reportWarningWithString:NSLocalizedString(@"There is no application can open this file.", nil)];
    }
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
//        willCheckInWiz = inWiz;
//        WizDownloadPool* downloader = [[WizGlobalData sharedData] globalDownloadPool:self.accountUserId];
//        if ([downloader attachmentIsDownloading:attachment.attachmentGuid]) {
//            return;
//        }
//        else
//        {
//            if (![downloader checkCanProduceAProcess]) {
//                return;
//            }
//            WizDownloadAttachment* download = [downloader getDownloadProcess:attachment.attachmentGuid type:[WizGlobals attachmentKeyString]];
//            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadDone:) name:[download notificationName:WizSyncXmlRpcDonlowadDoneNotificationPrefix ]object:nil];
//            [download downloadAttachment:attachment.attachmentGuid];
//            UIAlertView* alert = nil;
//            [WizGlobals showAlertView:NSLocalizedString(@"Sync attachments", nil) 
//                              message:NSLocalizedString(@"Please wait while downloading attachment...!", nil) 
//                             delegate:self 
//                              retView:&alert];
//            self.waitAlert = alert;
//            [alert show];
//        }
    }
    
}
- (BOOL) checkAttachmentIsThere:(NSString*)attachmentGUID
{
    for (int i = 0; i<[self.attachments count]; i++) {
        WizDocumentAttach* attach = [self.attachments objectAtIndex:i];
        if ([attach.attachmentGuid isEqualToString:attachmentGUID]) {
            return YES;
        }
    }
    return NO;
}
- (void) downloadDone:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSDictionary* ret = [userInfo valueForKey:@"ret"];
    NSString* attachmentGUID = [ret valueForKey:@"document_guid"];
    if ([self checkAttachmentIsThere:attachmentGUID]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.waitAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.waitAlert = nil;
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        WizDocumentAttach* attach = [index attachmentFromGUID:attachmentGUID];
        [self checkAttachment:attach inWiz:willCheckInWiz];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    self.lastIndexPath = indexPath;
    [self checkAttachment:attch inWiz:YES];
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    self.lastIndexPath = indexPath;
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
