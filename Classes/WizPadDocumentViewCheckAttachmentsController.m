//
//  WizPadDocumentViewCheckAttachmentsController.m
//  Wiz
//
//  Created by wiz on 12-2-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentViewCheckAttachmentsController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
@implementation WizPadDocumentViewCheckAttachmentsController

@synthesize documentGUID;
@synthesize accountUserId;
@synthesize attachments;

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
    }
    
    WizDocumentAttach* attach = [self.attachments objectAtIndex:indexPath.row];
    cell.textLabel.text = attach.attachmentName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocumentAttach* attch = [self.attachments objectAtIndex:indexPath.row];
    NSString* attachmentPath = [WizIndex documentFilePath:self.accountUserId documentGUID:attch.attachmentGuid];
    NSString* attachmentFilePath = [attachmentPath stringByAppendingPathComponent:attch.attachmentName];
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

@end
