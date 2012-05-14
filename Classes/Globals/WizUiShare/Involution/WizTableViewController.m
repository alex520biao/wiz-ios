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


NSComparisonResult ReverseComparisonResult(NSComparisonResult result)
{
    if (result > 0) {
        return -1;
    }
    else if (result < 0) {
        return 1;
    }
    else {
        return 0;
    }
    
}


@interface WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocument:(WizDocument*)doc mask:(WizTableOrder)mask;
-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask;
@end

@implementation WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocumentOrder:(WizDocument*)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
            return [self compareModifiedDate:doc];
        case kOrderReverseDate:
            return  [self compareModifiedDate:doc];
        case kOrderCreatedDate:
            return [self compareCreateDate:doc];
        case kOrderReverseCreatedDate:
            return [self compareCreateDate:doc];
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return  [self.title compareFirstCharacter:doc.title];
        default:
            break;
    }
    return -NSUIntegerMax;
}
-(NSComparisonResult) compareDocument:(WizDocument *)doc mask:(WizTableOrder)mask
{
    return ReverseComparisonResult([self compareDocumentOrder:doc mask:mask]);
}
- (NSComparisonResult) reverseDateGroup:(NSDate*)d1 date2:(NSDate*)d2
{
    if ([d1 isToday]) {
        if ([d2 isToday]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isYesterday])
    {
        if ([d2 isYesterday]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]]) 
    {
        if ([d2 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else if ([d1 isLaterThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d1 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:2]]) {
        if ([d2 isLaterThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d2 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:2]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else {
        if ([d1 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:7]] && [d2 isEarlierThanDate:[NSDate dateWithDaysBeforeNow:7]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
}

-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
            return [[self.dateModified stringYearAndMounth] compare:[self.dateModified stringYearAndMounth] ];
        case kOrderReverseDate:
            return [self reverseDateGroup:self.dateModified date2:doc.dateModified];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            return [[self.dateCreated stringYearAndMounth] compare:[self.dateCreated stringYearAndMounth]];
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return [self.title compareFirstCharacter:doc.title];
        default:
            break;
    }
    return 0;
}
@end

@interface NSMutableArray (WizSortDocument)
- (void) sortDocuments:(WizTableOrder)mask;
@end
@implementation NSMutableArray (WizSortDocument)

- (void) sortDocuments:(WizTableOrder)mask
{
    [self sortUsingComparator:(NSComparator)^(WizDocument* doc1, WizDocument* doc2)
     {
         return [doc1 compareDocument:doc2 mask:mask];
     }];
}
@end
@interface WizTableViewController ()
{
    NSTimer* updateArrayTimer;
}
@property (nonatomic, retain) NSTimer* updateArrayTimer;
- (void) showSyncButton;
@end
@implementation WizTableViewController
@synthesize kOrderIndex;
@synthesize tableSourceArray;
@synthesize updateArrayTimer;
- (void) showActivity
{
    UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0, 0.0, 30, 30)];
    [activity startAnimating];
    UIBarButtonItem* refreshing = [[UIBarButtonItem alloc] initWithCustomView:activity];
    refreshing.style = UIBarButtonItemStyleBordered;
    [activity release];
    self.navigationItem.rightBarButtonItem = refreshing;
    [refreshing release];
}
- (void) reloadSelf
{
    [[WizSyncManager shareManager] startSyncInfo];
    [self showActivity];
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
    [updateArrayTimer invalidate];
    [updateArrayTimer release];
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) reloadAllData
{
    self.kOrderIndex = [[WizSettings defaultSettings] userTablelistViewOption];
    NSMutableArray* sourceArray = [NSMutableArray arrayWithArray:[self reloadAllDocument]];
    [sourceArray sortDocuments:self.kOrderIndex];
    int count = 0;
    [self.tableSourceArray removeAllObjects];
    if ([sourceArray count] == 1) {
        [self.tableSourceArray addObject:[NSMutableArray arrayWithObject:[sourceArray lastObject]]];
        return;
    }
    
    for (int docIndx = 0; docIndx < [sourceArray count];) {
        @try {
            WizDocument* doc1 = [sourceArray objectAtIndex:docIndx];
            WizDocument* doc2 = [sourceArray objectAtIndex:docIndx+1];
            if ([doc1 compareToGroup:doc2 mask:self.kOrderIndex] != 0) {
                NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
                NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
                [self.tableSourceArray addObject:arr];
                count = docIndx+1;
            }
            docIndx++;
        }
        @catch (NSException *exception) {
            if (docIndx == [sourceArray count]-1) {
                WizDocument* doc1= [sourceArray objectAtIndex:[sourceArray count]-2];
                WizDocument* doc2 = [sourceArray lastObject];
                if ([doc1 compareToGroup:doc2 mask:self.kOrderIndex] != 0) {
                    NSMutableArray* arr = [NSMutableArray arrayWithObject:doc2];
                    [self.tableSourceArray addObject:arr];
                }
                else {
                    NSArray* subArr = [sourceArray subarrayWithRange:NSMakeRange(count, docIndx-count+1)];
                    NSMutableArray* arr = [NSMutableArray arrayWithArray:subArr];
                    [self.tableSourceArray addObject:arr];
                }
            }
            docIndx++;
            count = docIndx;
            continue;
        }
        @finally {
        }
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    WizDocument* doc = [[self.tableSourceArray objectAtIndex:section] firstObject];
    switch (self.kOrderIndex) {
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
        {
            if (doc.dateCreated != nil) {
                return [doc.dateCreated  stringYearAndMounth];
            }
            else {
                return @"dd";
            }
        }
            
        case kOrderDate:
        {
            if (doc.dateModified != nil ) {
                return [doc.dateModified stringYearAndMounth];
            }
            else {
                return @"dddd";
            }
        }
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return [WizGlobals pinyinFirstLetter:doc.title];
        case kOrderReverseDate:
        {
            NSDate* date = doc.dateModified;
            if ([date isToday] ) {
                return WizStrToday;
            }
            else if ([date isYesterday])
            {
                return WizStrYesterday;
            }
            else if ([date isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:2]])
            {
                return WizStrThedaybeforeyesterday;
            }
            else if ([date isLaterThanDate:[NSDate dateWithDaysBeforeNow:7]])
            {
                return WizStrWithInAWeek;
            }
            else {
                return WizStrOneWeekAgo;
            }

        }
        default:
            break;
    }
    return @"No Title";
}

- (void) reloadDocument:(WizDocument*)doc  indexPath:(NSIndexPath*)indexPath
{
    [[self.tableSourceArray objectAtIndex:indexPath.section] replaceObjectAtIndex:indexPath.row withObject:doc];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
}
- (void) didChangedSyncDescription:(NSString *)description
{
    if (nil != self.tableView.tableHeaderView) {
        UILabel* label = (UILabel*)self.tableView.tableHeaderView;
        label.text = description;
    }
}

- (void) buildTableviewHeader
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 40)];
    self.tableView.tableHeaderView = label;
    [label release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildTableviewHeader];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}
- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[WizSettings defaultSettings] userTablelistViewOption] != self.kOrderIndex) {
        [self reloadAllData];
    }
    [[WizSyncManager shareManager] setDisplayDelegate:self];
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
- (NSUInteger) indexOfInsertDocumentToArray:(WizDocument*)document :(NSArray*)arr
{
    for (NSUInteger docIndex = 0 ; docIndex < [arr count]; docIndex++) {
        WizDocument* doc = [arr objectAtIndex:docIndex];
        if ([document compareDocument:doc mask:self.kOrderIndex] >= 0) {
            return docIndex;
        }
    }
    return NSNotFound;
}
- (NSInteger) groupIndexOfDocument:(NSString*)documentGUID
{
    WizDocument* doc = [WizDocument documentFromDb:documentGUID];
    if (nil == doc) {
        return NSNotFound;
    }
    for (int arrIndex = 0; arrIndex < [self.tableSourceArray count]; arrIndex++)
    {
        NSMutableArray* docArr =[self.tableSourceArray objectAtIndex:arrIndex];
        if (![doc compareToGroup:[docArr objectAtIndex:0] mask:self.kOrderIndex]) 
        {
            return arrIndex;
        }
    }
    return NSNotFound;
}


- (NSIndexPath*) indexOfDocumentInTableSourceArray:(NSString*)documentGUID
{
    NSInteger section = [self groupIndexOfDocument:documentGUID];
    NSInteger row = NSNotFound;
    if (NSNotFound != section) {
        NSArray* arr = [tableSourceArray objectAtIndex:section];
        for (NSInteger docIndex = 0; docIndex < [arr count]; docIndex++) {
            if ([documentGUID isEqualToString:[[arr objectAtIndex:docIndex] guid]]) {
                row = docIndex;
                break;
            }
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (NSIndexPath*) indexPathOfDocument:(NSString*)document
{
    NSInteger section = NSNotFound;
    NSInteger row = NSNotFound;
    for (int i =0 ; i < [self.tableSourceArray count]; i++) {
        NSArray* array = [self.tableSourceArray objectAtIndex:i];
        for (int j = 0; j < [array count]; j++) {
            WizDocument* doc = [array objectAtIndex:j];
            if ([doc.guid isEqualToString:document]) {
                section = i;
                row = j;
                break;
            }
        }
    }
    return [NSIndexPath indexPathForRow:row inSection:section];
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
        [WizDocument deleteDocument:doc.guid];
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
    NSString* documentGUID = [WizNotificationCenter getDeleteDocumentGUIDFromNc:nc];
    if (documentGUID == nil || [documentGUID isEqualToString:@""]) {
        return;
    }
    NSIndexPath* docIndex = [self indexPathOfDocument:documentGUID];
    if (docIndex.section == NSNotFound || docIndex.row == NSNotFound)
    {
        return;
    }
    if ([self.tableSourceArray count]> 0) {
        if ([[self.tableSourceArray objectAtIndex:docIndex.section] count] > 0)
        {
            @synchronized(self.tableSourceArray)
            {
                [[self.tableSourceArray objectAtIndex:docIndex.section] removeObjectAtIndex:docIndex.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:docIndex] withRowAnimation:UITableViewRowAnimationRight];
            }
            
        }
        else {
            @synchronized(self.tableSourceArray)
            {
                [self.tableSourceArray removeObjectAtIndex:docIndex.section];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationFade];
            }
            
        }
    }
    
}

- (void) updateDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
    WizDocument* doc = [WizDocument documentFromDb:documentGUID];
    if (nil == doc)
    {
        return ;
    }
    @try {
        NSIndexPath* indexPath = [self indexOfDocumentInTableSourceArray:doc.guid];
        if (indexPath.row != NSNotFound && indexPath.section != NSNotFound) {
            [self reloadDocument:doc indexPath:indexPath];
        }
        else {
            [self insertDocument:doc indexPath:indexPath];
        }
    }
    @catch (NSException *exception) {
        return;
    }
    @finally {
        return;
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
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSArray* array = [self.tableView visibleCells];
    for (DocumentListViewCell* each in array) {
        [each prepareForAppear];
    }
}
@end
