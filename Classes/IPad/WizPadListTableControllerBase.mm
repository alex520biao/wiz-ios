//
//  WizPadListTableControllerBase.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadListTableControllerBase.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizPadListCell.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "NSDate-Utilities.h"
#import "DocumentListViewControllerBaseNew.h"
#import "WizPadNotificationMessage.h"
#import "WizSync.h"
#import "WizNotification.h"
#import "pinyin.h"
#import <ifaddrs.h>

#define WizNotFoundIndex    -2
@implementation WizPadListTableControllerBase
@synthesize isLandscape;
@synthesize accountUserID;
@synthesize kOrderIndex;
@synthesize tableArray;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (NSIndexPath*) indexPathForDocument:(NSString*)documentGUID
{
    for (int arrIndex = 0; arrIndex < [self.tableArray count]; arrIndex++) {
        NSArray* arr = [self.tableArray objectAtIndex:arrIndex];
        for (int docIndex = 0;docIndex < [arr count]; docIndex++) {
            WizDocument* doc = [arr objectAtIndex:docIndex];
            if ([doc.guid isEqualToString:documentGUID]) {
                return [NSIndexPath indexPathForRow:docIndex inSection:arrIndex];
            }
        }
    }
    return [NSIndexPath indexPathForRow:WizNotFoundIndex inSection:WizNotFoundIndex];
}
- (NSArray*) reloadDocuments
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    return [index recentDocuments];
}
- (void) orderByReverseDate
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self reloadDocuments]];
    [self.tableArray removeAllObjects];
    NSMutableArray* today = [NSMutableArray array];
    NSMutableArray* yestorday = [NSMutableArray array];
    NSMutableArray* dateBeforeYestorday = [NSMutableArray array];
    NSMutableArray* week = [NSMutableArray array];
    NSMutableArray* mounth = [NSMutableArray array];
    NSDate* todayDate = [NSDate date];
    for(int k = 0; k <[ array count]; k++)
    {
        WizDocument* doc = [array objectAtIndex:k];
        NSDate* date = [WizGlobals sqlTimeStringToDate:doc.dateModified];
        int daysBeforToday = [date daysBeforeDate:todayDate];
        if ([date isToday] )
        {
            [today addObject:doc];
        }
        else if ([date isYesterday])
        {
            [yestorday addObject:doc];
        }
        else if ([[date dateByAddingDays:2] isToday] )
        {
            [dateBeforeYestorday addObject:doc];
        }
        else if(daysBeforToday <7 )
        {
            [week addObject:doc];
        }
        else{
            [mounth addObject:doc];
        }
    }
    if ([today count]) {
        [self.tableArray addObject:today];
    }
    if ([yestorday count]) {
        [self.tableArray addObject:yestorday];
    }
    if ([dateBeforeYestorday count]) {
        [self.tableArray addObject:dateBeforeYestorday];
    }
    if ([week count]) {
        [self.tableArray addObject:week];
    }
    if ([mounth count]) {
        [self.tableArray addObject:mounth];
    }
    
}
- (void) orderByDate
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self reloadDocuments]];
    [self.tableArray removeAllObjects];
    NSRange range = NSMakeRange(0, 7);
    if ([array count] == 1) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        [sectionArray addObject:[array objectAtIndex:0]];
        [self.tableArray addObject:sectionArray];
        return;
    }
    if ([array count] == 0) {
        return;
    }
    int docIndex = [array count]-1;
    for (int i =0; i<12; i++) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        for(int k = docIndex; k >= 0; k--)
        {
            WizDocument* doc1 = [array objectAtIndex:k];
            WizDocument* doc2 = [array objectAtIndex:k-1];
            if(k == 1)
            {
                if ([[doc1.dateModified substringWithRange:range] isEqualToString:[doc2.dateModified substringWithRange:range]]) {
                    [sectionArray addObject:doc1];
                    [sectionArray addObject:doc2];
                    [self.tableArray addObject:sectionArray];
                } else
                {
                    [sectionArray addObject:doc1];
                    NSMutableArray* sectionArr = [NSMutableArray array];
                    [sectionArr addObject:doc2];
                    [self.tableArray addObject:sectionArray];
                    [self.tableArray addObject:sectionArr];
                }
                return;
            }
            if ([[doc1.dateModified substringWithRange:range] isEqualToString:[doc2.dateModified substringWithRange:range]]) {
                [sectionArray addObject:doc1];
            } else
            {
                [sectionArray addObject:doc1];
                [self.tableArray addObject:sectionArray];
                docIndex = k-1;
                break;
            }
            
        }
    }
}

- (void) orderByFirstLetter
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self reloadDocuments]];
    if (kOrderFirstLetter == self.kOrderIndex) {
        [array sortUsingSelector:@selector(compareWithFirstLetter:)];
    }
    else if (kOrderReverseFirstLetter == self.kOrderIndex)
    {
        [array sortUsingSelector:@selector(compareReverseWithFirstLetter:)];
    }
    [self.tableArray removeAllObjects];
    if ([array count] == 1) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        [sectionArray addObject:[array objectAtIndex:0]];
        [self.tableArray addObject:sectionArray];
        return;
    }
    if ([array count] == 0) {
        return;
    }
    int docIndex = 0;
    for (int i =0; i<26; i++) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        for(int k = docIndex; k <[ array count] - 1; k++)
        {
            WizDocument* doc1 = [array objectAtIndex:k];
            WizDocument* doc2 = [array objectAtIndex:k+1];
            
            if([[WizIndex pinyinFirstLetter:doc1.title] isEqualToString:[WizIndex pinyinFirstLetter:doc2.title]])
            {
                [sectionArray addObject:doc1];
                if (k == [array count] - 2) {
                    [sectionArray addObject:doc2];
                    [self.tableArray addObject:sectionArray];
                    docIndex = k+1;
                    break;
                }
            } else
            {
                [sectionArray addObject:doc1];
                [self.tableArray addObject:sectionArray];
                if (k == [array count] -2) {
                    NSMutableArray* sectionTempArray = [NSMutableArray array];
                    [sectionTempArray addObject:doc2];
                    [self.tableArray addObject:sectionTempArray];
                }
                docIndex = k+1;
                break;
            }
            
        }
    }
}

- (void) orderByCreateDate
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:[self reloadDocuments]];
    [self.tableArray removeAllObjects];
    NSRange range = NSMakeRange(0, 7);
    if (self.kOrderIndex == kOrderCreatedDate) {
        [array sortUsingSelector:@selector(compareCreateDate:)];
    }
    else if (self.kOrderIndex == kOrderReverseCreatedDate) {
        [array sortUsingSelector:@selector(compareReverseCreateDate:)];
    }
    if ([array count] == 1) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        [sectionArray addObject:[array objectAtIndex:0]];
        [self.tableArray addObject:sectionArray];
        return;
    }
    if ([array count] == 0) {
        return;
    }
    int docIndex = [array count]-1;
    for (int i =0; i<12; i++) {
        NSMutableArray* sectionArray = [NSMutableArray array];
        for(int k = docIndex; k >= 0; k--)
        {
            WizDocument* doc1 = [array objectAtIndex:k];
            WizDocument* doc2 = [array objectAtIndex:k-1];
            if(k == 1)
            {
                if ([[doc1.dateCreated substringWithRange:range] isEqualToString:[doc2.dateCreated substringWithRange:range]]) {
                    [sectionArray addObject:doc1];
                    [sectionArray addObject:doc2];
                    [self.tableArray addObject:sectionArray];
                } else
                {
                    [sectionArray addObject:doc1];
                    NSMutableArray* sectionArr = [NSMutableArray array];
                    [sectionArr addObject:doc2];
                    [self.tableArray addObject:sectionArray];
                    [self.tableArray addObject:sectionArr];
                }
                return;
            }
            if ([[doc1.dateCreated substringWithRange:range] isEqualToString:[doc2.dateCreated substringWithRange:range]]) {
                [sectionArray addObject:doc1];
            } else
            {
                [sectionArray addObject:doc1];
                [self.tableArray addObject:sectionArray];
                docIndex = k-1;
                break;
            }
            
        }
    }
}
- (void) reloadAllData
{
    if (![[self reloadDocuments] count]) {
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
    }
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.kOrderIndex = [index userTablelistViewOption];
    switch (self.kOrderIndex) {
        case kOrderDate:
            [self orderByDate];
            break;
        case kOrderFirstLetter:
            [self orderByFirstLetter];
            break;
        case kOrderReverseDate:
            [self orderByReverseDate];
            break;
        case kOrderReverseFirstLetter:
            [self orderByFirstLetter];
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            [self orderByCreateDate];
            break;
        default:
            break;
    }
}
- (void) reloadTableView
{
    [self reloadAllData];
    [self.tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor= [UIColor grayColor];
    if (nil == self.tableArray) {
        self.tableArray = [NSMutableArray array];
    }
    self.isLandscape = UIInterfaceOrientationIsLandscape((self.interfaceOrientation));
    [self reloadAllData];
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
//- (NSInteger) countOfLandscape
//{
//
//}
//- (NSInteger) countOfPortrait
//{
//    
//}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isLandscape) {
        return [self.tableArray count];
    }
    else
    {
        return [self.tableArray count];
    }
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
    self.tableView.backgroundView = nil;
    NSString* documentGUID = [WizNotificationCenter getNewDocumentGUIDFromMessage:nc];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    WizDocument* doc = [index documentFromGUID:documentGUID];
    if (doc == nil) {
        return;
    }
    if([self.tableArray count] >0)
    {
        [[self.tableArray objectAtIndex:0] insertObject:doc atIndex:0];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        NSMutableArray* array = [NSMutableArray arrayWithObject:doc];
        [self.tableArray addObject:array];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    WizPadListCell *cell = (WizPadListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[WizPadListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accountUserId = self.accountUserID;
        cell.owner = self;
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
    [cell setDocuments:cellArray];
    return cell;
}



#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PADABSTRACTVELLHEIGTH;
}
- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if(kOrderDate == self.kOrderIndex )
        {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSRange range = NSMakeRange(0, 7);
            NSString* sectionTitle = [doc.dateModified substringWithRange:range];
            return sectionTitle;
        }
        else if (kOrderCreatedDate == self.kOrderIndex || kOrderReverseCreatedDate == self.kOrderIndex) {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSRange range = NSMakeRange(0, 7);
            NSString* sectionTitle = [doc.dateCreated substringWithRange:range];
            return sectionTitle;
        }
        else if (kOrderReverseDate == self.kOrderIndex)
        {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSDate* date = [WizGlobals sqlTimeStringToDate:doc.dateModified];
            if ([date isToday]) {
                return WizStrToday;
            }
            else if( [date isYesterday])
            {
                return WizStrYesterday;
            }
            else if ([[date dateByAddingDays:2] isToday])
            {
                return WizStrThedaybeforeyesterday;
            }
            else if ([date isThisWeek])
            {
                return WizStrOneWeek;
            }
            else 
            {
                return WizStrOneWeekAgo;
            }
            
            
        }
        else if(kOrderFirstLetter == self.kOrderIndex || kOrderReverseFirstLetter == self.kOrderIndex)
        {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSString* firstLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([doc.title characterAtIndex:0])] uppercaseString];
            return firstLetter;
        } else
            return nil;
        
    }
    else
    {
        return nil;
    }
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
    NSIndexPath* docIndex = [self indexPathForDocument:documentGUID];
    if (docIndex.section == WizNotFoundIndex)
    {
        return;
    }
    [[self.tableArray objectAtIndex:docIndex.section] removeObjectAtIndex:docIndex.row];
    if ([[self.tableArray objectAtIndex:docIndex.section] count] > 0)
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationFade];
}
else {
    [self.tableArray removeObjectAtIndex:docIndex.section];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:docIndex.section] withRowAnimation:UITableViewRowAnimationFade];
}
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfChangeDocumentListOrderMethod object:nil];
    [WizNotificationCenter removeObserver:self];
    [WizNotificationCenter removeObserverForDeleteDocument:self];
    self.accountUserID = nil;
    [super dealloc];
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
