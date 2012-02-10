//
//  CatelogBaseController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogBaseController.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "CatelogBaseCell.h"
@implementation WizPadCatelogData
@synthesize name;
@synthesize count;
@synthesize abstract;
@synthesize keyWords;
@end

@implementation CatelogBaseController
@synthesize landscapeContentArray;
@synthesize portraitContentArray;
@synthesize accountUserId;
@synthesize willToOrientation;
- (void) dealloc{
    self.accountUserId = nil;
    self.landscapeContentArray = nil;
    self.portraitContentArray = nil;
    [super dealloc];
}

- (NSArray*) arrayToLoanscapeCellArray:(NSArray*)source
{
    int documentCount = [source count];
    NSMutableArray* retArray = [NSMutableArray array];
    for (int docIndex = 0; docIndex < documentCount; ) {
        NSMutableArray* cellArray = [NSMutableArray array];
        for (int i =docIndex; i < documentCount; i++) {
            if ([cellArray count] == 4) {
                [retArray addObject:cellArray];
                docIndex = i;
                break;
            } else if (i == documentCount -1)
            {
                [cellArray addObject:[source objectAtIndex:i]];
                [retArray addObject:cellArray];
                docIndex = i+1;
                break;
            }
            [cellArray addObject:[source objectAtIndex:i]];
        }
    }
    return retArray;
}

- (NSArray*) arrayToPotraitCellArraty:(NSArray*)source
{
    int documentCount = [source count];
    NSMutableArray* retArray = [NSMutableArray array];
    for (int docIndex = 0; docIndex < documentCount; ) {
        NSMutableArray* cellArray = [NSMutableArray array];
        for (int i =docIndex; i < documentCount; i++) {
            if ([cellArray count] == 3) {
                [retArray addObject:cellArray];
                docIndex = i;
                break;
            } else if (i == documentCount -1)
            {
                [cellArray addObject:[source objectAtIndex:i]];
                [retArray addObject:cellArray];
                docIndex = i+1;
                break;
            }
            [cellArray addObject:[source objectAtIndex:i]];
        }
    }
    return retArray;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) reloadAllData
{
    if (nil == self.landscapeContentArray) {
        self.landscapeContentArray = [NSMutableArray array];
    }
    if (nil == self.portraitContentArray) 
    {
        self.portraitContentArray = [NSMutableArray array];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor grayColor];
    [self reloadAllData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.willToOrientation = toInterfaceOrientation;
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (UIInterfaceOrientationIsLandscape(self.willToOrientation)) {
        return [self.landscapeContentArray count];
    }
    else
    {
        return [self.portraitContentArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CatelogBaseCell *cell = (CatelogBaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CatelogBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accountUserId = self.accountUserId;
        cell.owner = self;

    }
    
    if (UIInterfaceOrientationIsLandscape(self.willToOrientation)) {
        [cell setContent:[self.landscapeContentArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell setContent:[self.portraitContentArray objectAtIndex:indexPath.row]];
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}
@end
