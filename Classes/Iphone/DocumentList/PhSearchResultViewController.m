//
//  PhSearchResultViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhSearchResultViewController.h"

@interface PhSearchResultViewController ()

@end

@implementation PhSearchResultViewController

@synthesize resultArray;
- (void) dealloc
{
    [resultArray release];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (id) initWithResultArray:(NSArray*)array
{
    self = [super init];
    if (self) {
        self.resultArray = array;
    }
    return self;
}
- (NSArray*) reloadAllDocument
{
    return self.resultArray;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.tableSourceArray documentsCount] == 0) {
        UILabel* noDocumentsLabel = [WizTableViewController noDocumentsLabel];
        noDocumentsLabel.text = NSLocalizedString(@"Search results is empty", nil);
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
