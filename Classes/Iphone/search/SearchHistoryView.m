//
//  SearchHistoryView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-7.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchHistoryView.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "CommonString.h"
#import "SearchResultViewController.h"
#import "SearchViewControllerIphone.h"
#import "WizAccountManager.h"
@implementation SearchHistoryView
@synthesize history;
@synthesize owner;
- (void) dealloc
{
    [history release];
    [owner release];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) reloadData
{
    NSString* objectPath = [WizIndex documentFilePath:[[WizAccountManager defaultManager] activeAccountUserId] documentGUID:@"SearchHistoryDir"];
    [WizGlobals ensurePathExists:objectPath];
    NSString* fileNamePath = [objectPath stringByAppendingPathComponent:@"history.dat"];
    NSMutableArray* historyy = [NSMutableArray arrayWithContentsOfFile:fileNamePath];
    self.history = historyy;
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.history removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    NSString* objectPath = [WizIndex documentFilePath:[[WizAccountManager defaultManager] activeAccountUserId] documentGUID:@"SearchHistoryDir"];
    [WizGlobals ensurePathExists:objectPath];
    NSString* fileNamePath = [objectPath stringByAppendingPathComponent:@"history.dat"];
    [self.history writeToFile:fileNamePath atomically:NO];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self reloadData];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[self.history count]])];
    UIImageView* searchFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchTableFooter"]];
    [footerView addSubview:searchFooter];
    self.tableView.tableFooterView = footerView;
    footerView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    [searchFooter release];
    [footerView release];
    
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(90, 7, 210, 100)];
    remind.text = NSLocalizedString(@"Tap the field above to search your notes. Tap a recent or saved search to view the results of that search.", nil);
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [searchFooter addSubview:remind];
    [remind release];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.history count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString* key = [[self.history objectAtIndex:indexPath.row] objectForKey:@"key_words"];
    NSNumber* count = [[self.history objectAtIndex:indexPath.row] objectForKey:@"count"];
    cell.textLabel.text = key;
    if (count == nil) {
        count = [NSNumber numberWithInt:0];
    }
    NSString* detailString = [NSString stringWithFormat:NSLocalizedString(@"find %d notes", nil),[count intValue]];
    cell.detailTextLabel.text = detailString;
    cell.imageView.image = [UIImage imageNamed:@"searchIcon"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* keywords = [[self.history objectAtIndex:indexPath.row] objectForKey:@"key_words"];
	if (keywords == nil || [keywords length] == 0)
		return;
	//
	WizIndex* index = [WizIndex activeIndex];
	NSArray* arr = [index documentsByKey:keywords];
	//
	if (arr == nil || [arr count] == 0)
	{
		NSString* formatter = NSLocalizedString(@"Cannot find %@", nil);
		NSString* msg = [NSString stringWithFormat:formatter, keywords];
		//
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    
    SearchResultViewController* searchResultView = [[SearchResultViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultView.searchResult = arr;
    SearchViewControllerIphone* parent = (SearchViewControllerIphone*)self.owner;
    [parent.navigationController pushViewController:searchResultView animated:YES];
    [searchResultView release];
}

@end
