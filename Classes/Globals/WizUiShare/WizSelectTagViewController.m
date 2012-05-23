//
//  WizSelectTagViewController.m
//  Wiz
//
//  Created by wiz on 12-2-3.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizSelectTagViewController.h"
#import "WizGlobalData.h"
#import "WizNewTagCell.h"
#import "WizPadNotificationMessage.h"
#import "WizPhoneNotificationMessage.h"
#import "WizGlobals.h"
#import "WizNotification.h"

@interface WizSelectTagViewController()
{
    NSMutableArray* tags;
    UISearchBar* searchBar;
    UISearchDisplayController* searchDisplayController;
    NSMutableArray* searchedTags;
    BOOL isNewTag;
}
@property (nonatomic, retain) NSMutableArray* tags;
@property (nonatomic, retain)UISearchBar* searchBar;
@property (nonatomic, retain)UISearchDisplayController* searchDisplayController;
@property (nonatomic, retain) NSMutableArray* searchedTags;
@property BOOL isNewTag;
@end

@implementation WizSelectTagViewController

@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize tags;
@synthesize searchedTags;
@synthesize isNewTag;
@synthesize selectDelegate;
- (void) dealloc
{
    selectDelegate = nil;
    [searchedTags release];
    [searchDisplayController release];
    [searchBar release];
    [tags release];
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
- (NSMutableArray*) selectedTags
{
    return [tags objectAtIndex:0];
}

- (NSMutableArray*) allTags
{
    return [tags objectAtIndex:1];
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
            [btn setTitle:WizStrOK forState:UIControlStateNormal];
        }
    }
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
    [self buildSeachView];
    if (nil == self.tags) {
        self.tags = [NSMutableArray arrayWithCapacity:2];
    }
    NSArray* initSelectedTags = [self.selectDelegate selectedTagsOld];
    NSMutableArray* selectedTags = [NSMutableArray array];
    [self.tags addObject:selectedTags];
    NSMutableArray* allTags = [NSMutableArray arrayWithArray:[WizTag allTags]];
    if (initSelectedTags != nil) {
        for (WizTag* initTag in initSelectedTags) {
            for (WizTag* existTag in allTags) {
                if ([[initTag guid] isEqualToString:[existTag guid]]) {
                    [selectedTags addObject:existTag];
                }
            }
        }
    }
    [self.tags addObject:allTags];
    
}

- (NSUInteger) tagIndexAtAll:(WizTag*)tag
{
    for (int i=0 ; i < [[self allTags] count]; i++) {
        if ([[[[self allTags] objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
            return i;
        }
    }
    return -1;
}
- (NSUInteger) tagIndexAtSelected:(WizTag*)tag
{

    for (int i=0 ; i < [[self selectedTags] count]; i++) {
        if ([[[[self selectedTags] objectAtIndex:i] guid] isEqualToString:[tag guid]]) {
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
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"title like %@",match];
    NSArray* nameIn = [[self allTags] filteredArrayUsingPredicate:predicate];
    self.searchedTags = [NSMutableArray arrayWithArray:nameIn];
    NSPredicate* searchFullName = [NSPredicate predicateWithFormat:@"title = %@",self.searchBar.text];
    NSArray* predicateArray = [[self allTags] filteredArrayUsingPredicate:searchFullName];
    if([predicateArray count]==0)
    {
        WizTag* tag =[[WizTag alloc]init];
        tag.title = self.searchBar.text;
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
        [newTagCell setTextFieldText:[tag title]];
        return newTagCell;
    }
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text =  NSLocalizedString( [tag title], nil);
    if ([self checkTagIsSeleted:tag]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}
- (void) removeSelectedTag:(WizTag*)tag
{
    for (WizTag* each in [self.tags objectAtIndex:0]) {
        if ([[each title] isEqualToString:[tag title]]) {
            [[self.tags objectAtIndex:0] removeObject:each];
            return;
        }
    }
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
        NSString* tagName = getTagDisplayName(tag.title);
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
- (void) unselectedTag:(WizTag*)tag
{
    NSUInteger indexOfSelected = [self tagIndexAtSelected:tag];
    [[tags objectAtIndex:0] removeObjectAtIndex:indexOfSelected];
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexOfSelected inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    [self.selectDelegate didSelectedTags:[self.tags objectAtIndex:0]];
}

- (void) selectedTag:(WizTag*)tag
{
    [[tags objectAtIndex:0] insertObject:tag atIndex:0];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView endUpdates];
    [self.selectDelegate didSelectedTags:[self.tags objectAtIndex:0]];
}
- (void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==0 && isNewTag) {
        WizTag* tag = [self.searchedTags objectAtIndex:0];
        [tag save];
        [self selectedTag:tag];
        [[self allTags] insertObject:tag atIndex:0];
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
        self.isNewTag = NO;
        [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateTagTable];
    }
    else
    {
        WizTag* tag = [self.searchedTags objectAtIndex:indexPath.row];
        if (![self checkTagIsSeleted:tag]) {
            [self selectedTag:tag];
        }
        else {
            [self unselectedTag:tag];
        }
    }
    [self.searchDisplayController.searchResultsTableView beginUpdates];
    [self.searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self.searchDisplayController.searchResultsTableView endUpdates];
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
                if (![self checkTagIsSeleted:tag]) {
                    [self selectedTag:tag];
                }
                else {
                    [self unselectedTag:tag];
                }
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
            return NSLocalizedString(@"Selected tags",nil);
        }
        else if(1 == section)
        {
            return NSLocalizedString(@"All tags",nil);
        }
        else
        {
            return @"";
        }
    }
    return nil;
}
@end
