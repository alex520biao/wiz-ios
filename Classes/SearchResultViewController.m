//
//  SearchResultViewController.m
//  Wiz
//
//  Created by Wei Shijun on 4/5/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "SearchResultViewController.h"
#import "DocumentListViewControllerBaseNew.h"
@implementation SearchResultViewController

@synthesize searchResult;

- (void) reloadDocuments
{
    self.sourceArray = [NSMutableArray arrayWithArray:self.searchResult];
}

- (BOOL) isBusy
{
	return YES;
}

 -(BOOL) canSync
{
	return NO;
}

- (NSString*) titleForView
{
	return [NSString stringWithString:NSLocalizedString(@"Search Resault", nil)];
}
- (void)addPullToRefreshHeader {
}

- (void) syncDocuments
{
}

- (NSString*) syncDocumentsXmlRpcMethod
{
    return @"";
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

@end
