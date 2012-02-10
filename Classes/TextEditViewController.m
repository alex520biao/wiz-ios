//
//  TextEditViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/21/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "TextEditViewController.h"
#import "CommonString.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizGlobals.h"



@implementation TextEditViewController

@synthesize accountUserId;

@synthesize editTitleView;
@synthesize editView;
@synthesize imageView;
@synthesize addImageButton;


- (void)updateLayout:(int)keyboardHeight
{
	if (self.editView == nil)
		return;
	if (self.editTitleView == nil)
		return;
	if (self.imageView == nil)
		return;
	if (self.addImageButton == nil)
		return;
	//
	CGRect rc = self.view.frame;
	//
	int imageHeight = rc.size.height / 4;
	BOOL showImage = [self shouldShowImage];
	if (!showImage)
	{
		imageHeight = 0;
	}
	//
	int bottomHeight = imageHeight;
	if (keyboardHeight > bottomHeight)
	{
		bottomHeight = keyboardHeight;
	}
	//
	//
	float fontSize = [UIFont labelFontSize];
	
	//
	int titleHeight = fontSize + 16;
	int addImageButtonWidth = titleHeight + 8;
	//
	CGRect rcTitle = CGRectMake(0, 0, rc.size.width,  titleHeight);
	CGRect rcEdit = CGRectMake(0, rcTitle.size.height, rc.size.width,  rc.size.height - rcTitle.size.height - bottomHeight);
	CGRect rcImage =CGRectMake(0, rcEdit.origin.y + rcEdit.size.height , rc.size.width,  bottomHeight); 
	CGRect rcAddImage = CGRectMake(rc.size.width - addImageButtonWidth, 0 , addImageButtonWidth,  titleHeight); 
	//
	if (showImage)
	{
		rcTitle.size.width -= addImageButtonWidth;
	}
	else 
	{
		self.addImageButton.hidden = YES;
	}

	//
	self.editView.frame = rcEdit;
	self.editTitleView.frame = rcTitle;
	self.imageView.frame = rcImage;
	self.addImageButton.frame = rcAddImage;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	[super viewDidLoad];
	//
	CGRect rc = CGRectMake(0, 0, 100,  100);
	float fontSize = [UIFont labelFontSize];
	//
	UITextField* editTitle = [[UITextField alloc] initWithFrame:rc];
	editTitle.borderStyle = UITextBorderStyleRoundedRect;
	editTitle.font = [UIFont boldSystemFontOfSize: fontSize];
	editTitle.returnKeyType = UIReturnKeyDone;
	[editTitle setPlaceholder:NSLocalizedString(@"Title", nil)];
	[self.view addSubview:editTitle];
	[editTitle addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
	self.editTitleView = editTitle;
	[editTitle release];

	UITextView* edit = [[UITextView alloc] initWithFrame:rc];
	edit.font = [UIFont systemFontOfSize: fontSize];
	edit.returnKeyType = UIReturnKeyDefault;
	[self.view addSubview:edit];
	self.editView = edit;
	[edit release];
	
	UIImageView* img = [[UIImageView alloc] initWithFrame:rc];
	img.contentMode = UIViewContentModeScaleAspectFit;
	img.backgroundColor = [UIColor lightGrayColor];
	[self.view addSubview:img];
	self.imageView = img;
	[img release];
	//
	UIButton* addImg = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[self.view addSubview:addImg];
	[addImg addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
	self.addImageButton = addImg;
	//
	[self updateLayout:0];
	//
	UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithTitle:WizStrCancel style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	[cancelButton release];
	//
	UIBarButtonItem* saveButton = [[UIBarButtonItem alloc] initWithTitle:[self saveButtonText] style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];
	//
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	//
}

- (NSString*) saveButtonText
{
	return WizStrSave;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	//
	[self updateLayout:0];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];

	self.editView = nil;
	self.editTitleView = nil;
	self.imageView = nil;
	self.addImageButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
	// Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
	[self updateLayout:keyboardRect.size.height];
	
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
	[self updateLayout:0];
    //
    [UIView commitAnimations];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self updateLayout:0];
}


- (void)dealloc 
{
    [super dealloc];
}


- (IBAction) addImage:(id)sender
{
//	[editTitleView resignFirstResponder];
//	[editView resignFirstResponder];
//	//
//	CameraViewController* addImage = [[CameraViewController alloc] init];
//	addImage.textEditViewController = self;
//	//
//	UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:addImage];
//	modalNavigationController.modalPresentationStyle = UIModalPresentationFullScreen;
//    
//	[self presentModalViewController:modalNavigationController animated:YES];
//	[modalNavigationController release];
//	
//	[addImage release];
}


- (IBAction) textFieldDoneEditing: (id)sender
{
	[sender resignFirstResponder];
}

- (IBAction) cancel: (id)sender
{
	if (WizDeviceIsPad())
	{
		[self dismissModalViewControllerAnimated:YES];
	}
	else
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
}
- (IBAction) save: (id)sender
{
	[self cancel:nil];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	if (WizDeviceIsPad())
		return YES;
	return NO;
}

- (BOOL) shouldShowImage
{
	return NO;
}
- (void) setImage:(UIImage*)img
{
	self.imageView.image = img;
}

@end
