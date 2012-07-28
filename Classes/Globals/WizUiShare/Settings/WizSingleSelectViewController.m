//
//  WizSingleSelectViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSingleSelectViewController.h"
#import "NSArray+WizSetting.h"
@interface WizSingleSelectViewController ()
{
    NSArray* valueArray;
    NSIndexPath* lastPath;
}
@property (nonatomic, retain) NSArray* valueArray;
@property (nonatomic, retain) NSIndexPath* lastPath;
@end

@implementation WizSingleSelectViewController
@synthesize valueArray;
@synthesize lastPath;
@synthesize singleSelectDelegate;
- (void) dealloc
{
    [singleSelectDelegate release];
    [valueArray release];
    [lastPath release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) initWithValusAndLastIndex:(NSArray*)array    lastIndex:(NSInteger)index
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.valueArray = array;
        self.lastPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    return [self.valueArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[[UITableViewCell alloc] init] autorelease];
    }
    if (self.lastPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.text = [self.valueArray wizSettingDescriptionAtIndex:indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.lastPath = indexPath;
    [self.singleSelectDelegate didSelectedIndex:indexPath.row];
    [self.tableView reloadData];
}

@end
