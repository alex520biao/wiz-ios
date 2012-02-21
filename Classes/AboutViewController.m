//
//  AboutViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/18/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "AboutViewController.h"


@interface AboutViewController ( privates )

-(void) loadWebView;

@end
@implementation AboutViewController

@synthesize webView;


- (void)viewWillAppear:(BOOL)animated
{
	
	self.navigationController.navigationBarHidden= NO;
	self.title = NSLocalizedString(@"About WizNote", nil);
	
	[super viewWillAppear:animated];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	return YES;
}

//If you need to do additional setup after loading the view, override viewDidLoad.
- (void)viewDidLoad
{

	[super viewDidLoad];
	[self loadWebView];
	
}

-(void) loadWebView 
{
	NSString *version  = [[[NSBundle mainBundle] infoDictionary] valueForKey:[NSString stringWithFormat:@"CFBundleVersion"]];
	[webView loadHTMLString:[NSString stringWithFormat:@"<font face=\"Helvetica\"> <p style=\"color:rgb(51,51,51);padding-top:8px;\"><br><br><br><br><br><br><br><br><br><br><b style=\"font-size:18px;\">Wiz for iPhone/iPad</b><br>Version %@<br><br></font>",version] baseURL:nil];
	[webView setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

	
}


- (void)dealloc
{
    self.webView = nil;
    [super dealloc];
}


@end
