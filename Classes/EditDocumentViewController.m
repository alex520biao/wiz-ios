//
//  EditDocumentViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/21/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "EditDocumentViewController.h"

#import "Globals/WizIndex.h"
#import "Globals/WizGlobalData.h"


@implementation EditDocumentViewController

@synthesize doc;
@synthesize text;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	//
	self.editTitleView.text = doc.title;
	self.editView.text = self.text;
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
}


- (void)dealloc {
    [super dealloc];
}



- (IBAction) cancel: (id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


- (IBAction) save: (id)sender
{
	NSString* t = self.editView.text;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	[index editDocument:doc.guid documentText:t documentTitle:self.editTitleView.text];
	//
	[self cancel:nil];
}



@end
