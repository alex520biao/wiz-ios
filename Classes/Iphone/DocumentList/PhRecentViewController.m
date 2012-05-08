//
//  PhRecentViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-4-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhRecentViewController.h"
#import "WizDbManager.h"

@interface PhRecentViewController ()

@end

@implementation PhRecentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSLog(@"view init");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"view init after super init");
    }
    return self;
}
- (NSArray*) reloadAllDocument
{
    return [WizDocument recentDocuments];
}

- (void) insertDocument:(WizDocument*)doc indexPath:(NSIndexPath*)indexPath
{
    if ([self documentsCount] > 100) {
        [self deleteDocument:[[[self.tableSourceArray lastObject]lastObject] guid]];
    }
    NSInteger updateSection = indexPath.section;
    if (updateSection == NSNotFound) {
        NSMutableArray* newArr = [NSMutableArray arrayWithObject:doc];
        updateSection = 0;
        [self.tableSourceArray insertObject:newArr atIndex:updateSection];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:updateSection] withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        [self.tableView beginUpdates];
        NSMutableArray* arr = [self.tableSourceArray objectAtIndex:updateSection];
        [arr insertObject:doc atIndex:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:updateSection]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void) deleteDocument:(NSString *)documentGuid
{
    [WizNotificationCenter postDeleteDocumentMassage:documentGuid];
}
-(void) setupAccount
{
    [WizNotificationCenter postIphoneSetupAccount];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewdidload");
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = item;
    self.title = WizStrRecentNotes;
    [item release];
    [self reloadAllData];
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
