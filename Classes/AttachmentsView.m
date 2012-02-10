//
//  AttachmentsView.m
//  Wiz
//
//  Created by dong zhao on 11-11-18.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "AttachmentsView.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizDownloadObject.h"
#import "ScrollTableViewCell.h"
#import "PlayAudioAttachmentCell.h"
#import "WizGlobals.h"
#import "AttachmentImageViewController.h"
@implementation AttachmentsView
@synthesize accountUserId;
@synthesize docGuid;
@synthesize attachmentsAraay;
@synthesize lastIndexPath;
@synthesize isPlayingAudio;
@synthesize waitAlertView;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.accountUserId = nil;
    self.docGuid = nil;
    self.attachmentsAraay = nil;
    self.lastIndexPath = nil;
    self.waitAlertView = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle
-(void) toggleEdit
{
    [self.tableView setEditing:!self.tableView.editing animated:YES];
    
    if(self.tableView.editing)
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
    else
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    self.attachmentsAraay = [[[index attachmentsByDocumentGUID:self.docGuid] mutableCopy] autorelease];
    
    self.lastIndexPath = [NSIndexPath  indexPathForRow:-1 inSection:-1] ;
    self.isPlayingAudio = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.attachmentsAraay count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WizDocumentAttach* attach = [self.attachmentsAraay objectAtIndex:indexPath.row];
    if (self.isPlayingAudio && indexPath.row == self.lastIndexPath.row) {
        NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attach.attachmentGuid];
        [WizGlobals ensurePathExists:objectPath];
        NSString* fileNamePath = [objectPath stringByAppendingPathComponent:attach.attachmentName];
        PlayAudioAttachmentCell* newCell=[[[PlayAudioAttachmentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] autorelease];
        newCell.audioFilePath = fileNamePath;
        newCell.attachmentNameLabel.text = attach.attachmentName;
        newCell.owner = self;
        [newCell prepareForPlay];
        self.isPlayingAudio = !self.isPlayingAudio;
        return newCell;
    }
    
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil || [cell isKindOfClass:[PlayAudioAttachmentCell class]]) {
        cell = nil;
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    if ([WizGlobals checkAttachmentTypeIsAudio:attach.attachmentType]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_video_img"];
    }
    else  if ([WizGlobals checkAttachmentTypeIsImage:attach.attachmentType])
    {
        cell.imageView.image = [UIImage imageNamed:@"icon_image_img"];
    }
    cell.textLabel.text = attach.attachmentName;
    cell.detailTextLabel.text = [attach attachmentModifiedDate];
    
    return cell;
}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attach = [self.attachmentsAraay objectAtIndex:indexPath.row];
    WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
    [index deleteAttachment:attach.attachmentGuid];
    [index addDeletedGUIDRecord:attach.attachmentGuid type:@"attachment"];
    [self.attachmentsAraay removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]withRowAnimation:YES];
}


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

- (void) checkAttachment:(WizDocumentAttach*) attach
{
    if ([WizGlobals checkAttachmentTypeIsAudio:attach.attachmentType]) {
        self.isPlayingAudio = YES;
        [self.tableView reloadData];
    }
    else if([WizGlobals checkAttachmentTypeIsImage:attach.attachmentType])
    {
        NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attach.attachmentGuid];
        [WizGlobals ensurePathExists:objectPath];
        NSString* fileNamePath = [objectPath stringByAppendingPathComponent:attach.attachmentName];
        AttachmentImageViewController* checkImage = [[AttachmentImageViewController alloc] init];
        NSURL* url = [[NSURL alloc] initFileURLWithPath:fileNamePath];
        checkImage.url = url;
        [self.navigationController pushViewController:checkImage animated:YES];
        [url release];
        [checkImage release];
    }
}



- (void) downloadingAttachment:(NSNotification*) nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* methodName = [userInfo objectForKey:@"sync_method_name"];
    NSNumber* total = [userInfo objectForKey:@"sync_method_total"];
    NSNumber* current = [userInfo objectForKey:@"sync_method_current"];
    if (![methodName isEqualToString:SyncMethod_DownloadObject]) {
        return;
    }
    

    
    if ([total isEqualToNumber:current]) {
       
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        [index setAttachmentServerChanged:[[self.attachmentsAraay objectAtIndex:self.lastIndexPath.row] attachmentGuid] changed:NO];
        [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
        self.waitAlertView = nil;
        [self checkAttachment:[self.attachmentsAraay objectAtIndex:self.lastIndexPath.row]];
    }
    
    

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocumentAttach* attach = [self.attachmentsAraay objectAtIndex:indexPath.row];
    self.lastIndexPath = indexPath;
    if([index attachmentSeverChanged:attach.attachmentGuid])
    {
        WizDownloadAttachment* downloader = [[WizGlobalData sharedData] downloadAttachmentData:self.accountUserId];
        downloader.owner = self;
        [downloader downloadAttachment:attach.attachmentGuid];
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(downloadingAttachment:) name:[downloader notificationName:WizGlobalSyncProcessInfo] object:nil];
        UIAlertView* alert = nil;
         [WizGlobals showAlertView:NSLocalizedString(@"Downloading Attachment", nil) message:NSLocalizedString(@"Please wait while Downloading Attachment...!", nil) delegate:self retView:&alert];
         [alert show];
         //
         self.waitAlertView = alert;
        
        [alert release];
        return;
    }
    [self checkAttachment:attach];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42;
}
- (void) audioPlayStop
{
    NSIndexPath* old = self.lastIndexPath;
    [self.tableView beginUpdates];
    self.isPlayingAudio = NO;
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:old] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
}

@end
