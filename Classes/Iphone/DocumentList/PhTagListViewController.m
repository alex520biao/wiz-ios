//
//  PhTagListViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhTagListViewController.h"

@interface PhTagListViewController ()

@end

@implementation PhTagListViewController

@synthesize tagGuid;
- (void) dealloc
{
    [tagGuid release];
    [super dealloc];
}

- (id) initWithTagGuid:(NSString*)guid
{
    self = [super init];
    if (self) {
        self.tagGuid = guid;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (NSArray*) reloadAllDocument
{
    NSArray* ret = [WizDocument documentsByTag:self.tagGuid];
    if (nil == ret) {
        ret = [NSArray array];
    }
    return ret;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([self.tableSourceArray documentsCount] == 0) {
        UILabel* noDocumentsLabel = [WizTableViewController noDocumentsLabel];
        noDocumentsLabel.text = NSLocalizedString(@"This tag is empty", nil);
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
