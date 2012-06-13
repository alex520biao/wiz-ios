//
//  WizTableVController.m
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"

#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizNotification.h"
#import "WizDbManager.h"
#import "DocumentListViewCell.h"
#import "WizSyncManager.h"
#import "DocumentViewCtrollerBase.h"
#import "WizSettings.h"
#import "MTStatusBarOverlay.h"
#import "WizAccountManager.h"

@interface WizTableViewController ()
- (void) showSyncButton;
@end
@implementation WizTableViewController
@synthesize kOrderIndex;
@synthesize tableSourceArray;
- (NSArray*) reloadAllDocument
{
    return nil;
}
+ (UIBarButtonItem*) syncBarButtonItem
{
    static UIBarButtonItem* share = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30, 30)];
        [activity startAnimating];
        share = [[UIBarButtonItem alloc] initWithCustomView:activity];
        share.style = UIBarButtonItemStyleBordered;
        [activity release];
    });
    return share;
}
- (void) showActivity
{
    self.navigationItem.rightBarButtonItem = [WizTableViewController syncBarButtonItem];
}
- (void) reloadSelf
{
    [self showActivity];
}

- (void) refresh
{
    [[[WizSyncManager shareManager] syncDataForGroup:[[WizAccountManager defaultManager] activeAccountGroupKbguid]] startSyncInfo];
    [self reloadSelf];
}

- (void) showSyncButton
{
    UIBarButtonItem* refresh = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sync"] style:UIBarButtonItemStyleBordered target:self action:@selector(reloadSelf)];
    self.navigationItem.rightBarButtonItem = refresh;
    [refresh release];
    
}
- (void) dealloc
{
    [tableSourceArray release];
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) reloadAllData
{
    self.kOrderIndex = [[WizSettings defaultSettings] userTablelistViewOption];
    NSMutableArray* sourceArray = [NSMutableArray arrayWithArray:[self reloadAllDocument]];
    [self.tableSourceArray removeAllObjects];
    [self.tableSourceArray addObject:sourceArray];
    [self.tableSourceArray sortDocumentByOrder:self.kOrderIndex];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[self.tableSourceArray objectAtIndex:section] description];
}
- (void) stopSyncing
{
    [[[WizSyncManager shareManager] activeGroupSync] stopSync];
}
- (void) didChangedSyncDescription:(NSString *)description
{
    if (description == nil || [description isBlock]) {
        WizSync* sync = [[WizSyncManager shareManager] syncDataForGroup:[[WizAccountManager defaultManager] activeAccountGroupKbguid]];
        if ([sync isSyncing]) {
            return;
        }
        self.tableView.tableHeaderView = nil;
        [self showSyncButton];
        [self stopLoading];
        return;
    }
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
    [super viewWillAppear:animated];
    [[WizSyncManager shareManager] setDisplayDelegate:self];
    WizSync* sync = [[WizSyncManager shareManager] syncDataForGroup:[[WizAccountManager defaultManager] activeAccountGroupKbguid]];
    if ([sync isSyncing]) {
        [self startLoadingAnimation];
        [self showActivity];
    }
    else {
        [self showSyncButton];
        [self stopLoading];
    }
    if ([[WizSettings defaultSettings] userTablelistViewOption] != self.kOrderIndex) {
        [self reloadAllData];
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSArray* array = [self.tableView visibleCells];
    for (DocumentListViewCell* each in array) {
        [each prepareForAppear];
    }
}
- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[WizSyncManager shareManager] setDisplayDelegate:nil];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    for (DocumentListViewCell* each in [self.tableView visibleCells]) {
        [each prepareForAppear];
    }
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableSourceArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableSourceArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DocumentCell";
    DocumentListViewCell *cell = (DocumentListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    WizDocument* doc = [[self.tableSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[DocumentListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.doc = doc;
    return cell;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentListViewCell* docCell = (DocumentListViewCell*)cell;
    [docCell prepareForAppear];
}
-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView* sectionView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 20)] autorelease];
    sectionView.image = [UIImage imageNamed:@"tableSectionHeader"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:13]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    [label release];
    sectionView.alpha = 0.8f;
    return sectionView;
}
- (void) viewDocument:(WizDocument*)doc
{
	DocumentViewCtrollerBase* docView = [[DocumentViewCtrollerBase alloc] init];
    docView.hidesBottomBarWhenPushed = YES;
    docView.doc = doc;
	[self.navigationController pushViewController:docView animated:YES];
	[docView release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.tableSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self viewDocument:doc];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WizDocument* doc = [[self.tableSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [WizDocument deleteDocument:doc];
    }
}
- (NSInteger) documentsCount
{
    NSInteger ret = 0;
    for (NSArray* each in self.tableSourceArray) {
        ret += [each count];
    }
    return ret;
}
- (void) onDeleteDocument:(NSNotification*)nc
{
    WizDocument* document = [WizNotificationCenter getWizDocumentFromNc:nc];
    if (document == nil) {
        return;
    }
    NSIndexPath* docIndex = [self.tableSourceArray removeDocument:document];
    if (docIndex != nil) {
        if (docIndex.row == WizDeletedSectionIndex) {
            [self.tableView beginUpdates];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:docIndex] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        
    }
}

- (void) updateDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
    if (documentGUID == nil) {
        return;
    }
    WizDocument* doc = [WizDocument documentFromDb:documentGUID];
    if (nil == doc) {
        return;
    }
    NSIndexPath* indexPath = [self.tableSourceArray updateDocument:doc];
    if (nil != indexPath) {
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    else {
        indexPath = [self.tableSourceArray insertDocument:doc];
        if (nil == indexPath) {
            return;
        }
        if (indexPath.section == WizNewSectionIndex) {
            [self.tableView beginUpdates];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
        else {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.tableView endUpdates];
        }
    }
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.tableSourceArray = [NSMutableArray array];
        [WizNotificationCenter addObserverForUpdateDocument:self selector:@selector(updateDocument:)];
        [WizNotificationCenter addObserverForDeleteDocument:self selector:@selector(onDeleteDocument:)];
        [WizNotificationCenter addObserverForUpdateDocumentList:self selector:@selector(reloadAllData)];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.kOrderIndex = -1;
        [self showSyncButton];
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
    }
    return self;
}
@end
