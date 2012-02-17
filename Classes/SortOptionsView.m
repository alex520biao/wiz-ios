//
//  SortOptionsView.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SortOptionsView.h"
#import "DocumentListViewControllerBaseNew.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizPadNotificationMessage.h"
@implementation SortOptionsView
@synthesize options;
@synthesize delegate;
@synthesize kOrder;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void) dealloc
{
    self.options = nil;
    self.delegate = nil;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.options = [NSArray arrayWithObjects:NSLocalizedString(@"Sort By Modified Date" , nil)
                    ,NSLocalizedString(@"Reverse Sort By Modified Date" , nil)
                    ,NSLocalizedString(@"Sort By First Letter", nil)
                    ,NSLocalizedString(@"Reverse Sort By First Letter", nil)
                    ,NSLocalizedString(@"Sort By Created Date", nil)
                    ,NSLocalizedString(@"Reverse Sort By Created Date", nil)
                    ,nil];
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

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [self.options count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = [self.options objectAtIndex:indexPath.row];
    DocumentListViewControllerBaseNew* base = (DocumentListViewControllerBaseNew*) self.delegate;
    if (indexPath.row == base.kOrder-1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!WizDeviceIsPad()) {
        DocumentListViewControllerBaseNew* base = (DocumentListViewControllerBaseNew*) self.delegate;
        if (0 == indexPath.row) {
            base.kOrder = kOrderDate;
        }    
        else if( 1== indexPath.row)
        {
            base.kOrder = kOrderReverseDate;
        }
        else if ( 2 == indexPath.row)
        {
            base.kOrder = kOrderFirstLetter;
        }
        else if (3 == indexPath.row)
        {
            base.kOrder = kOrderReverseFirstLetter;
        }
        else if (4 == indexPath.row)
        {
            base.kOrder = kOrderCreatedDate;
        }
        else if (5 == indexPath.row)
        {
            base.kOrder = kOrderReverseCreatedDate;
        }
        else 
        {
            base.kOrder = kOrderDate;
        }
        base.isReverseDateOrdered = NO;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                self.kOrder = kOrderDate;
                break;
            case 1:
                self.kOrder = kOrderReverseDate;
                break;
            case 2:
                self.kOrder = kOrderFirstLetter;
                break;
            case 3:
                self.kOrder = kOrderReverseFirstLetter;
                break;
            default:
                break;
        }
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.kOrder] forKey:TypeOfChangeSortedOrderIndex];
        [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfChangeSortedOrder object:nil userInfo:userInfo];
    }
}

@end
