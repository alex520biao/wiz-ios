//
//  WizSelectTagViewController.m
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSelectTagViewController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizNewTagCell.h"
#import "WizPadNotificationMessage.h"
@implementation WizSelectTagViewController

@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize tags;
@synthesize accountUserId;
@synthesize initSelectedTags;
@synthesize searchedTags;
@synthesize isNewTag;
- (void) dealloc
{
    self.searchedTags = nil;
    self.initSelectedTags = nil;
    self.accountUserId = nil;
    self.searchDisplayController = nil;
    self.searchBar = nil;
    self.tags = nil;
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
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) removeSelectedTag:(WizTag*)tag
{
    for (WizTag* each in [self.tags objectAtIndex:0]) {
        if ([[each name] isEqualToString:[tag name]]) {
            [[self.tags objectAtIndex:0] removeObject:each];
            return;
        }
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    for(id cc in [self.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            [btn setTitle:@"OK"  forState:UIControlStateNormal];
        }
    }
}
- (void) postSlectedTagMessage:(WizTag*)tag
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:tag forKey:TypeOfTagKey];
    [nc postNotificationName:TypeOfSelectedTag object:nil userInfo:userInfo];
}

- (void) postUnSelectedTagMessage:(WizTag*)tag
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:tag forKey:TypeOfTagKey];
    [nc postNotificationName:TypeOfUnSelectedTag object:nil userInfo:userInfo];
}

- (void) buildSeachView
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)] autorelease];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate =self;
    //change the words of searchBar cancel-button
    
    
    self.tableView.tableHeaderView = self.searchBar;
    self.searchDisplayController= [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self]autorelease];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
}
- (void) buildNavigationItems
{
    UIBarButtonItem* saveItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveTags)];
    self.navigationItem.rightBarButtonItem = saveItem;
    [saveItem release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (nil == self.tags) {
        self.tags = [NSMutableArray arrayWithCapacity:2];
    }
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSMutableArray* selectedTags = [NSMutableArray array];
    if (self.initSelectedTags != nil) {
        
        [selectedTags  addObjectsFromArray:self.initSelectedTags];
    }

    [self.tags addObject:selectedTags];
    [self.tags addObject:[NSMutableArray arrayWithArray:[index allTagsForTree]]];
    [self buildSeachView];
    
}

- (NSUInteger) tagIndexAtAll:(WizTag*)tag
{
    for (int i=0 ; i < [[tags objectAtIndex:1] count]; i++) {
        if ([[[[tags objectAtIndex:1] objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
            return i;
        }
    }
    return -1;
}
- (NSUInteger) tagIndexAtSelected:(WizTag*)tag
{

    for (int i=0 ; i < [[tags objectAtIndex:0] count]; i++) {
        if ([[[[tags objectAtIndex:0] objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
            return i;
        }
    }
    return -1;
}
- (BOOL) checkTagIsSeleted:(WizTag*)tag
{
    return -1 != [self tagIndexAtSelected:tag];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInSearchTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 2;
    }
    else
    {
        return [self numberOfSectionsInSearchTableView:tableView];
    }
}

- (NSUInteger) searchTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    NSString* match = [NSString stringWithFormat:@"*%@*",self.searchBar.text];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name like %@",match];
    NSArray* nameIn = [[self.tags objectAtIndex:1] filteredArrayUsingPredicate:predicate];
    self.searchedTags = [NSMutableArray arrayWithArray:nameIn];
    NSPredicate* searchFullName = [NSPredicate predicateWithFormat:@"name = %@",self.searchBar.text];
    NSArray* predicateArray = [[self.tags objectAtIndex:1] filteredArrayUsingPredicate:searchFullName];
    if([predicateArray count]==0)
    {
        WizTag* tag =[[WizTag alloc]init];
        tag.name = self.searchBar.text;
        [self.searchedTags insertObject:tag atIndex:0];
        self.isNewTag = YES;
        [tag release];
    }
    return [self.searchedTags count];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (tableView == self.tableView) {
        return [[tags objectAtIndex:section] count];
    }
    else
    {
        return [self searchTableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}

- (UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizTag* tag = [searchedTags objectAtIndex:indexPath.row];
    static NSString *newTagCellIdentifier = @"newTagCell";
    if (indexPath.row == 0 && isNewTag) {
        WizNewTagCell* newTagCell = [tableView dequeueReusableCellWithIdentifier:newTagCellIdentifier];
        if (newTagCell == nil) {
            newTagCell = [[[WizNewTagCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:newTagCellIdentifier] autorelease];
        }
        [newTagCell setTextFieldText:[tag name]];
        return newTagCell;
    }
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text =  NSLocalizedString( [tag name], nil);
    if ([self checkTagIsSeleted:tag]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        static NSString *CellIdentifier = @"Cell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        WizTag* tag = [[tags objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSString* tagName = getTagDisplayName(tag.name);
        cell.textLabel.text = NSLocalizedString(tagName, nil);
        if ([self checkTagIsSeleted:tag]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    else
    {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }

}

- (void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0 && isNewTag) {
        WizIndex* index = [[WizGlobalData sharedData] indexData:accountUserId];
        WizTag* tag = [index newTag:self.searchBar.text description:@"" parentTagGuid:nil];
        [self.searchedTags replaceObjectAtIndex:0 withObject:tag];
        [[self.tags objectAtIndex:0] addObject:tag];
        [[self.tags objectAtIndex:1] insertObject:tag atIndex:0];
        [self postSlectedTagMessage:tag];
        self.isNewTag = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPadTagWillReload object:nil userInfo:nil];
    }
    else
    {
        WizTag* tag = [searchedTags objectAtIndex:indexPath.row];
        if ([self checkTagIsSeleted:tag]) {
            [self removeSelectedTag:tag];
            [self postUnSelectedTagMessage:tag];
        }
        else
        {
            [[self.tags objectAtIndex:0] addObject:[searchedTags objectAtIndex:indexPath.row]];
            [self postSlectedTagMessage:tag];
        }
    }
    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void) unselectedTag:(WizTag*)tag
{
    NSUInteger indexOfSelected = [self tagIndexAtSelected:tag];
    [[tags objectAtIndex:0] removeObjectAtIndex:indexOfSelected];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexOfSelected inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self postUnSelectedTagMessage:tag];
}

- (void) selectedTag:(WizTag*)tag
{
    if (![self checkTagIsSeleted:tag]) {
        [[tags objectAtIndex:0] insertObject:tag atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [self postSlectedTagMessage:tag];
    }
    else
    {
        [self unselectedTag:tag];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView) {
        WizTag* tag =[[tags objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        switch (indexPath.section) {
            case 0:
                [self unselectedTag:tag];
                break;
            case 1:
                [self selectedTag:tag];
                break;
            default:
                break;
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self tagIndexAtAll:tag] inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
    }
    else
    {
        [self searchTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(0 == section)
        {
            return NSLocalizedString(@"Tags Selected",nil);
        }
        else if(1 == section)
        {
            return NSLocalizedString(@"All Tags",nil);
        }
        else
        {
            return @"";
        }
    }
    return nil;
}
@end
