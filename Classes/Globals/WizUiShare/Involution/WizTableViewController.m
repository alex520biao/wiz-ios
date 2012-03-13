//
//  WizTableViewController.m
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTableViewController.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "NSDate-Utilities.h"
#import "CommonString.h"
#import "WizTableVIewCell.h"

@interface WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocument:(WizDocument*)doc mask:(WizTableOrder)mask;
-(NSComparisonResult) compareToGroup:(WizDocument*)doc mask:(WizTableOrder)mask;
@end

@implementation WizDocument (WizTableViewControllerDocument)
-(NSComparisonResult) compareDocument:(WizDocument *)doc mask:(WizTableOrder)mask
{
    switch (mask) {
        case kOrderDate:
            return [self.dateModified compareDate:doc.dateModified];
        case kOrderReverseDate:
            return [doc.dateModified compareDate:self.dateModified];
        case kOrderCreatedDate:
            return [self.dateCreated compareDate:doc.dateCreated];
        case kOrderReverseCreatedDate:
            return [doc.dateCreated compareDate:self.dateCreated];
        case kOrderFirstLetter:
            return [self.title compareFirstCharacter:doc.title];
        case kOrderReverseFirstLetter:
            return [doc.title compareFirstCharacter:self.title];
        default:
            break;
    }
    return 0;
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
    else if ([d1 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:7]]) {
        if ([d2 isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:7]]) {
            return 0;
        }
        else {
            return -1;
        }
    }
    else {
        return 0;
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
            return [self dateBreakForGoup:self.dateCreated :doc.dateCreated];
        case kOrderReverseCreatedDate:
            return [self dateBreakForGoup:self.dateCreated :doc.dateCreated];
        case kOrderFirstLetter:
            return [self.title compareFirstCharacter:doc.title];
        case kOrderReverseFirstLetter:
            return [doc.title compareFirstCharacter:self.title];
        default:
            break;
    }
    return 0;
}
@end

@implementation NSString (WizTableViewControllerNSString)
- (NSComparisonResult) compareDate:(NSString*)str
{
    return [[WizGlobals sqlTimeStringToDate:self] isLaterThanDate:[WizGlobals sqlTimeStringToDate:str]];
}
- (NSComparisonResult) compareFirstCharacter:(NSString *)str
{
    return [[WizIndex pinyinFirstLetter:self] compare:[WizIndex pinyinFirstLetter:str]];
}
@end

@implementation WizTableViewController
@synthesize accountUserId;
@synthesize kOrderIndex;
@synthesize tableSourceArray;
- (void) dealloc
{
    self.accountUserId = nil;
    self.tableSourceArray = nil;
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
    [sourceArray sortUsingComparator:(NSComparator)^(WizDocument* doc1, WizDocument* doc2)
    {
        NSUInteger i = [doc1 compareDocument:doc2 mask:self.kOrderIndex];
        return i;
    }];
    
    int count = 0;
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
            NSLog(@"%@",exception.description);
            NSLog(@"%d",docIndx);
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
            NSRange rang = NSMakeRange(0, 7);
            return [doc.dateCreated substringWithRange:rang];
            break;
        }
        case kOrderDate:
        {
            NSRange rang = NSMakeRange(0, 7);
            return [doc.dateModified substringWithRange:rang];
            break;
        }
        case kOrderFirstLetter:
        case kOrderReverseFirstLetter:
        {
            return [WizIndex pinyinFirstLetter:doc.title];
        }
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
            else if ([date isEqualToDateIgnoringTime:[NSDate dateWithDaysBeforeNow:7]])
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.kOrderIndex = kOrderReverseDate;
    [self sortAllData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95;
}
@end
