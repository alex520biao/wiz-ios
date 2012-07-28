//
//  WizPadDocumentListController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentListController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
@implementation WizRange
@synthesize start;
@synthesize end;
@end

@implementation WizPadDocumentListController
@synthesize listType;
@synthesize tableOrientation;
- (void) dealloc
{
    [super dealloc];
}

- (void) reloadDocuments
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.sourceArray = [[[index recentDocuments] mutableCopy] autorelease];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}
- (void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) halfOrdered:(NSUInteger)start end:(NSUInteger)end rangeArray:(NSArray*)rangeArray
{
    
}

- (void) dateOrdered
{
    NSMutableArray* rangeArray = [NSMutableArray arrayWithCapacity:5];
    for (int i = 0; i<5; i++) {
        WizRange* range = [[WizRange alloc] init];
        range.start = -1;
        range.end = -1;
        [rangeArray addObject:range];
        [range release];
    }
    
}
- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([WizGlobals DeviceIsPad]) {
        NSLog(@"ddd");
    }
    else {
        NSLog(@"xxxxx");
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
