//
//  WizPadCheckAttachments.m
//  Wiz
//
//  Created by wiz on 12-2-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadCheckAttachments.h"
#import "WizPadNotificationMessage.h"
#import "WizFileManager.h"
#import "WizDbManager.h"

@implementation WizPadCheckAttachments
@synthesize source;
@synthesize delegate;
- (void) dealloc
{
    delegate = nil;
    [source release];
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
    return [self.source count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    WizAttachment* attach = [self.source objectAtIndex:indexPath.row];
    if (attach.localChanged > 0) {
        cell.textLabel.text = attach.title;
        cell.imageView.image = [WizGlobals attachmentNotationImage:[attach.title fileType]];
    }
    else {
        cell.textLabel.text = [attach.description fileName];
        cell.imageView.image = [WizGlobals attachmentNotationImage:[attach.description fileType]];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WizAttachment* attachment = [self.source objectAtIndex:indexPath.row];
        if (WizAttachmentEditTypeTempChanged == attachment.localChanged) {
            [[WizFileManager shareManager] removeItemAtPath:attachment.description error:nil];
        }
        else {
            [WizAttachment deleteAttachment:attachment.guid];
            [[[WizDbManager shareDbManager] shareDataBase] addDeletedGUIDRecord:attachment.guid type:WizAttachmentKeyString];
        }
        [self.source removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.delegate didRemoveAttachmentsDone];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizAttachment* attachment = [self.source objectAtIndex:indexPath.row];
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
        UIWebView* webview = [[UIWebView alloc] init];
        webview.scalesPageToFit = YES;
        NSURL* url = [[NSURL alloc] initFileURLWithPath:sourceFile];
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
    
}

@end
