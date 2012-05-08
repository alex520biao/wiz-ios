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
        // Custom initialization
    }
    return self;
}
- (id) initWithResultArray:(NSArray*)array
{
    self = [super init];
    if (self) {
        self.resultArray = array;
    }
    return array;
}
- (NSArray*) reloadAllDocument
{
    return self.resultArray;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self reloadAllData];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
