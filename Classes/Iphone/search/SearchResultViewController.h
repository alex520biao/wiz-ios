//
//  SearchResultViewController.h
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DocumentListViewControllerBaseNew.h"

@interface SearchResultViewController : DocumentListViewControllerBaseNew {
	NSArray* searchResult;
	
}
@property (nonatomic, retain) NSArray* searchResult;

@end
