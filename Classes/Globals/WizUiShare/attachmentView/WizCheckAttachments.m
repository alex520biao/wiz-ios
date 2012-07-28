//
//  WizCheckAttachments.m
//  Wiz
//
//  Created by wiz on 12-2-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizCheckAttachments.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizDownloadObject.h"
#import "WizCheckAttachment.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"
#import "WizNotification.h"
#import "WizSyncManager.h"
#import "ATMHud.h"
#import "ATMHudDelegate.h"
@interface WizCheckAttachments () <ATMHudDelegate>
{
    NSMutableArray* attachments;
    UIAlertView* waitAlert;
    NSIndexPath* lastIndexPath;
    UIDocumentInteractionController* currentPreview;
    BOOL willCheckInWiz;
    ATMHud* downloadActivity;
}
@property (nonatomic, retain) NSMutableArray* attachments;
@property (nonatomic, retain) UIAlertView* waitAlert;
@property (nonatomic, retain) NSIndexPath* lastIndexPath;
@property (nonatomic, retain) UIDocumentInteractionController* currentPreview;
- (void) downloadDone:(NSNotification*)nc;
@end

@implementation WizCheckAttachments

@synthesize doc;
@synthesize attachments;
@synthesize waitAlert;
@synthesize lastIndexPath;
@synthesize currentPreview;
@synthesize checkAttachmentDelegate;
- (void) dealloc
{
    [currentPreview release];
    [lastIndexPath release];
    [doc release];
    [attachments release];
    [waitAlert release];
    [downloadActivity release];
    downloadActivity = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        attachments = [[NSMutableArray alloc] init];
        currentPreview = [[UIDocumentInteractionController alloc] init];
        currentPreview.delegate = self;
        downloadActivity = [[ATMHud alloc] initWithDelegate:self];
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

- (void) userDidTapHud:(ATMHud *)_hud
{
    [_hud hide];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:downloadActivity.view];
    self.lastIndexPath = nil;
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
    self.attachments = [NSMutableArray arrayWithArray:[self.doc attachments]];
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
    [WizNotificationCenter removeObserverForDownloadDone:self];
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
- (NSURL*) getAttachmentFileURL:(WizAttachment*)attachment
{
    NSString* attachmentFilePath = [attachment attachmentFilePath];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:attachmentFilePath];
    return [url autorelease];
}
- (BOOL) checkCanOpenInOtherApp:(WizAttachment*)attach
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
    WizAttachment* attach = [self.attachments objectAtIndex:indexPath.row];
    if (attach.type == nil || [attach.type isEqualToString:@""]) {
        attach.type = @"noneType";
    }
    if (attach.serverChanged) {
        cell.detailTextLabel.text = NSLocalizedString(@"Tap to download", nil);
    }
    else 
    {
        cell.detailTextLabel.text = NSLocalizedString(@"Tap to view", nil);
    }
    if ([WizGlobals checkAttachmentTypeIsAudio:attach.type]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_video_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsPPT:attach.type])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_ppt_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsWord:attach.type])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_word_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsExcel:attach.type])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_excel_img"];
    }
    else if ([WizGlobals checkAttachmentTypeIsImage:attach.type])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_image_img"];
    }
    else 
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_file_img"];
    }
    cell.textLabel.text = attach.title;
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}
- (void) checkInWiz:(WizAttachment*)attachment
{

    WizCheckAttachment* check = [[WizCheckAttachment alloc] initWithNibName:nil bundle:nil];;
    NSURL* url = [self getAttachmentFileURL:attachment];
    NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
    check.req = req;
    [req release];
    if ([WizGlobals WizDeviceIsPad]) {
        [self.checkAttachmentDelegate didPushCheckAttachmentViewController:check];
    }
    else {
        [self.navigationController pushViewController:check animated:YES];
    }
    [check release];
}
- (void) checkInOtherApp:(WizAttachment*)attachment
{
    NSURL* url = [self getAttachmentFileURL:attachment];
    [currentPreview setURL:url];
    CGRect nav = CGRectMake(0.0, 40*(lastIndexPath.row+1), 320, 40);
    if (![currentPreview presentOptionsMenuFromRect:nav inView:self.view  animated:YES]) {
        [WizGlobals reportWarningWithString:NSLocalizedString(@"There is no application can open this file.", nil)];
    }
}
-(void) checkAttachment:(WizAttachment*) attachment inWiz:(BOOL)inWiz
{
    if (!attachment.serverChanged) {
        if (inWiz) {
            [self checkInWiz:attachment];
        }
        else {
            [self checkInOtherApp:attachment];
        }
        
    }
    else
    {
        willCheckInWiz = inWiz;
        [attachment download];
        [WizNotificationCenter addObserverForDownloadDone:self selector:@selector(downloadDone:)];
        [downloadActivity show];
        [downloadActivity setActivity:YES];
    }
    
}
- (BOOL) checkAttachmentIsThere:(NSString*)attachmentGUID
{
    for (int i = 0; i<[self.attachments count]; i++) {
        WizAttachment* attach = [self.attachments objectAtIndex:i];
        if ([attach.guid isEqualToString:attachmentGUID]) {
            return YES;
        }
    }
    return NO;
}

- (void) downloadDone:(NSNotification*)nc
{
    NSString* guid = [WizNotificationCenter downloadGuidFromNc:nc];
    if (guid == nil) {
        return;
    }
    WizAttachment* attachment = [self.attachments objectAtIndex:self.lastIndexPath.row];
    if ([guid isEqualToString:attachment.guid]) {
        attachment.serverChanged = NO;
        [self checkAttachment:attachment inWiz:willCheckInWiz];
        [self.waitAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.waitAlert = nil;
    }
    [downloadActivity hide];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizAttachment* attch = [self.attachments objectAtIndex:indexPath.row];
    self.lastIndexPath = indexPath;
    [self checkAttachment:attch inWiz:YES];
}
- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    WizAttachment* attch = [self.attachments objectAtIndex:indexPath.row];
    self.lastIndexPath = indexPath;
    [self checkAttachment:attch inWiz:NO];
}
@end
