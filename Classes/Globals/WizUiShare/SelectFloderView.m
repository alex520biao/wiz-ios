//
//  SelectFloderView.m
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectFloderView.h"
#import "WizPadNotificationMessage.h"
#import "WizFolderSelectDelegate.h"
#import "WizDbManager.h"
#import "WizNotification.h"
@interface SelectFloderView ()
{
    NSMutableArray* allFloders;
    NSMutableArray*       selectedFloder;
    UISearchBar* searchBar;
    UISearchDisplayController* searchDisplayController;
    NSArray* searchedFolder;
}
@property (nonatomic, retain) NSMutableArray* allFloders;
@property (nonatomic, retain) NSMutableArray* selectedFloder;
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UISearchDisplayController* searchDisplayController;
@property (nonatomic, retain) NSArray* searchedFolder;
@end
@implementation SelectFloderView

@synthesize selectedFloder;
@synthesize allFloders;
@synthesize searchBar;
@synthesize searchDisplayController;
@synthesize searchedFolder;
@synthesize selectDelegate;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}
- (void)dealloc
{
    [searchedFolder release];
    [allFloders release];
    [searchDisplayController release];
    [searchBar release];
    selectDelegate = nil;
    [super dealloc];
}
- (void)searchTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* folder = [self.searchedFolder objectAtIndex:indexPath.row];
    if ([folder isEqualToString:[self.selectedFloder lastObject]]) {
            return;
    }
    else {
        [self didSelectedFolder:folder];
        [tableView beginUpdates];
        [tableView reloadData];
        [tableView endUpdates];
        [self.tableView reloadData];
    }
}
- (void) buildSeachView
{
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)] autorelease];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.delegate =self;
    self.tableView.tableHeaderView = self.searchBar;
    self.searchDisplayController= [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self]autorelease];
    self.searchDisplayController.searchResultsDelegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) addFloder
{
   [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfSelectedFolder object:nil userInfo:[NSDictionary dictionaryWithObject:[self.selectedFloder lastObject]  forKey:TypeOfFolderKey]];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildSeachView];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    if(self.selectedFloder == nil)
    {
        self.selectedFloder = [NSMutableArray array];
        NSString* sFolder = [self.selectDelegate selectedFolderOld];
        if (nil == sFolder || [sFolder isBlock]) {
            sFolder = @"/My Notes/";
        }
        [self.selectedFloder addObject:sFolder];
    }
    if(self.allFloders == nil)
    {
        self.allFloders =[NSMutableArray array];
        [self.allFloders addObjectsFromArray:[[[WizDbManager shareDbManager] shareDataBase]allLocationsForTree]];
    }
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView) {
        return 2;
    }
    else {
        return 1;
    }
}

- (NSUInteger) searchTableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString* match = [NSString stringWithFormat:@"*%@*",self.searchBar.text];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",match];
    NSArray* nameIn = [self.allFloders filteredArrayUsingPredicate:predicate];
    self.searchedFolder = nameIn;
    return [self.searchedFolder count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(section == 0)
            return [self.selectedFloder count];
        if(section == 1)
            return [self.allFloders count];
    }
    else {
        return [self searchTableView:tableView numberOfRowsInSection:section];
    }
    return 0;
}
- (UITableViewCell *)searchTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    NSString* title = [self.searchedFolder objectAtIndex:indexPath.row];
    if ([title isEqualToString:[self.selectedFloder lastObject]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = [self.searchedFolder objectAtIndex:indexPath.row];
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.tableView)
    {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        if(0 == indexPath.section) 
        {
            cell.textLabel.text = [WizGlobals folderStringToLocal:[self.selectedFloder objectAtIndex:indexPath.row]];
        }
        if(1 == indexPath.section)
        {
            cell.textLabel.text = [WizGlobals folderStringToLocal:[self.allFloders objectAtIndex:indexPath.row]];
            if ([[self.selectedFloder lastObject] isEqualToString:[self.allFloders objectAtIndex:indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    else {
        return [self searchTableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(0 == section)
            return NSLocalizedString(@"Selected folders",nil);
        if(1 == section)
            return NSLocalizedString(@"All folders", nil);
    }
    else {
        return nil;
    }
    return @"";
}
- (BOOL) checkFolderIsExist:(NSString*)folder
{
    for (NSString* each in self.allFloders) {
        if ([each isEqualToString:folder]) {
            return YES;
        }
    }
    return NO;
}
- (void) didSelectedFolder:(NSString*)folder
{
    if (![self checkFolderIsExist:folder]) {
        [self.allFloders insertObject:folder atIndex:0];
    }
    [self.selectedFloder removeLastObject];
    [self.selectedFloder addObject:folder];
    [self.selectDelegate didSelectedFolderString:folder];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        if( 1 == indexPath.section) {
            NSString* folder = [self.allFloders objectAtIndex:indexPath.row];
            if ([folder isEqualToString:[self.selectedFloder lastObject]]) {
                return;
            }
            else {
                [self didSelectedFolder:folder];
                [self.tableView reloadData];
            }
        }
        
    }
    else {
        [self searchTableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
    if (searchBar_.text == nil || [[searchBar_.text trim] isEqualToString:@""]) {
        return;
    }
    NSString* locationString = [[searchBar_.text trim] stringReplaceUseRegular:@"[\\,/,:,<,>,*,?,\",&,\"]"];
    NSString* location = [NSString stringWithFormat:@"/%@/",locationString];
    if (![self checkFolderIsExist:location]) {
        [self.allFloders insertObject:location atIndex:0];
    }
    [self.selectedFloder removeLastObject];
    [self.selectedFloder addObject:location];
    [self.selectDelegate didSelectedFolderString:location];
    [self.tableView reloadData];
    [WizNotificationCenter postSimpleMessageWithName:MessageTypeOfUpdateFolderTable];
}


- (void) searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText
{
    
    NSLog(@"the search text is %@",searchText);
    self.searchBar.showsCancelButton = YES;
    if (searchText == nil) {
        return;
    }
    
    if ([searchText checkHasInvaildCharacters]) {
        [WizGlobals reportError:[WizGlobalError folderInvalidCharacterError:searchText]];
        searchBar_.text = [searchText stringReplaceUseRegular:@"[\\,/,:,<,>,*,?,\",&,\"]"];
    }
    for(id cc in [self.searchBar subviews])
    {
        if([cc isKindOfClass:[UIButton class]])
        {
            UIButton *btn = (UIButton *)cc;
            if (searchText != nil && ![[searchText trim] isEqualToString:@""]) {
                [btn setTitle:WizStrAddFloder forState:UIControlStateNormal];
            }
            else
            {
                [btn setTitle:WizStrCancel forState:UIControlStateNormal];
            }
        }
    }
}
@end
