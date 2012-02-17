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
#import "pinyin.h"
@implementation WizPadListTableControllerBase
@synthesize landscapeDocumentsArray;
@synthesize portraitDocumentsArray;
@synthesize isLandscape;
@synthesize sourceArray;
@synthesize accountUserID;
@synthesize kOrderIndex;
@synthesize tableArray;
- (void) dealloc
{
    self.accountUserID = nil;
    self.sourceArray = nil;
    self.landscapeDocumentsArray = nil;
    self.portraitDocumentsArray = nil;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (NSArray*) arrayToLoanscapeCellArray:(NSArray*)source
{
    int documentCount = [source count];
    NSMutableArray* retArray = [NSMutableArray array];
    for (int docIndex = 0; docIndex < documentCount; ) {
        NSMutableArray* cellArray = [NSMutableArray array];
        for (int i =docIndex; i < documentCount; i++) {
            if ([cellArray count] == 4) {
                [retArray addObject:cellArray];
                docIndex = i;
                break;
            } else if (i == documentCount -1)
            {
                [cellArray addObject:[source objectAtIndex:i]];
                [retArray addObject:cellArray];
                docIndex = i+1;
                break;
            }
            [cellArray addObject:[source objectAtIndex:i]];
        }
    }
    return retArray;
}

- (NSArray*) arrayToPotraitCellArraty:(NSArray*)source
{
    int documentCount = [source count];
    NSMutableArray* retArray = [NSMutableArray array];
    for (int docIndex = 0; docIndex < documentCount; ) {
        NSMutableArray* cellArray = [NSMutableArray array];
        for (int i =docIndex; i < documentCount; i++) {
            if ([cellArray count] == 3) {
                [retArray addObject:cellArray];
                docIndex = i;
                break;
            } else if (i == documentCount -1)
            {
                [cellArray addObject:[source objectAtIndex:i]];
                [retArray addObject:cellArray];
                docIndex = i+1;
                break;
            }
            [cellArray addObject:[source objectAtIndex:i]];
        }
    }
    return retArray;
}
//data source delegate
- (void) reloadDocuments
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    NSMutableArray* arr = [[index recentDocuments] mutableCopy];
    self.sourceArray = arr;
    [arr release];
}
- (void) orderByReverseDate
{
    NSMutableArray* array = [self.sourceArray mutableCopy];
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
    [array release];
    
}
- (void) orderByDate
{
    NSMutableArray* array = [[self.sourceArray mutableCopy] autorelease];
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
    int docIndex = [self.sourceArray count]-1;
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
    NSMutableArray* array = [[self.sourceArray mutableCopy] autorelease];
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
- (void) reloadAllData
{
    [self reloadDocuments];
    if (![self.sourceArray count]) {
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
        remindLabel.text = NSLocalizedString(@"You don't have any notes \n Tap new note to get started!", nil);
        remindLabel.textAlignment = UITextAlignmentCenter;
        remindLabel.textColor = [UIColor lightTextColor];
        remindLabel.font= [UIFont systemFontOfSize:35];
        remindLabel.backgroundColor = [UIColor clearColor];;
        self.tableView.backgroundView = back;
    }
    else
    {
        self.tableView.backgroundView = nil;
    }
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
            break;
        default:
            break;
    }
    [self.landscapeDocumentsArray removeAllObjects];
    [self.portraitDocumentsArray removeAllObjects];
    for (NSMutableArray* each in self.tableArray) {
        [self.landscapeDocumentsArray addObject:[self arrayToLoanscapeCellArray:each]];
        [self.portraitDocumentsArray addObject:[self arrayToPotraitCellArraty:each]];
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor= [UIColor grayColor];
    if (nil == self.landscapeDocumentsArray) {
        self.landscapeDocumentsArray = [NSMutableArray array];
    }
    if (nil == self.portraitDocumentsArray) {
        self.portraitDocumentsArray = [NSMutableArray array];
    }
    
    if (nil == self.tableArray) {
        self.tableArray = [NSMutableArray array];
    }
    self.isLandscape = UIInterfaceOrientationIsLandscape((self.interfaceOrientation));
    self.kOrderIndex = kOrderReverseDate;
    [self reloadAllData];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddNewDocument:) name:MessageOfPadNewDocument object:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.isLandscape) {
        return [self.landscapeDocumentsArray count];
    }
    else
    {
        return [self.portraitDocumentsArray count];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.isLandscape) {
        return [[self.landscapeDocumentsArray objectAtIndex:section] count]  ;
    }
    else
    {
        return [[self.portraitDocumentsArray objectAtIndex:section] count];
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
    NSDictionary* userInfo = [nc userInfo];
    WizDocument* doc = [userInfo valueForKey:TypeOfDocumentKeyString];
    [self.sourceArray insertObject:doc atIndex:0];
    [self reloadAllData];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfPadNewDocument object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAddNewDocument:) name:MessageOfPadNewDocument object:nil];
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
    if (self.isLandscape) {
        [cell setDocuments:[[self.landscapeDocumentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell setDocuments:[[self.portraitDocumentsArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    }
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
        else if (kOrderReverseDate == self.kOrderIndex)
        {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSDate* date = [WizGlobals sqlTimeStringToDate:doc.dateModified];
            if ([date isToday]) {
                return NSLocalizedString(@"Today", nil);
            }
            else if( [date isYesterday])
            {
                return NSLocalizedString(@"Yesterday", nil);
            }
            else if ([[date dateByAddingDays:2] isToday])
            {
                return NSLocalizedString(@"The Day Before Yesterday", nil);
            }
            else if ([date isThisWeek])
            {
                return NSLocalizedString(@"Within A Week", nil);
            }
            else 
            {
                return NSLocalizedString(@"A Week Ago", nil);
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

@end
