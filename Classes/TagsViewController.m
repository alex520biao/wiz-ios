//
//  TagsViewController.m
//  Wiz
//
//  Created by Wei Shijun on 3/14/11.
//  Copyright 2011 WizBrother. All rights reserved.
//

#import "TagsViewController.h"
#import "TagViewController.h"
#import "CommonString.h"

#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizSync.h"
#import "TagDocumentListView.h"

@implementation TagsViewController


@synthesize accountUserId;
@synthesize tags;


- (void) viewDidLoad
{
	
    self.title = WizStrTags;
	//
	[super viewDidLoad];
}

- (void) viewDidUnload
{
	[super viewDidUnload];
}

- (void) dealloc
{
	self.accountUserId = nil;
	self.tags = nil;
	//
	[super dealloc];
}

- (void) viewWillAppear:(BOOL)animated
{
		//
    
    self.tags =  [[[WizGlobalData sharedData] indexData:accountUserId] allTagsForTree];
	[[self tableView] reloadData];
	[super viewWillAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	//
	self.tags = nil;
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger) numberOfSectionsInTableView: (UITableView *)tableView
{
	return 1;
}

- (NSInteger) tableView: (UITableView *)tableView
  numberOfRowsInSection: (NSInteger)section
{
	 if (0 == section)
		return [self.tags count];
	else
		return 0;
}

- (UITableViewCell *) tableView: (UITableView *)tableView
		  cellForRowAtIndexPath: (NSIndexPath *)indexPath
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
	if (0 == indexPath.section)
	{
		int index = indexPath.row;
		if (index < [self.tags count])
		{
			WizTag* tag = [self.tags objectAtIndex:index];
			//
			cell.textLabel.text = [WizIndex pathName:tag.name];
			cell.indentationLevel = [WizIndex pathLevel:tag.namePath];
			
		}
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
		if (indexPath.row < [self.tags count])
		{
			WizTag* tag = [self.tags objectAtIndex:indexPath.row];
			//
			TagDocumentListView* tagView = [[TagDocumentListView alloc] initWithStyle:UITableViewStylePlain];
			tagView.accountUserID = accountUserId;
			tagView.tag = tag;
			[self.navigationController pushViewController:tagView animated:YES];
			[tagView release];
			return;
		}
	}
}

@end
