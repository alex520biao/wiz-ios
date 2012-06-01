//
//  WizPadCatelogViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadCatelogViewController.h"

@interface WizPadCatelogViewController ()
{
    NSMutableArray* dataArray;
    UIInterfaceOrientation willInterfaceOrientation;
}
@end

@implementation WizPadCatelogViewController
@synthesize checkDelegate;
- (void) dealloc
{
    [dataArray release];
    dataArray = nil;
    checkDelegate = nil;
    [super dealloc];
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        dataArray = [[NSMutableArray alloc] init];
        self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return self;
}

- (NSArray*) catelogDataSourceArray
{
    return nil;
}
- (void) reloadAllData
{
    self.tableView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [dataArray removeAllObjects];
    [dataArray addObjectsFromArray:[self catelogDataSourceArray]];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    willInterfaceOrientation = self.interfaceOrientation;
    [self reloadAllData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (UIInterfaceOrientationIsLandscape(willInterfaceOrientation)) {
        count = 4;
    }
    else
    {
        count = 3;
    }
    NSLog(@"count is %d",count);
    NSLog(@"%d remind %d",[dataArray count],[dataArray count]%count);
    if ([dataArray  count]%count>0) {
        return  [dataArray count]/count+1;
    }
    else {
        return [dataArray count]/count  ;
    }
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    willInterfaceOrientation = toInterfaceOrientation;
    [self.tableView reloadData];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    CatelogCell *cell = (CatelogCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (nil == cell) {
        cell = [[[CatelogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withDelegate:self] autorelease];
    }
    NSInteger documentsCount =0;
    if (UIInterfaceOrientationIsLandscape(willInterfaceOrientation)) {
        documentsCount = 4;
    }
    else
    {
        documentsCount = 3;
    }
    NSUInteger needLength = documentsCount*(indexPath.row+1);
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([dataArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, [dataArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    NSLog(@"index ");
    cellArray = [dataArray subarrayWithRange:docRange];
    [cell setCatelogViewContents:cellArray];
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}
@end
