//
//  WizPadRecentViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadRecentViewController.h"

@interface WizPadRecentViewController ()
{
    NSMutableArray* documents;
}
@property (nonatomic, retain) NSMutableArray* documents;
@end

@implementation WizPadRecentViewController

@synthesize documents;
- (void) dealloc
{
    [documents release];
    documents = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        documents = [[NSMutableArray alloc] init ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.gridView setCellSize:CGSizeMake(180, 200)];
    [documents addObjectsFromArray:[WizDocument recentDocuments]];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}
- (NSInteger) numberOfSectionsInGridView:(NRGridView *)gridView
{
    return 1;
}

- (NSInteger) gridView:(NRGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return [documents count];
}
- (NRGridViewCell*) gridView:(NRGridView *)gridView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyCellIdentifier = @"MyCellIdentifier";
    
    NRGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:MyCellIdentifier];
    
    if(cell == nil){
        cell = [[[NRGridViewCell alloc] initWithReuseIdentifier:MyCellIdentifier] autorelease];
        cell.backgroundColor = [UIColor whiteColor];
        [[cell textLabel] setFont:[UIFont boldSystemFontOfSize:11.]];
        [[cell detailedTextLabel] setFont:[UIFont systemFontOfSize:11.]];
        
    }
    WizDocument* doc = [documents objectAtIndex:indexPath.row];
    cell.textLabel.text = doc.title;
    cell.detailedTextLabel.text = @"Some details";
    return cell;
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
