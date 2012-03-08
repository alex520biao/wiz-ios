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
        UIWebView* web = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768)];
        web.multipleTouchEnabled = YES;
        web.userInteractionEnabled = YES;
        web.scalesPageToFit = YES;
        [self.view addSubview:web];
        self.webView = web;
        [web release];
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

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        self.webView.frame = CGRectMake(0.0, 0.0, 1024, 768);
    }
    else {
        self.webView.frame = CGRectMake(0.0, 0.0, 768, 1024);
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:self.req];
    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        self.webView.frame = CGRectMake(0.0, 0.0, 1024, 768);
    }
    else {
        self.webView.frame = CGRectMake(0.0, 0.0, 768, 1024);
    }
    [self.navigationController setToolbarHidden:YES animated:YES];
}

@end
