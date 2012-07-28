//
//  WizEditorCheckAttachmentViewController.m
//  Wiz
//
//  Created by wiz on 12-7-18.
//
//

#import "WizEditorCheckAttachmentViewController.h"
#import "WizCheckAttachmentViewController.h"
@interface WizEditorCheckAttachmentViewController ()

@end

@implementation WizEditorCheckAttachmentViewController
@synthesize attachmetsSourceDelegate;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.attachmetsSourceDelegate sourceAttachmentsArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizAttachment* attachment = [[self.attachmetsSourceDelegate sourceAttachmentsArray] objectAtIndex:indexPath.row];
    cell.textLabel.text = attachment.title;
    cell.imageView.image = [WizGlobals attachmentNotationImage:[attachment.description fileType]];
    if (attachment.localChanged == WizAttachmentEditTypeNoChanged) {
        if ([WizGlobals checkAttachmentTypeIsImage:[attachment.description fileType]]) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                UIImage* image = [UIImage imageWithContentsOfFile:[attachment attachmentFilePath]];
                if (nil != image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.imageView.image = image;
                    });
                }
            });
        }
    }
    if (attachment.localChanged == WizAttachmentEditTypeNoChanged) {
        if (attachment.serverChanged == 0) {
            cell.detailTextLabel.text = NSLocalizedString(@"Tap to check", nil);
        }
        else
        {
            cell.detailTextLabel.text = NSLocalizedString(@"It is not downloaded.", nil);
        }
    }
    else
    {
        cell.detailTextLabel.text = NSLocalizedString(@"Tap to check", nil);
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        WizAttachment* attachment = [[self.attachmetsSourceDelegate sourceAttachmentsArray] objectAtIndex:indexPath.row];
        [[self.attachmetsSourceDelegate deletedAttachmentsArray] addObject:attachment];
        [[self.attachmetsSourceDelegate sourceAttachmentsArray] removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }    
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizAttachment* attachment = [[self.attachmetsSourceDelegate sourceAttachmentsArray] objectAtIndex:indexPath.row];
    if (YES == attachment.serverChanged) {
        return;
    }
    else {
        NSString* sourceFile = @"";
        if (attachment.localChanged < 0) {
            sourceFile = attachment.description;
        }
        else {
            sourceFile = [attachment attachmentFilePath];
        }
        WizCheckAttachmentViewController* check = [[WizCheckAttachmentViewController alloc] initWithAttachmentPath:sourceFile];
        [self.navigationController pushViewController:check animated:YES];
        [check release];
    }
}

@end
