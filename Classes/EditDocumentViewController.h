//
//  EditDocumentViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/21/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TextEditViewController.h"

@class WizDocument;

@interface EditDocumentViewController : TextEditViewController {
	WizDocument* doc;
	NSString* text;
}

@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, retain) NSString* text;

@end
