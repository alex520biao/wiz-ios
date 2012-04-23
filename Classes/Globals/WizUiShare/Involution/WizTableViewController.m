//
//  WizTableViewController.m
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"

#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "CommonString.h"
#import "WizTableVIewCell.h"
#import "WizNotification.h"
#define WizNotFound -2

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
        case kOrderReverseDate:
            return  [self.dateModified compareDate:doc.dateModified];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            return [self.dateCreated compareDate:doc.dateCreated];
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
    if ([WizIndex isReverseOrder:mask]) {
        return ReverseComparisonResult([self compareDocumentOrder:doc mask:mask]);
    }
    else {
        return [self compareDocumentOrder:doc mask:mask];   
    }
}
- (NSComparisonResult) reverseDateGroup:(NSString*)date1 :(NSString*)date2
{
    NSDate* d1 = [WizGlobals sqlTimeStringToDate:date1];
    NSDate* d2 = [WizGlobals sqlTimeStringToDate:date2];
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
- (NSComparisonResult) dateBreakForGoup:(NSString*)date1 :(NSString*)date2
{
    NSRange range = NSMakeRange(0, 7);
    return [[date1 substringWithRange:range] compare:[date2 substringWithRange:range] options:NSCaseInsensitiveSearch];
}
-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
            return [self dateBreakForGoup:self.dateModified :doc.dateModified];
        case kOrderReverseDate:
            return [self reverseDateGroup:self.dateModified :doc.dateModified];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            return [self dateBreakForGoup:self.dateCreated :doc.dateCreated];
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return [self.title compareFirstCharacter:doc.title];
        default:
            break;
    }
    return 0;
}
@end

@implementation NSString (WizTableViewControllerNSString)
- (NSComparisonResult) compareDate:(NSString*)str
{
    return [[WizGlobals sqlTimeStringToDate:self] compare:[WizGlobals sqlTimeStringToDate:str]];
}
- (NSComparisonResult) compareFirstCharacter:(NSString *)str
{
    return [[WizIndex pinyinFirstLetter:self] compare:[WizIndex pinyinFirstLetter:str]];
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

@implementation WizTableViewController
@synthesize accountUserId;
@synthesize kOrderIndex;
@synthesize tableSourceArray;
- (void) dealloc
{
    [accountUserId release];
    [tableSourceArray release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}
- (id) initWithAccountuserid:(NSString*)userId
{
    self = [super init];
    if (self) {
        self.accountUserId = userId;
        self.tableSourceArray = [NSMutableArray array];
        self.kOrderIndex = -1;
    }
    return self;
}
- (NSMutableArray*) reloadAllData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    return [NSMutableArray  arrayWithArray:[index recentDocuments]] ;
}

- (void) sortAllData
{
    NSMutableArray* sourceArray = [self reloadAllData];
    [sourceArray sortDocuments:self.kOrderIndex];
    int count = 0;
    [self.tableSourceArray removeAllObjects];
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
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    WizDocument* doc = [[self.tableSourceArray objectAtIndex:section] firstObject];
    switch (self.kOrderIndex) {
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
        {
            if (doc.dateCreated != nil) {
                return [[WizGlobals dateToSqlString:doc.dateCreated] substringToIndex:7];
            }
            else {
                return @"";
            }
        }
            
        case kOrderDate:
        {
            if (doc.dateModified != nil ) {
                return [[WizGlobals dateToSqlString:doc.dateModified] substringToIndex:7];
            }
            else {
                return @"";
            }
        }
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
            return [WizIndex pinyinFirstLetter:doc.title];
        case kOrderReverseDate:
        {
            NSDate* date = [WizGlobals sqlTimeStringToDate:doc.dateModified];
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
    return @"";
}
- (void) reloadSelf
{
    static int i = 0;
    if (i == 0) {
        i = self.kOrderIndex;
    }
    i++;
    if (i%7 == 0) {
        i = 1;
    }
    self.kOrderIndex = i;
    [self sortAllData];
    [self.tableView reloadData];
}
- (void) insertDocument:(NSNotification*)nc
{
    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:documentGUID];
    NSInteger updateSection = [self groupIndexOfDocument:documentGUID];
    if (updateSection == WizNotFound) {
        NSMutableArray* newArr = [NSMutableArray arrayWithObject:doc];
        [newArr addObject:doc];
        if ([WizIndex isReverseOrder:self.kOrderIndex]) {
            updateSection = 0;
        }
        else {
            updateSection = [tableSourceArray count];
        }
        [self.tableSourceArray insertObject:doc atIndex:updateSection];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:updateSection] withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        NSMutableArray* arr = [tableSourceArray objectAtIndex:updateSection];
        [arr addObject:doc];
        [arr sortDocuments:self.kOrderIndex];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:updateSection] withRowAnimation:UITableViewRowAnimationTop];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kOrderIndex = kOrderFirstLetter;
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(reloadSelf)];
    self.navigationItem.rightBarButtonItem = item;
    self.tableView.frame = CGRectMake(0.0, 0.0, 200, 480);
    [item release];
    [self sortAllData];
    [WizNotificationCenter addObserverWithKey:self selector:@selector(insertDocument:) name:MessageTypeOfNewDocument];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [WizNotificationCenter removeObserverWithKey:self name:MessageTypeOfNewDocument];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    WizTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.accountUserId];
    if (!cell) {
        cell = [[[WizTableViewCell alloc] initWithUserIdAndDocGUID:UITableViewCellStyleValue1 userId:self.accountUserId] autorelease];
    }
    WizDocument* document = [[self.tableSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.documemtGuid = document.guid;
    [cell setNeedsDisplay];
    return cell;
}
- (NSUInteger) indexOfInsertDocumentToArray:(WizDocument*)document :(NSArray*)arr
{
    for (NSUInteger docIndex = 0 ; docIndex < [arr count]; docIndex++) {
        WizDocument* doc = [arr objectAtIndex:docIndex];
        if ([WizIndex isReverseOrder:self.kOrderIndex]) {
            if ([document compareDocument:doc mask:self.kOrderIndex] >= 0) {
                return docIndex;
            }
        }
        else {
            if ([document compareDocument:doc mask:self.kOrderIndex] <=0) {
                return docIndex;
            }
        }
    }
    return WizNotFound;
}
- (NSInteger) groupIndexOfDocument:(NSString*)documentGUID
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:documentGUID];
    for (int arrIndex = 0; arrIndex < [self.tableSourceArray count]; arrIndex++) 
    {
        NSMutableArray* docArr =[self.tableSourceArray objectAtIndex:arrIndex];
        if (![doc compareToGroup:[docArr objectAtIndex:0] mask:self.kOrderIndex]) 
        {
            return arrIndex;
        }
    }
    return WizNotFound;
}


- (NSIndexPath*) indexOfDocumentInTableSourceArray:(NSString*)documentGUID
{
    NSInteger section = [self groupIndexOfDocument:documentGUID];
    NSInteger row = WizNotFound;
    if (WizNotFound != section) {
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

- (void) insertDocumentToTableArray:(NSString*)documentGUID
{

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    WizDocument* doc = [[self.tableSourceArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//    NSIndexPath* a = [self indexOfDocumentInTableSourceArray:doc.guid];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}
- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray* arr = [tableSourceArray objectAtIndex:indexPath.section];
        if ([arr count] == 1) {
            [self.tableSourceArray removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationTop];
            return;
        }
        [[self.tableSourceArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }
}
@end
