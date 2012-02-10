//
//  NewNoteViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/16/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TextEditViewController.h"

@interface NewNoteViewController : TextEditViewController 
{
	NSString* location;
}

@property (nonatomic, retain) NSString* location;

@end
