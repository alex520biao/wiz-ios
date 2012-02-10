//
//  DocumentListViewControllerBaseNew.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DocumentListViewControllerBaseNew.h"
#import "WizIndex.h"
#import "pinyin.h"
#import "WizGlobals.h"
#import "WizApi.h"
#import "WizSync.h"
#import "Globals/WizGlobalData.h"
#import "Globals/WizIndex.h"
#import "Globals/WizGlobals.h"
#import "WizPhoneNotificationMessage.h"

#import "Globals/WizDocumentsByLocation.h"
#import "WizDownloadObject.h"
#import "Globals/ZipArchive.h"
#import "SortOptionsView.h"
#import "DocumentViewCtrollerBase.h"
#import "PickViewController.h"
#import "FoldersViewControllerNew.h"
#import "TagsListTreeControllerNew.h"
#import "DocumentListViewCell.h"
#import "NSDate-Utilities.h"

@implementation DocumentListViewControllerBaseNew
@synthesize accountUserID;
@synthesize tableArray;
@synthesize kOrder;
@synthesize currentDoc;
@synthesize isReverseDateOrdered;
@synthesize lastIndexPath;
@synthesize assertAlerView;
@synthesize sourceArray;
- (void) dealloc
{
    self.tableArray = nil;
    self.sourceArray = nil;
    self.accountUserID = nil;
    self.currentDoc = nil;
    self.isReverseDateOrdered = NO;
    self.lastIndexPath = nil;
    self.assertAlerView = nil;
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
    [super didReceiveMemoryWarning];

}

#pragma mark - View lifecycle
- (void) optionsView
{
    SortOptionsView* optionsView = [[[SortOptionsView alloc] init] autorelease];
    optionsView.delegate = self;
    [self.navigationController pushViewController:optionsView animated:YES];
}
- (void) addNewDocument:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    WizDocument* newDocument = [userInfo valueForKey:TypeOfWizDocumentData];
    [self.sourceArray insertObject:newDocument atIndex:0];
    if ([self.tableArray count]) {
        NSDate * date = [WizGlobals sqlTimeStringToDate:[[[self.tableArray objectAtIndex:0] objectAtIndex:0] dateModified]];
        if ([date isToday]) {
            [[self.tableArray objectAtIndex:0] insertObject:newDocument atIndex:0];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        }
        else
        {
            NSMutableArray* array = [NSMutableArray array];
            [array addObject:newDocument];
            [self.tableArray insertObject:array atIndex:0];
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
    else
    {
        NSMutableArray* array = [NSMutableArray array];
        [array addObject:newDocument];
        [self.tableArray insertObject:array atIndex:0];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationLeft];
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addNewDocument:) name:MessageOfNewDocument object:nil];
    if(0 == self.kOrder)
    {
        self.kOrder = kOrderReverseDate;
        self.isReverseDateOrdered = NO;
    }
    if (nil == self.tableArray) {
        self.tableArray = [NSMutableArray array];
    }
    
    if (![WizGlobals WizDeviceIsPad]) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:51.0/255 green:141.0/255 blue:201.0/255 alpha:1.0];
        if (![WizGlobals WizDeviceIsPad]) {
            if ([WizGlobals WizDeviceVersion] < 5.0) {
                self.navigationController.delegate = self;
            }
            UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"View Options",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(optionsView)];
            self.navigationItem.rightBarButtonItem = item;
            [item release];
        }
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfNewDocument object:nil];
    if ([WizGlobals WizDeviceVersion] < 5.0) {
        self.navigationController.delegate = nil;
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    if (self.lastIndexPath != nil) {

        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.lastIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        self.lastIndexPath = nil;
    }
    else
    {
        if (!self.isReverseDateOrdered) {
            [self reloadAllData];
        }
    }
    for (UIView* each in self.view.subviews) {
        if (each.frame.size.width == 21.0) {
            each.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0];
        }
    }
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [self.tableArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.tableArray objectAtIndex:section] count];
}

//return custom cell 
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* CellIdentifier = @"DocumentCell";
    DocumentListViewCell *cell = (DocumentListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    WizDocument* doc = [[self.tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[DocumentListViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        cell.accoutUserId = self.accountUserID;
    }
    cell.interfaceOrientation = self.interfaceOrientation;
    cell.doc = doc;
    [cell performSelectorOnMainThread:@selector(prepareForAppear) withObject:nil waitUntilDone:YES];
    return cell;
}

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
      if(kOrderDate == self.kOrder )
      {
          WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
          NSRange range = NSMakeRange(0, 7);
          NSString* sectionTitle = [doc.dateModified substringWithRange:range];
          return sectionTitle;
      }
      else if (kOrderReverseDate == self.kOrder)
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
      else if(kOrderFirstLetter == self.kOrder || kOrderReverseFirstLetter == self.kOrder)
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


//- (NSArray*) sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    
//    NSMutableArray* arr = [NSMutableArray array];

//    for (NSArray* each in self.tableArray) {
//        WizDocument* doc = [each objectAtIndex:0];
//        if(kOrderDate == self.kOrder || kOrderReverseDate == self.kOrder)
//        {
//            [arr addObject:@""];
//        }
//        else if(kOrderFirstLetter == self.kOrder || kOrderReverseFirstLetter == self.kOrder)
//        {
//            NSString* firstLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([doc.title characterAtIndex:0])] uppercaseString];
//            [arr addObject:firstLetter];
//        }
//    }
//    return arr;
//
//}
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
    self.isReverseDateOrdered = YES;
    
}

- (void) reloadAllData
{
    [self reloadDocuments];
    switch (self.kOrder) {
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
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}


- (void) orderByDate
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.sourceArray];
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
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.sourceArray];
    if (kOrderFirstLetter == self.kOrder) {
        [array sortUsingSelector:@selector(compareWithFirstLetter:)];
    }
    else if (kOrderReverseFirstLetter == self.kOrder)
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

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImageView* sectionView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 20)] autorelease];
    sectionView.image = [UIImage imageNamed:@"tableSectionHeader"];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:16]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    [label release];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    return sectionView;
}



- (void) onSyncEnd
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
    [self stopLoading];
    [nc postNotificationName:MessageOfTagViewVillReloadData object:nil userInfo:nil];
    [nc postNotificationName:MessageOfFolderViewVillReloadData object:nil userInfo:nil];
    UIView* remindView = [self.view viewWithTag:10001];
    [remindView removeFromSuperview];
    [self reloadAllData];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if( buttonIndex == 0 ) //Edit
	{
		return;
	}else
    {
        WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
        [[NSNotificationCenter defaultCenter] postNotificationName:[sync notificationName:WizGlobalStopSync] object: nil userInfo:nil];
    }
    self.assertAlerView = nil;
}

- (void) stopSyncing
{
    self.assertAlerView = [[[UIAlertView alloc] 
                           initWithTitle:NSLocalizedString(@"Please Confirm",nil)
                           message:NSLocalizedString(@"The synchronizing proceess will stop!",nil)
                           delegate:self 
                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                           otherButtonTitles:NSLocalizedString(@"OK", nil), nil] autorelease];
    [self.assertAlerView show];
    
}

-(void) syncGoing:(NSNotification*) nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* methodName = [userInfo objectForKey:@"sync_method_name"];
    NSNumber* total = [userInfo objectForKey:@"sync_method_total"];
    NSNumber* current = [userInfo objectForKey:@"sync_method_current"];
    NSString* objectName = [userInfo objectForKey:@"object_name"];
    
    if ([methodName isEqualToString:SyncMethod_ClientLogin]) {
        self.refreshLabel.text = NSLocalizedString(@"logining", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in logining", nil);
            
        }
        else
        {
            self.refreshDetailLabel.text = NSLocalizedString(@"begin in logging", nil);
        }
    }
    
    else if ([methodName isEqualToString:SyncMethod_ClientLogout]) {
        self.refreshLabel.text = NSLocalizedString(@"loging out", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in loging out", nil);
            self.refreshDetailLabel.text = @"";
           
        }
        else
        {
             self.refreshDetailLabel.text = NSLocalizedString(@"begin in loging out", nil);
        }
    }
    
    
    else if ([methodName isEqualToString:SyncMethod_GetAllTags]) {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing the tags", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succedd in downloading the tags", nil);
        }
        else
        {
//            NSString* display = [NSString stringWithFormat:@"%@ %d ,%@ %d",
//                                 NSLocalizedString(@"begin version is",nil),
//                                 [total intValue],
//                                 NSLocalizedString(@"request count is", nil),
//                                 [current intValue]];
            NSString* display = @"......";
            self.refreshDetailLabel.text= display;
        }
    }
    
    else if([methodName isEqualToString:SyncMethod_PostTagList])
    {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing the tags", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succedd in uploading the tags", nil);
        }
        else
        {
            self.refreshDetailLabel.text= NSLocalizedString(@"uploading the tags", nil);
        }
    }
    
    else if ([methodName isEqualToString:SyncMethod_DownloadDocumentList]) {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing document list", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in synchronizing document list", nil);
        }
        else
        {
//            NSString* display = [NSString stringWithFormat:@"%@ %d ,%@ %d",
//                                 NSLocalizedString(@"begin version is",nil),
//                                 [total intValue],
//                                 NSLocalizedString(@"request count is", nil),
//                                 [current intValue]];
             NSString* display = @"......";
            self.refreshDetailLabel.text= display;
        }
    }
    
    else if ([methodName isEqualToString:SyncMethod_GetAttachmentList]) {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing attachment list", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in downloading attachment list", nil);
        }
        else
        {
//            NSString* display = [NSString stringWithFormat:@"%@ %d ,%@ %d",
//                                 NSLocalizedString(@"begin version is",nil),
//                                 [total intValue],
//                                 NSLocalizedString(@"request count is", nil),
//                                 [current intValue]];
             NSString* display = @"......";
            self.refreshDetailLabel.text= display;
        }
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetAllCategories])
    {
        self.refreshLabel.text = NSLocalizedString(@"synchronize folder list", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in synchronizing folder list", nil);
        } 
        else
        {
            self.refreshDetailLabel.text = NSLocalizedString(@"synchronizing folder list", nil);
        }
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetUserInfo])
    {
        self.refreshLabel.text = NSLocalizedString(@"synchronize user's info", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in synchronizing folder list", nil);
        } 
        else
        {
            self.refreshDetailLabel.text = NSLocalizedString(@"synchronizing user's info", nil);
        }
    }
    
    else if ( [methodName isEqualToString:SyncMethod_UploadDeletedList])
    {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing deleted object", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in uploading deleted object", nil);
        } 
        else
        {
            self.refreshDetailLabel.text = NSLocalizedString(@"uploading deleted object", nil);
        }
    }
    
    else if ( [methodName isEqualToString:SyncMethod_DownloadDeletedList])
    {
        self.refreshLabel.text = NSLocalizedString(@"synchronizing deleted object", nil);
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = NSLocalizedString(@"succeed in downloading deleted object", nil);
        } 
        else
        {
            self.refreshDetailLabel.text = NSLocalizedString(@"downloading deleted object", nil);
        }
    }
    
    
    
    
    else if ([methodName isEqualToString:SyncMethod_UploadObject]) {
        self.refreshLabel.text = NSLocalizedString(@"Uploading Object", nil);
        NSRange range = NSMakeRange(0, 20);
        NSString* displayName = nil;
        if (objectName.length >= 20) {
             displayName = [objectName substringWithRange:range];
        }
        else
        {
            displayName = objectName;
        }
        self.refreshDetailLabel.text = [NSString stringWithFormat:@"%@ %d%%",displayName,(int)([current floatValue]/[total floatValue]*100)];
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text = [NSString stringWithFormat:@"%@ %@",
                                            displayName,
                                            NSLocalizedString(@"uploaded successfully", nil)];
        }
    }
   
    if ([methodName isEqualToString:SyncMethod_DownloadObject]) {
        self.refreshLabel.text = NSLocalizedString(@"downloading the doument data", nil);
        NSRange range = NSMakeRange(0, 20);
        NSString* displayName = nil;
        if (objectName.length >= 20) {
            displayName = [objectName substringWithRange:range];
        }
        else
        {
            displayName = objectName;
        }
        self.refreshDetailLabel.text = [NSString stringWithFormat:@"%@ %d%%",displayName,(int)([current floatValue]/[total floatValue]*100)];
        if ([total isEqualToNumber:current]) {
            self.refreshDetailLabel.text =[NSString stringWithFormat:@"%@ %@",
                                           displayName,
                                           NSLocalizedString(@"downloaded successfully", nil)];        }
    }
    return;
}

- (void) displayProcessInfo
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	[nc removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
}
-(void) refresh
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
    if( ![sync startSync])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Synchronizing Error", nil)
                                                        message:NSLocalizedString(@"There is anthoer synchronizing process already!", nil)
                                                       delegate:nil 
                                              cancelButtonTitle:@"ok" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self stopLoading];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
   
}
- (void) viewDocument
{
	if (!self.currentDoc)
		return;
	DocumentViewCtrollerBase* docView = [[DocumentViewCtrollerBase alloc] initWithNibName:@"DocumentViewCtrollerBase" bundle:nil];
	docView.accountUserID = self.accountUserID;
	docView.doc = self.currentDoc;
    docView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:docView animated:YES];
	[docView release];
}

- (void) tableView: (UITableView *)tableView
didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    self.currentDoc = doc;
    [self viewDocument];
    self.lastIndexPath = indexPath;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WizDocument* doc = [[self.tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        [index deleteDocument:doc.guid];
        [index addDeletedGUIDRecord:doc.guid type:@"document"];
        [[self.tableArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
        if (![[self.tableArray objectAtIndex:indexPath.section] count]) {
            [self.tableArray removeObjectAtIndex:indexPath.section];
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
            return;
        }
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.navigationController == navigationController) {
        [viewController viewWillAppear:animated];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  CELLHEIGHTWITHABSTRACT+5;
}
@end
