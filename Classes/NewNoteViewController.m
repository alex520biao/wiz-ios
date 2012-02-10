//
//  NewNoteViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "NewNoteViewController.h"

#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizGlobals.h"

@implementation NewNoteViewController

@synthesize location;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	self.title = NSLocalizedString(@"New Note", nil);
	//
	[super viewDidLoad];
}

- (IBAction) save: (id)sender
{
	WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
	//
	NSString* title = self.editTitleView.text;
	NSString* text = self.editView.text;
	UIImage* img = self.imageView.image;
	if (img)
	{
		[index newPhoto:img title:title text:text location:self.location];
	}
	else 
	{
		[index newNote:title text:text location:self.location];
	}

	[self cancel:nil];
}

- (BOOL) shouldShowImage
{
	return YES;
}

@end
