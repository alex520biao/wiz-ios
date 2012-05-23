//
//  WizPadListTableControllerBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListTableControllerBase.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "NSDate-Utilities.h"
#import "WizPadNotificationMessage.h"
#import "WizNotification.h"
#import "pinyin.h"
#import <ifaddrs.h>
#import "WizDocument.h"
#import "WizDbManager.h"
#import "WizTableViewController.h"
#import "WizSettings.h"

@implementation WizPadListTableControllerBase
@synthesize isLandscape;
@synthesize kOrderIndex;
@synthesize tableArray;
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfChangeDocumentListOrderMethod object:nil];
    [WizNotificationCenter removeObserver:self];
    [WizNotificationCenter removeObserverForDeleteDocument:self];
    [tableArray release];
    [super dealloc];
}
- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        kOrderIndex = -1;
        self.tableArray = [NSMutableArray array];
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (NSArray*) reloadDocuments
{
    return [WizDocument recentDocuments];
}
- (void) reloadAllData
{
    NSArray* documents = [self reloadDocuments];
    if (![documents count]) {
        UIView* back = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768)];
       UILabel* remindLabel = [[UILabel alloc] initWithFrame:CGRectMake(414, 284, 200, 200)];;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        {
           remindLabel.frame = CGRectMake(314, 184, 400, 200);
        }
        else
        {
           remindLabel.frame = CGRectMake(184, 314, 400, 200);
        }
        [back addSubview:remindLabel];
        remindLabel.numberOfLines = 0;
        remindLabel.text = NSLocalizedString(@"You don't have any notes.\n Tap new note to get started!", nil);
        remindLabel.textAlignment = UITextAlignmentCenter;
        remindLabel.textColor = [UIColor lightTextColor];
        remindLabel.font= [UIFont systemFontOfSize:35];
        remindLabel.backgroundColor = [UIColor clearColor];;
        self.tableView.backgroundView = back;
        [back release];
        [remindLabel release];
    }
    else
    {
        self.tableView.backgroundView = nil;
        [self.tableArray removeAllObjects];
        [self.tableArray addObject:[NSMutableArray arrayWithArray:documents]];
        NSInteger order = [[WizSettings defaultSettings] userTablelistViewOption];
        [self.tableArray sortDocumentByOrder:order];
        [self.tableView reloadData];
        self.kOrderIndex = order;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor= [UIColor scrollViewTexturedBackgroundColor];
    self.isLandscape = UIInterfaceOrientationIsLandscape((self.interfaceOrientation));
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    if ([[WizSettings defaultSettings] userTablelistViewOption] != self.kOrderIndex) {
        [self reloadAllData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


- (void) didAnimateFirstHalfOfRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.tableView reloadData];
    [super didAnimateFirstHalfOfRotationToInterfaceOrientation:toInterfaceOrientation];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (self.isLandscape) {
        count = 4;
   }
    else
    {
        count = 3;
    }
    if ([[self.tableArray objectAtIndex:section] count]%count>0) {
        return  [[self.tableArray objectAtIndex:section] count]/count+1;
    }
    else {
        return [[self.tableArray objectAtIndex:section] count]/count  ;
    }

}
- (void) didSelectedDocument:(WizDocument*)doc
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:doc.guid forKey:TypeOfCheckDocumentListKey];
    [userInfo setObject:[NSNumber numberWithInt:-1] forKey:TypeOfCheckDocumentListType];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}
- (void)onAddNewDocument:(NSNotification*)nc
{
//    self.tableView.backgroundView = nil;
//    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
//    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
//    WizDocument* doc = [index documentFromGUID:documentGUID];
//    if (doc == nil) {
//        return;
//    }
//    if([self.tableArray count] >0)
//    {
//        [[self.tableArray objectAtIndex:0] insertObject:doc atIndex:0];
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else {
//        NSMutableArray* array = [NSMutableArray arrayWithObject:doc];
//        [self.tableArray addObject:array];
//        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//    }
}
- (void) didPadCellDidSelectedDocument:(WizDocument *)doc
{
    [self didSelectedDocument:doc];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WizPadAbstractCell";
    WizPadListCell *cell = (WizPadListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WizPadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectedDelegate = self;
    }
    NSUInteger documentsCount=0;
    if (self.isLandscape) {
        documentsCount = 4;
    }
    else
    {
        documentsCount = 3;
    }
    NSUInteger needLength = documentsCount*(indexPath.row+1);
    NSArray* sectionArray = [self.tableArray objectAtIndex:indexPath.section];
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([sectionArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, [sectionArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    cellArray = [sectionArray subarrayWithRange:docRange];
    cell.documents = cellArray;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setNeedsDisplay];
}

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PADABSTRACTVELLHEIGTH;
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray* array = [self.tableArray objectAtIndex:section];
    return [array description];
}

// interface  orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.isLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
- (void) onDeleteDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getDeleteDocumentGUIDFromNc:nc];
    NSLog(@"documentGUID is %@",documentGUID);
    if (documentGUID == nil || [documentGUID isEqualToString:@""]) {
        NSLog(@"nil");
        return;
    }
//    if (docIndex.section == NSNotFound)
//    {
//        return;
//    }
//    [[self.tableArray objectAtIndex:docIndex.section] removeObjectAtIndex:docIndex.row];
//    if ([[self.tableArray objectAtIndex:docIndex.section] count] > 0)
//    {
//        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationFade];
//    }
//    else {
//        [self.tableArray removeObjectAtIndex:docIndex.section];
//        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationFade];
//    }
}



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
        [WizNotificationCenter addObserverForNewDocument:self selector:@selector(onAddNewDocument:)];
        [WizNotificationCenter addObserverForDeleteDocument:self selector:@selector(onDeleteDocument:)];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:MessageOfChangeDocumentListOrderMethod object:nil];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:0];
        self.tableArray = [NSMutableArray array];
        [self.tableArray addObject:arr];
    }
    return self;
}
@end
