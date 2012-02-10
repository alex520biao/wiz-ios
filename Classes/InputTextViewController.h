//
//  InputTextViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/12/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InputTextViewController : UIViewController {
	NSString* description;
	//
	UITextField* textField;
	UILabel* labelDescription;
	//
	id delegate;
}

@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) id delegate;

@property (nonatomic, retain) IBOutlet UITextField* textField;
@property (nonatomic, retain) IBOutlet UILabel* labelDescription;

- (IBAction) cancel: (id)sender;
- (IBAction) save: (id)sender;


+ (void) inputText: (UINavigationController*)nav title:(NSString*)title description: (NSString*) description delegate: (id)callback;


@end

@interface NSObject (InputTextViewDelegate)

- (BOOL)inputTextDone: (InputTextViewController *)sender text: (NSString*)text;

@end
