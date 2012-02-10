//
//  TagViewController.h
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DocumentListViewControllerBase.h"

@class WizTag;

@interface TagViewController : DocumentListViewControllerBase {
	WizTag* tag;
}

@property (nonatomic, retain) WizTag* tag;

@end
