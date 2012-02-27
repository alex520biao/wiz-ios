//
//  RootViewController.m
//  iPad
//
//  Created by Wei Shijun on 5/19/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "RootViewController.h"
#import "DetailViewController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizSync.h"
#import "CommonString.h"


@implementation RootViewController

@synthesize splitViewController;
@synthesize detailViewController;

@synthesize accountUserId;
@synthesize locations;
@synthesize tags;

@synthesize accountsButton;
@synthesize syncButton;
@synthesize activeButton;


#pragma mark -
#pragma mark View lifecycle

- (void) reloadAllData
{
	self.locations = [[[WizGlobalData sharedData] indexData:accountUserId] allLocationsForTree];
	self.tags = [[[WizGlobalData sharedData] indexData:accountUserId] allTagsForTree];
	
	[self.tableView reloadData];
}

- (void) initAccountsButton
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:WizStrAccounts style:UIBarButtonItemStyleDone target:self action:@selector(onManageAccounts:)];
	self.accountsButton = button;
	[button release];
}


- (void) initSyncButton
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:WizStrSync style:UIBarButtonItemStyleDone target:self action:@selector(onSyncAll:)];
	self.syncButton = button;
	[button release];
}

- (void)initActiveButton
{
	NSAutoreleasePool *apool = [[NSAutoreleasePool alloc] init];
	UIActivityIndicatorView *aiv = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	UIBarButtonItem *activityButtonItem = [[UIBarButtonItem alloc] initWithCustomView:aiv];
	[aiv startAnimating]; 
	[aiv release];
	
	self.activeButton = activityButtonItem;
	[activityButtonItem release];
	[apool release];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	//
	[self.tableView reloadData];
	//
	//
	//
	[self initAccountsButton];
	[self initSyncButton];
	[self initActiveButton];
	
	self.navigationItem.leftBarButtonItem = self.accountsButton;
	self.navigationItem.rightBarButtonItem = self.syncButton;
}


- (IBAction) onManageAccounts: (id)sender
{
}

- (IBAction) onSyncAll: (id)sender
{
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	//
	WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncBegin) name:[sync notificationName:WizSyncBeginNotificationPrefix] object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
	
	[sync startSync];
}

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView 
{
    // Return the number of sections.
    return 3;
}



- (NSString*) tableView: (UITableView *)tableView
titleForHeaderInSection: (NSInteger)section
{
	if (0 == section)
		return NSLocalizedString(@"Favorites", nil);
	else if (1 == section)
		return NSLocalizedString(@"Folders", nil);
	else if (2 == section)
		return NSLocalizedString(@"Tags", nil);
	else
		return nil;
}



- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section 
{
	if (self.accountUserId == nil
		|| self.locations == nil
		|| self.tags == nil)
		return 0;
	//
	if (0 == section)
		return 1;
	else if (1 == section)
		return [self.locations count];
	else if (2 == section)
		return [self.tags count];
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	if (0 == indexPath.section)
	{
		static NSString* CellId = @"FavoritesCell";
		//
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier:CellId] autorelease];
		}
		
		if (0 == indexPath.row)
		{
			cell.textLabel.text = NSLocalizedString(@"Recent notes", nil);
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		//
		return cell;
	}
	if (1 == indexPath.section)
	{
		static NSString* CellId = @"FolderCell";
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier:CellId] autorelease];
		}
		//
		int index = indexPath.row;
		if (index < [self.locations count])
		{
			NSString* location = [self.locations objectAtIndex:index];
			//
			cell.textLabel.text = [WizIndex locationLocaleName:location];
			cell.indentationLevel = [WizIndex pathLevel:location];
			
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//
		return cell;
	}
	else if (2 == indexPath.section)
	{
		static NSString* CellId = @"TagCell";
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
		if (cell == nil)
		{
			cell = [[[UITableViewCell alloc]
					 initWithStyle:UITableViewCellStyleDefault
					 reuseIdentifier:CellId] autorelease];
		}
		//
		int index = indexPath.row;
		if (index < [self.tags count])
		{
			WizTag* tag = [self.tags objectAtIndex:index];
			//
			cell.textLabel.text = [WizIndex pathName:tag.name];
			cell.indentationLevel = [WizIndex pathLevel:tag.namePath];
			
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		//
		return cell;	
	}
	//
	return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSString* typeData = nil;
	if (1 == indexPath.section)
	{
		typeData = [self.locations objectAtIndex:indexPath.row];
	}
	else if (2 == indexPath.section)
	{
		WizTag* tag = [self.tags objectAtIndex:indexPath.row];
		//
		typeData = tag.guid;
	}
	//
	[self.detailViewController listDocuments:self.accountUserId docType:indexPath.section typeData:typeData docs:nil];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
	[accountUserId release];
	[locations release];
	[tags release];
	
    [detailViewController release];
    [super dealloc];
}


-(void) setAccount:(NSString*)userId
{
	self.accountUserId = userId;
	self.detailViewController.accountUserId = userId;
	//
	[self reloadAllData];
	//
	[self.detailViewController clearData];
}


-(void) onSyncBegin
{
	self.navigationItem.rightBarButtonItem = self.activeButton;
}

-(void) onSyncEnd
{
	self.navigationItem.rightBarButtonItem = self.syncButton;
	//
	[self reloadAllData];
}

@end

