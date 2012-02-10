//
//  NSDocumentViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/15/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WizDocument;

@interface DocumentViewController : UIViewController {
	UIWebView* web;
	//
	NSString* accountUserId;
	WizDocument* doc;
}

@property (nonatomic, retain) IBOutlet UIWebView* web;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) WizDocument* doc;


- (IBAction) editDocument: (id)sender;
- (IBAction) backToHome: (id)sender;

@end
