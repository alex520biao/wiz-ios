//
//  NSDocumentViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "DocumentViewController.h"
#import "EditDocumentViewController.h"
#import "CommonString.h"

#import "Globals/WizIndex.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizGlobals.h"
#import "TagSelectView.h"
@interface UIWebView(WizUIWebView) 

- (BOOL) containImages;

@end

@implementation UIWebView(WizUIWebView) 


- (BOOL) containImages
{
	NSString* script = @"function containImages() { var images = document.images; return (images && images.length > 0) ? \"1\" : \"0\"; } containImages();";
	//
	NSString* ret = [self stringByEvaluatingJavaScriptFromString:script];
	//
	if (!ret)
		return NO;
	if ([ret isEqualToString:@"1"])
		return YES;
	if ([ret isEqualToString:@"0"])
		return NO;
	
	//
	return NO;
}

- (NSString*) bodyText
{
	//NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return body.innerHTML.replace(/\\&lt;br\\&gt;/gi,\"\\n\").replace(/(&lt;([^&gt;]+)&gt;)/gi, \"\"); } getBodyText();";
	NSString* script = @"function getBodyText() { var body = document.body; if (!body) return ""; if (body.innerText) return body.innerText;  return \"\"; } getBodyText();";
	//
	NSMutableString* ret = [NSMutableString stringWithString: [self stringByEvaluatingJavaScriptFromString:script]];
	if (!ret)
		return [NSString stringWithString: @""];
	//
	/*
	while ([ret rangeOfString:@"\n\n"].location != NSNotFound)
	{
		[ret replaceOccurrencesOfString:@"\n\n" withString:@"\n" options:0 range:NSMakeRange(0, [ret length])];
	}
	*/
	
	//
	return ret;
}


@end



@implementation DocumentViewController

@synthesize web;
@synthesize accountUserId;
@synthesize doc;
//wiz-dzpqzb test
-(void) addTags
{
    TagSelectView* tags = [[TagSelectView alloc] initWithStyle:UITableViewStyleGrouped];
    tags.accountUserId = self.accountUserId;
    [self.navigationController pushViewController:tags animated:YES];
    [tags release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	//
    
    
    NSString* documentFileName = [WizIndex documentFileName:self.accountUserId documentGUID:self.doc.guid];
	//
	NSURL* url = [[NSURL alloc] initFileURLWithPath:documentFileName];
	NSURLRequest* req = [[NSURLRequest alloc] initWithURL:url];
	[self.web loadRequest:req];
	[req release];
	[url release];
	//
	self.doc = [[[WizGlobalData sharedData] indexData:self.accountUserId] documentFromGUID:doc.guid];
	self.title = self.doc.title;
    

	//
	NSString* title = NSLocalizedString(@"Edit", nil);
	//wiz-dzpqzb test
	UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleDone target:self action:@selector(addTags)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
	//
	if (WizDeviceIsPad())
	{
		UIBarButtonItem* homeButton = [[UIBarButtonItem alloc] initWithTitle:WizStrHome style:UIBarButtonItemStyleDone target:self action:@selector(backToHome:)];
		self.navigationItem.leftBarButtonItem = homeButton;
		[homeButton release];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	
	
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.web = nil;
}


- (void)dealloc {
    [super dealloc];
}

- (void) editCurrentDocument
{
	NSString* text = [web bodyText];
	//
	EditDocumentViewController* editView = [[EditDocumentViewController alloc] init];
	//
	editView.accountUserId = self.accountUserId;
	editView.doc = self.doc;
	editView.text = text;
	//
	[self.navigationController pushViewController:editView animated:YES];
	//
	[editView release];
}

- (IBAction) editDocument: (id)sender
{
	BOOL b = [web containImages];
	//
	if (b || ![self.doc.type isEqualToString:@"note"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Edit Document", nil) 
														message:NSLocalizedString(@"If you choose to edit this document, images and text-formatting will be lost.", nil) 
													   delegate:self 
											  cancelButtonTitle:nil 
											  otherButtonTitles:NSLocalizedString(@"Continue Editing", nil),WizStrCancel, nil];
		
		[alert show];
		[alert release];
	}
	else 
	{
		[self editCurrentDocument];
	}
}

- (IBAction) backToHome: (id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 ) //Edit
	{
		[self editCurrentDocument];
	}
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (WizDeviceIsPad())
		return YES;
	return NO;
}



@end
