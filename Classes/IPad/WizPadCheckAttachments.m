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
@implementation WizPadCheckAttachments
@synthesize source;

- (void) dealloc
{
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
    NSString* filePath = [self.source objectAtIndex:indexPath.row];
    cell.imageView.image = [WizGlobals attachmentNotationImage:[filePath fileType]];
    cell.textLabel.text = [filePath fileName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[self.source objectAtIndex:indexPath.row] forKey:TypeOfAttachmentFilePath];
        [[WizFileManager shareManager] removeItemAtPath:[self.source objectAtIndex:indexPath.row] error:nil];
        [self.source removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIWebView* webview = [[UIWebView alloc] init];
    NSURL* url = [[NSURL alloc] initFileURLWithPath:[self.source objectAtIndex:indexPath.row]];
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
