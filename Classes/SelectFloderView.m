//
//  SelectFloderView.m
//  Wiz
//
//  Created by dong zhao on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "SelectFloderView.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizPadNotificationMessage.h"
@implementation SelectFloderView

@synthesize selectedFloder;
@synthesize allFloders;
@synthesize accountUserID;
@synthesize lastIndexPath;
@synthesize selectedFloderString;
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
    self.allFloders = nil;
    self.accountUserID = nil;
    self.lastIndexPath = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) addFloder
{
    NSString* floder = [self.selectedFloder lastObject];
    NSRange stringRange = NSMakeRange(0, [self.selectedFloderString length]);
    [self.selectedFloderString deleteCharactersInRange:stringRange];
    [self.selectedFloderString appendFormat:@"%@",floder];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.selectedFloder == nil)
        self.selectedFloder = [[[NSMutableArray alloc] init] autorelease];
    if(self.allFloders == nil)
        self.allFloders = [[[[[WizGlobalData sharedData] indexData:self.accountUserID] allLocationsForTree] mutableCopy] autorelease];
    if(![self.selectedFloderString isEqual:@""])
    {
        for(int i = 0; i < [self.allFloders count]; i++)
        {
            NSString* each = [self.allFloders objectAtIndex:i];
            if([each isEqualToString:self.selectedFloderString])
            {
                [self.selectedFloder addObject:each];
                self.lastIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
            }
        }
    }
    else
    {
        [self.selectedFloder addObject:[self.allFloders objectAtIndex:0]];
        self.lastIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    }
    UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"OK", nil) style:UIBarButtonItemStyleDone target:self action:@selector(addFloder)];
	self.navigationItem.rightBarButtonItem = editButton;
    [editButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
        return [self.selectedFloder count];
    if(section == 1)
        return [self.allFloders count];
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
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
        if(self.lastIndexPath.row == indexPath.row && self.lastIndexPath.section == indexPath.section )
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

#pragma mark - Table view delegate

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(0 == section)
        return NSLocalizedString(@"Selected folder",nil);
    if(1 == section)
        return NSLocalizedString(@"All folders", nil);
    return @"";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
//        if (0 == indexPath.section) {
//            NSString* floder = [self.selectedFloder lastObject];
//            int rowInAllFloder = [self.allFloders indexOfObject:floder];
//            NSIndexPath* index = [NSIndexPath indexPathForRow:rowInAllFloder inSection:1];
//            UITableViewCell* cell = [tableView cellForRowAtIndexPath:index];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            [self.selectedFloder removeAllObjects];
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        }
        if( 1 == indexPath.section) {
            NSIndexPath* oldIndex = [NSIndexPath indexPathForRow:self.lastIndexPath.row inSection:self.lastIndexPath.section];
            self.lastIndexPath = indexPath;
            NSString* floder = [self.allFloders objectAtIndex:indexPath.row];
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            NSIndexPath* index = [NSIndexPath indexPathForRow:0 inSection:0];
            if (cell.accessoryType == UITableViewCellAccessoryNone) {
                if([self.selectedFloder count] != 0)
                {
                    [self.selectedFloder removeAllObjects];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationLeft];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:oldIndex] withRowAnimation:UITableViewRowAnimationLeft];
                }
                self.lastIndexPath = indexPath;
                [self.selectedFloder addObject:floder];
                if (WizDeviceIsPad()) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfSelectedFolder object:nil userInfo:[NSDictionary dictionaryWithObject:floder forKey:TypeOfFolderKey]];
                }

                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationRight];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        
    }
}

@end
