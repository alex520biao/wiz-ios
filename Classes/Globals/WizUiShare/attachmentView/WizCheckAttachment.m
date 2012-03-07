//
//  WizCheckAttachment.m
//  Wiz
//
//  Created by wiz on 12-3-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizCheckAttachment.h"

@interface WizCheckAttachment ()

@end

@implementation WizCheckAttachment
@synthesize webView;
@synthesize req;
- (void) dealloc
{
    self.req = nil;
    self.webView = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) cancel
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIWebView* webview_ = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    webview_.multipleTouchEnabled = YES;
    webview_.scalesPageToFit = YES;
    webview_.userInteractionEnabled = YES;
    [self.view addSubview:webview_];
    self.webView = webview_;
    [webview_ release];
    
    UIBarButtonItem* returnBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = returnBar;
    [returnBar release];
    // Do any additional setup after loading the view from its nib.
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
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:self.req];
}

@end
