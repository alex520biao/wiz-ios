//
//  FolderViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/13/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentListViewControllerBase.h"

@class WizDocument;

@interface FolderViewController : DocumentListViewControllerBase {
	NSString* location;
}

@property (nonatomic, retain) NSString* location;

@end
