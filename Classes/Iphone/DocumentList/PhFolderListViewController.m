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
    NSLog(@"folder view init ");
    self = [super init];
    if (self) {
        self.folder = folder_;
    }
    NSLog(@"folder view after super init ");
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
    NSLog(@"location key is %@",self.folder);
    NSArray* ret = [WizDocument documentsByLocation:self.folder];
    NSLog(@"ret is %d",[ret count]);
    if (nil == ret) {
        ret = [NSArray array];
    }
    return ret;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"folder viewdidload");
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
