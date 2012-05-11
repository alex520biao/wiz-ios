//
//  PhFolderListViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhFolderListViewController.h"

@interface PhFolderListViewController ()

@end

@implementation PhFolderListViewController
@synthesize folder;
- (void) dealloc
{
    [folder release];
    [super dealloc];
}
- (id) initWithFolder:(NSString *)folder_
{
    self = [super init];
    if (self) {
        self.folder = folder_;
    }
    return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (NSArray*) reloadAllDocument
{
    NSArray* ret = [WizDocument documentsByLocation:self.folder];
    if (nil == ret) {
        ret = [NSArray array];
    }
    return ret;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated
{
    [self reloadAllData];
    [super viewWillAppear:animated];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
