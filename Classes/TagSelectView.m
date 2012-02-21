//
//  TagSelectView.m
//  Wiz
//
//  Created by dong zhao on 11-11-14.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "TagSelectView.h"
#import "Globals/WizGlobalData.h"
#import "WizIndex.h"
#import "WizNewTagCell.h"

@implementation TagSelectView

@synthesize select;
@synthesize tags;
@synthesize accountUserId;
@synthesize searchBar;
@synthesize search;
@synthesize tagsSearch;
@synthesize selectCount;
@synthesize tagsWillAdd;
@synthesize isNewTag;
@synthesize documentTagsGUID;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    self.accountUserId  = nil;
    self.searchBar = nil;
    self.tags    = nil;
    self.select   = nil;
    self.tagsSearch = nil;
    self.tagsWillAdd = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void) addTagsToWizDocument
{
    NSMutableString* tagsGuid = [[NSMutableString alloc] init ];
    int tagsSelectCount = [self.select count];
    if(tagsSelectCount > 0 )
    {
        for(int i=0; i< tagsSelectCount -1;i++)
        {

            [tagsGuid appendFormat:@"%@*",[[self.select objectAtIndex:i] guid]];
        }
        [tagsGuid appendFormat:@"%@",[[self.select lastObject] guid]];
        
    }
    NSRange stringRange = NSMakeRange(0, [self.documentTagsGUID length]);
    [self.documentTagsGUID deleteCharactersInRange:stringRange];
    [self.documentTagsGUID appendFormat:@"%@",tagsGuid];
    [tagsGuid release];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(nil == self.select)
        self.select = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
    if(nil == self.tags)
        self.tags   = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
    if(nil == self.tagsSearch)
        self.tagsSearch = [[[NSMutableArray alloc] init] autorelease];
    if(nil == self.tagsWillAdd)
        self.tagsWillAdd = [[[NSMutableArray alloc] initWithCapacity:30] autorelease];
    self.tags = [[[[[WizGlobalData sharedData] indexData:accountUserId] allTagsForTree] mutableCopy] autorelease];
    if(self.documentTagsGUID != nil)
    {
        NSArray* tagGuids = [documentTagsGUID componentsSeparatedByString:@"*"];
        for(NSString* eachGuid in tagGuids)
        {
            for(WizTag* eachTag in self.tags)
            {
                if([eachTag.guid isEqualToString:eachGuid])
                {
                    [self.select addObject:eachTag];
                }
            }
        }
        
    }
    
    // buuid search part
    self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)] autorelease];
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    //change the words of searchBar cancel-button
    
    
    self.tableView.tableHeaderView = self.searchBar;
    self.search= [[[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self]autorelease];
    self.search.searchResultsDelegate = self;
    self.search.searchResultsDataSource = self;
    [self setSearch:self.search];
    
    
    self.selectCount = 0;
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStyleDone target:self action:@selector(addTagsToWizDocument)];
	self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(tableView == self.tableView)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.tableView == tableView)
    {
        
        if(0 == section)
            return [self.select count];
        if(1 == section)
            return [self.tags count];
    }
    else
    {
        self.isNewTag = NO;
        NSPredicate* searchFullName = [NSPredicate predicateWithFormat:@"name = %@",self.searchBar.text];
        NSArray* predicateArray = [self.tags filteredArrayUsingPredicate:searchFullName]  ;
        NSMutableArray* tagTemp = [[NSMutableArray alloc] init];
        if([predicateArray count]==0)
        {
            WizTag* tag = [[WizTag alloc] init];
            tag.name = self.searchBar.text;
            [tagTemp addObject:tag];
            [tag release];
            self.isNewTag = YES;
        }
        NSString* match = [NSString stringWithFormat:@"*%@*",self.searchBar.text];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"name like %@",match];
        NSArray* nameIn = [self.tags filteredArrayUsingPredicate:predicate];
        [tagTemp addObjectsFromArray:nameIn];
        self.tagsSearch = [[tagTemp mutableCopy]  autorelease];
        [tagTemp release];
        return [self.tagsSearch count];
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if(tableView == self.tableView)
    {
        if(0 == indexPath.section)
        {
            cell.textLabel.text = NSLocalizedString([[self.select objectAtIndex:indexPath.row] name],nil);
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        if(1 == indexPath.section)
        {
            cell.textLabel.text = NSLocalizedString([[self.tags objectAtIndex:indexPath.row] name],nil);
            if([self.select containsObject:[self.tags objectAtIndex:indexPath.row]])
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    else
    {
        if(self.isNewTag == YES)
        {
            if(indexPath.row == 0)
            {
                WizNewTagCell* cell = [[WizNewTagCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell0"];
                [cell setTextFieldText:self.searchBar.text];
                return cell;
            }
            else
            {
                cell.textLabel.text = NSLocalizedString([[self.tagsSearch objectAtIndex:indexPath.row] name],nil);
            }
            return cell;
        }
        
        cell.textLabel.text = NSLocalizedString([[self.tagsSearch objectAtIndex:indexPath.row] name],nil);
        if([self.tagsWillAdd containsObject:[self.tagsSearch objectAtIndex:indexPath.row]])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}



-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    
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


-(void) addTagsToSelectArray
{
    for(WizTag* each in self.tagsWillAdd)
    {
        if([self.tags containsObject:each])
        {
            if(![self.select containsObject:each]){
                int index = [self.tags indexOfObject:each];
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [self.select insertObject:each atIndex:0];
                NSIndexPath* indexPathInsert = [NSIndexPath indexPathForRow:[self.select indexOfObject:each] inSection:0];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathInsert] withRowAnimation:UITableViewRowAnimationTop];
            }
        }
        else {
            [self.tags insertObject:each atIndex:0];
            NSIndexPath* insertIndexPath = [NSIndexPath indexPathForRow:[self.tags indexOfObject:each] inSection:1];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:insertIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:insertIndexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            
            [self.select insertObject:each atIndex:0];
            NSIndexPath* indexPathInsert = [NSIndexPath indexPathForRow:[self.select indexOfObject:each] inSection:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPathInsert] withRowAnimation:UITableViewRowAnimationTop];
        }
        
    }
    [self.tagsWillAdd removeAllObjects];
    self.selectCount = 0;

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView == self.tableView)
    {
        if(indexPath.section == 1)
        {
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                WizTag* didSelect = [self.tags objectAtIndex:indexPath.row];
                int tagSelectPathRow = [self.select indexOfObject:didSelect];
                [self.select removeObject:didSelect];
                NSIndexPath* index = [NSIndexPath indexPathForRow:tagSelectPathRow inSection:0];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:YES];
                cell.accessoryType = UITableViewCellAccessoryNone;
                
                
            }
            else
            {
                WizTag* didselect = [self.tags objectAtIndex:indexPath.row];
                [didselect retain];
                [self.select insertObject:didselect atIndex:0];
                NSIndexPath *indexx = [NSIndexPath indexPathForRow:0 inSection:0];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexx] withRowAnimation:UITableViewRowAnimationTop];
                [[self.tableView cellForRowAtIndexPath:indexx] setAccessoryType:UITableViewCellAccessoryCheckmark];
                [didselect release];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
        }
        if(indexPath.section == 0)
        {
            WizTag* didselect = [self.select objectAtIndex:indexPath.row];
            [self.select removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            int tagIndex = [self.tags indexOfObject:didselect];
            NSIndexPath *indexx = [NSIndexPath indexPathForRow:tagIndex inSection:1];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexx];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    }
    else  //search table
    {
        if(self.isNewTag == YES)
        {
            if(indexPath.row == 0)
            {
                WizIndex* index  = [[WizGlobalData sharedData] indexData:self.accountUserId];
                WizTag* tag = [index newTag:self.searchBar.text description:@"" parentTagGuid:nil];
                [self.tagsWillAdd addObject:tag];
                UITableViewCell* cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                [self.tagsSearch removeObjectAtIndex:0];
                [self.tagsSearch insertObject:tag atIndex:0];
                //add the new tag to self.tags
                [self.tags insertObject:tag atIndex:0];
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                NSIndexPath* insertIndexPath = [NSIndexPath indexPathForRow:[self.tags indexOfObject:tag] inSection:1];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:insertIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                //
                cell.textLabel.text = self.searchBar.text;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                self.selectCount++;
                self.isNewTag = NO;
                [tag release];
            }
            else
            {
                UITableViewCell* cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
                if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
                {
                    [self.tagsWillAdd removeObject:[self.tagsSearch objectAtIndex:indexPath.row-1]];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    self.selectCount--;
                  
                    
                }
                else
                {
                    if(![self.tagsWillAdd containsObject:[self.tagsSearch objectAtIndex:indexPath.row-1]])
                    {
                        [self.tagsWillAdd addObject:[self.tagsSearch objectAtIndex:indexPath.row-1]];
                        self.selectCount++;
                    }
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                   
                }
                
            }
        }
        else
        {
            UITableViewCell* cell = [self.searchDisplayController.searchResultsTableView cellForRowAtIndexPath:indexPath];
            if(cell.accessoryType == UITableViewCellAccessoryCheckmark)
            {
                [self.tagsWillAdd removeObject:[self.tagsSearch objectAtIndex:indexPath.row]];
                cell.accessoryType = UITableViewCellAccessoryNone;
                self.selectCount--;
                
                
            }
            else
            {
                if(![self.tagsWillAdd containsObject:[self.tagsSearch objectAtIndex:indexPath.row]])
                {
                    [self.tagsWillAdd addObject:[self.tagsSearch objectAtIndex:indexPath.row]];
                    self.selectCount++;
                }
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
        }
        if(self.selectCount != 0)
        {
            for(id cc in [self.searchBar subviews])
            {
                if([cc isKindOfClass:[UIButton class]])
                {
                    UIButton* btn = (UIButton*) cc;
                    [btn setTitle:@"OK" forState:UIControlStateNormal];
                    [btn addTarget:self action:@selector(addTagsToSelectArray) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        else
        {
            for(id cc in [self.searchBar subviews])
            {
                if([cc isKindOfClass:[UIButton class]])
                {
                    UIButton* btn = (UIButton*) cc;
                    [btn setTitle:@"Cancel" forState:UIControlStateNormal];
                    [btn removeTarget:select action:@selector(addTagsToSelectArray) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}

@end
