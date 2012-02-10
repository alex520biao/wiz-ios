//
//  TextEditViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/21/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TextEditViewController : UIViewController {
	NSString* accountUserId;
	//
	UITextField* editTitleView;
	UITextView* editView;
	//
	UIImageView* imageView;
	//
	UIButton* addImageButton;
}
@property (nonatomic, retain) NSString* accountUserId;
//
@property (nonatomic, retain) UITextField* editTitleView;
@property (nonatomic, retain) UITextView* editView;
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UIButton* addImageButton;

- (IBAction) save:(id)sender;
- (IBAction) cancel:(id)sender;
- (IBAction) addImage:(id)sender;
- (IBAction) textFieldDoneEditing: (id)sender;

- (NSString*) saveButtonText; 

- (BOOL) shouldShowImage;
- (void) setImage:(UIImage*)img;

@end
