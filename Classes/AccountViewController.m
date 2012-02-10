//
//  AccountViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/8/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "AccountViewController.h"
#import "EditAccountViewController.h"
#import "FoldersViewController.h"
#import "TagsViewController.h"
#import "RecentDocumentViewController.h"
#import "NewNoteViewController.h"
#import "SearchViewController.h"
#import "CommonString.h"
#import "WizActivityIndicatorTableViewCell.h"
#import "Globals/WizSync.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizSettings.h"


@implementation AccountViewController

@synthesize accountUserId;
@synthesize imgNewNote;
@synthesize imgTakePhoto;
@synthesize imgDocuments;	
@synthesize imgFolders;	
@synthesize imgTags;	
@synthesize imgSync;	
@synthesize imgEditAccount;	



- (void) initSearchButton
{
	UIBarButtonItem* button = [[UIBarButtonItem alloc] initWithTitle:WizStrSearch style:UIBarButtonItemStyleDone target:self action:@selector(onSearchDocuments:)];
	self.navigationItem.rightBarButtonItem = button;
	[button release];
}


- (void) viewDidLoad
{
	WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncBegin) name:[sync notificationName:WizSyncBeginNotificationPrefix] object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
	//
	self.title = accountUserId;
	//
	self.imgNewNote = [UIImage imageNamed:@"note_new"];
	self.imgTakePhoto = [UIImage imageNamed:@"photo_new"];
	self.imgDocuments = [UIImage imageNamed:@"documents"];
	self.imgFolders = [UIImage imageNamed:@"folders"];
	self.imgTags = [UIImage imageNamed:@"tags"];
	self.imgSync = [UIImage imageNamed:@"sync"];
	self.imgEditAccount = [UIImage imageNamed:@"account_edit"];
	//
	[self initSearchButton];
	//
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
	//
	self.imgNewNote = nil;
	self.imgTakePhoto = nil;
	self.imgDocuments = nil;
	self.imgFolders = nil;
	self.imgTags = nil;
	self.imgSync = nil;
	self.imgEditAccount = nil;
}
- (void) dealloc
{
	self.accountUserId = nil;
	//
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
	self.navigationController.navigationBarHidden = NO;
	[super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 4;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	if (0 == section)
		return 1;
	else if (1 == section)
		return 3;
	else if (2 == section)
		return 1;
	else 
		return 1;
}


- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
	static NSString* CellId = @"AccountCell";
	//
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellId];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault
				 reuseIdentifier:CellId] autorelease];
	}
	
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			cell.textLabel.text = NSLocalizedString(@"New Note", nil);
			cell.imageView.image = self.imgNewNote;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	if (1 == indexPath.section)
	{
		if (0 == [indexPath row])
		{
			cell.textLabel.text = NSLocalizedString(@"Recent Documents", nil);
			cell.imageView.image = self.imgDocuments;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (1 == [indexPath row])
		{
			cell.textLabel.text = NSLocalizedString(@"Folders", nil);
			cell.imageView.image = self.imgFolders;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if (2 == [indexPath row])
		{
			cell.textLabel.text = WizStrTags;
			cell.imageView.image = self.imgTags;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if (2 == indexPath.section)
	{
		if (0 == [indexPath row])
		{
			static NSString* CellId = @"SyncCell";
			
			cell = [tableView dequeueReusableCellWithIdentifier:CellId];
			if (cell == nil)
			{
				cell = [[[WizActivityIndicatorTableViewCell alloc]
						 initWithStyle:UITableViewCellStyleDefault
						 reuseIdentifier:CellId] autorelease];
			}
			//
			WizActivityIndicatorTableViewCell* activityCell = (WizActivityIndicatorTableViewCell *)cell;
			if (activityCell)
			{
				WizSync* sync = [[WizGlobalData sharedData] syncData:accountUserId];
				if (sync.busy)
				{
					[activityCell startActivityAnimation];
				}
			}
			//
			cell.textLabel.text = WizStrSync;
			cell.imageView.image = self.imgSync;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//
			
		}
	}
	else if (3 == indexPath.section)
	{
		cell.textLabel.text = NSLocalizedString(@"Edit Account", nil);
		cell.imageView.image = self.imgEditAccount;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	//
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	if (0 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			NewNoteViewController* noteView = [[NewNoteViewController alloc] init];
            //initWithCoder:(NSCoder *)aDecoder initWithNibName:@"TextEditViewController" bundle:nil];
			
			noteView.accountUserId = self.accountUserId;
			
			[self.navigationController pushViewController:noteView animated:YES];
			[noteView release];	
            

		}
	}
	else if (1 == indexPath.section)
	{
		if (0 == indexPath.row)
		{
			RecentDocumentViewController* documentsView = [[RecentDocumentViewController alloc] initWithStyle:UITableViewStylePlain];
			
			documentsView.accountUserId = self.accountUserId;
			
			[self.navigationController pushViewController:documentsView animated:YES];
			[documentsView release];	
		}
		else if (1 == indexPath.row)
		{
			FoldersViewController *foldersView = [[FoldersViewController alloc] initWithStyle:UITableViewStylePlain];
			
			foldersView.accountUserId = self.accountUserId;
			
			[self.navigationController pushViewController:foldersView animated:YES];
			[foldersView release];	
		}
		else if (2 == indexPath.row)
		{
			TagsViewController *tagsView = [[TagsViewController alloc] initWithStyle:UITableViewStylePlain];
			
			tagsView.accountUserId = self.accountUserId;
			
			[self.navigationController pushViewController:tagsView animated:YES];
			[tagsView release];	
		}
	}
	else if (2 == indexPath.section)
	{
		WizSync* sync = [[WizGlobalData sharedData] syncData: accountUserId];
		[sync startSync];
	}
	else if (3 == indexPath.section)
	{
		EditAccountViewController *editAccountView = [[EditAccountViewController alloc] initWithNibName:@"EditAccountViewController" bundle:nil];
		
		editAccountView.accountUserId = self.accountUserId;
		editAccountView.accountPassword = [WizSettings accountPasswordByUserId:self.accountUserId];
		
		[self.navigationController pushViewController:editAccountView animated:YES];
		[editAccountView release];	
	}
	//
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) onSyncBegin
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow: 0 inSection:2]; 
	
	UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
	//
	if ([cell isKindOfClass:[WizActivityIndicatorTableViewCell class]])
	{
		WizActivityIndicatorTableViewCell* c = (WizActivityIndicatorTableViewCell *)cell;
		//
		[c startActivityAnimation];
	}
	
}

-(void) onSyncEnd
{
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow: 0 inSection:2]; 
	
	UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
	//
	if ([cell isKindOfClass:[WizActivityIndicatorTableViewCell class]])
	{
		WizActivityIndicatorTableViewCell* c = (WizActivityIndicatorTableViewCell *)cell;
		//
		[c stopActivityAnimation];
	}
}

- (void)onSearchDocuments: (id)sender
{
	SearchViewController *searchView = [[SearchViewController alloc] initWithNibName:@"SearchViewController" bundle:nil];
	
	searchView.accountUserId = self.accountUserId;
	searchView.accountPassword = [WizSettings accountPasswordByUserId:self.accountUserId];
	
	[self.navigationController pushViewController:searchView animated:YES];
	[searchView release];
}


@end
