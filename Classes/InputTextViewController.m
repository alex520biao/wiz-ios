//
//  InputTextViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/12/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "InputTextViewController.h"
#import "CommonString.h"

#import "Globals/WizGlobals.h"


@implementation InputTextViewController

@synthesize description;
@synthesize delegate;
@synthesize textField;
@synthesize labelDescription;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	//
	[super viewDidLoad];
	//
	self.labelDescription.text = self.description;
	//
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	//
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:WizStrSave style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	//
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
	self.textField = nil;
	self.labelDescription = nil;
}


- (void)dealloc {
	self.description = nil;
	self.delegate = nil;
    [super dealloc];
}


- (IBAction) cancel: (id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}
- (IBAction) save: (id)sender
{
	NSString* text = self.textField.text;
	//
	if (text == nil|| [text length] == 0)
	{
		[WizGlobals reportErrorWithString:NSLocalizedString(@"Please enter some text!", nil)];
		return;
	}
	//
	if ([self.delegate respondsToSelector: @selector(inputTextDone:text:)])
	{
		if (![self.delegate inputTextDone:self text:text])
			return;
		//
		[self cancel:nil];
	}
}


+ (void) inputText: (UINavigationController*)nav title:(NSString*)title description: (NSString*) description delegate: (id)callback
{
	InputTextViewController* view = [[InputTextViewController alloc] initWithNibName:@"InputTextViewController" bundle:nil];
	//
	view.title = title;
	view.description = description;
	view.delegate = callback;
	//
	[nav pushViewController: view animated:YES];
	[view release];
}


@end
