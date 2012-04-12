//
//  DocumentListViewControllerBaseNew.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-5.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "DocumentListViewControllerBaseNew.h"
#import "WizIndex.h"
#import "pinyin.h"
#import "WizGlobals.h"
#import "WizApi.h"
#import "WizSync.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizPhoneNotificationMessage.h"

#import "WizDocumentsByLocation.h"
#import "WizDownloadObject.h"
#import "ZipArchive.h"
#import "DocumentViewCtrollerBase.h"
#import "DocumentListViewCell.h"
#import "NSDate-Utilities.h"
#import "WizNotification.h"

@implementation DocumentListViewControllerBaseNew
@synthesize accountUserID;
@synthesize tableArray;
@synthesize kOrder;
@synthesize currentDoc;
@synthesize isReverseDateOrdered;
@synthesize lastIndexPath;
@synthesize assertAlerView;
@synthesize sourceArray;
@synthesize hasNewDocument;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

#pragma mark - View lifecycle
- (void) optionsView
{
}

- (NSInteger) indexForDocumentInSource:(NSString*)documentGuid
{
    for (int i = 0;i <[self.sourceArray count]; i++) {
        WizDocument* doc = [self.sourceArray objectAtIndex:i];
        if ([documentGuid isEqualToString:doc.guid]) {
            return i;
        }
    }
    return -1;
}

- (NSIndexPath*) indexPathForDocumentInTable:(NSString*)documentGuid
{
    for (int i =0; i < [self.tableArray count]; i++) {
        for (int j = 0; j < [[self.tableArray objectAtIndex:i] count]; j++) {
            WizDocument* doc = [[self.tableArray objectAtIndex:i] objectAtIndex:j];
            if ([documentGuid isEqualToString:doc.guid]) {
                
                return [NSIndexPath indexPathForRow:j inSection:i];
            }
        }
    }
    return nil;
}

- (void) onDeleteDocument:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* documentGuid = [userInfo valueForKey:TypeOfPhoneDocumentGuid];
    if (nil == documentGuid) {
        return;
    }
    
    NSInteger sourceIndex = [self indexForDocumentInSource:documentGuid];
    if (-1 == sourceIndex) {
        return;
    }
    [self.sourceArray removeObjectAtIndex:sourceIndex];
    NSIndexPath* indexPath = [self indexPathForDocumentInTable:documentGuid];
    if (nil == indexPath) {
        return;
    }
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    [index deleteDocument:documentGuid];
    [index addDeletedGUIDRecord:documentGuid type:@"document"];
    [[self.tableArray objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
    if (![[self.tableArray objectAtIndex:indexPath.section] count]) {
        [self.tableArray removeObjectAtIndex:indexPath.section];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationLeft];
        return;
    }
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationLeft];
    
}
- (void) willReloadAllData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.kOrder = [index userTablelistViewOption];
    [self reloadAllData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    hasNewDocument = NO;
    

    if (nil == self.tableArray) {
        self.tableArray = [NSMutableArray array];
    }
    if ([WizGlobals WizDeviceVersion] < 5.0) {
        self.navigationController.delegate = self;
    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserID];
    self.kOrder = [index userTablelistViewOption];
    [self reloadAllData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
        else if ( kOrderCreatedDate == self.kOrder || kOrderReverseCreatedDate == self.kOrder )
        {
            WizDocument* doc = [[self.tableArray objectAtIndex:section] objectAtIndex:0];
            NSRange range = NSMakeRange(0, 7);
            NSString* sectionTitle = [doc.dateCreated substringWithRange:range];
            return sectionTitle;
        }
      else if (kOrderReverseDate == self.kOrder)
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
          else if ([date daysBeforeDate:[NSDate date]] >= 3 && [date daysBeforeDate:[NSDate date]] <7)
          {
              return NSLocalizedString(@"With in a week", nil);
          }
          else 
          {
              return WizStrOneWeekAgo;
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

- (void) orderByCreateDate
{
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.sourceArray];
    [self.tableArray removeAllObjects];
    NSRange range = NSMakeRange(0, 7);
    if (self.kOrder == kOrderCreatedDate) {
        [array sortUsingSelector:@selector(compareCreateDate:)];
    }
    else if (self.kOrder == kOrderReverseCreatedDate) {
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
    int docIndex = [self.sourceArray count]-1;
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
        case kOrderCreatedDate:
        case kOrderReverseCreatedDate:
            [self orderByCreateDate];
            break;
        default:
            break;
    }
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    if ([self.tableArray count] == 0) {
    }
    else {
        self.tableView.backgroundView = nil;
    }
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
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4.0, 320, 15)];
    [label setFont:[UIFont systemFontOfSize:13]];
    [sectionView addSubview:label];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self tableView:self.tableView titleForHeaderInSection:section];
    [label release];
    sectionView.alpha = 0.8f;
    return sectionView;
}

- (void) onSyncEnd
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
    [nc removeObserver:self name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
    [nc removeObserver:self name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
    [nc removeObserver:self name:[sync notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
    [self stopLoading];
    UIView* remindView = [self.view viewWithTag:10001];
    [remindView removeFromSuperview];
}


- (void) stopSyncing
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
    [[NSNotificationCenter defaultCenter] postNotificationName:[sync notificationName:WizGlobalStopSync] object: nil userInfo:nil];
}

-(void) syncGoing:(NSNotification*) nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* methodName = [userInfo objectForKey:@"sync_method_name"];
    NSNumber* total = [userInfo objectForKey:@"sync_method_total"];
    NSNumber* current = [userInfo objectForKey:@"sync_method_current"];
    NSString* objectName = [userInfo objectForKey:@"object_name"];
    NSNotificationCenter* ncCenter = [NSNotificationCenter defaultCenter];
    if ([methodName isEqualToString:SyncMethod_ClientLogin]) {
        self.refreshLabel.text = WizStrSigningIn;
    }
    
    else if ([methodName isEqualToString:SyncMethod_ClientLogout]) {
        self.refreshLabel.text =WizStrSigningOut;
    }
    
    
    else if ([methodName isEqualToString:SyncMethod_GetAllTags]) {
        self.refreshLabel.text = WizStrSyncingtags;
    }
    
    else if([methodName isEqualToString:SyncMethod_PostTagList])
    {
        self.refreshLabel.text = WizStrSyncingtags;
    }
    
    else if ([methodName isEqualToString:SyncMethod_DownloadDocumentList]) {
        [ncCenter postNotificationName:MessageOfTagViewVillReloadData object:nil userInfo:nil];
        self.refreshLabel.text = WizStrSyncingnoteslist;
    }
    
    else if ([methodName isEqualToString:SyncMethod_GetAttachmentList]) {
         [ncCenter postNotificationName:MessageOfDocumentlistWillReloadData object:nil];
        self.refreshLabel.text = WizStrSyncingattachmentlist;
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetAllCategories])
    {
        if ([current isEqualToNumber:total]) {
            [ncCenter postNotificationName:MessageOfFolderViewVillReloadData object:nil userInfo:nil];
        }
        self.refreshLabel.text = WizStrSyncingfolders;
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetUserInfo])
    {
        self.refreshLabel.text = WizStrSyncinguserinformation;
    }
    
    else if ( [methodName isEqualToString:SyncMethod_UploadDeletedList])
    {
        self.refreshLabel.text = WizStrSyncingdeletednotes;
    }
    
    else if ( [methodName isEqualToString:SyncMethod_DownloadDeletedList])
    {
        self.refreshLabel.text =WizStrSyncingdeletednotes;
    }
    else if ([methodName isEqualToString:SyncMethod_UploadObject]) {
        self.refreshLabel.text = WizStrUploadingnotes;
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
                                            WizStrUploadsuccessfully];
        }
    }
   
    if ([methodName isEqualToString:SyncMethod_DownloadObject]) {
        self.refreshLabel.text = WizStrDownloadingNotes;
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
                                           WizStrDownloadSuccessfully];        }
    }
    return;
}

- (void) displayProcessInfo
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
}
-(void) refresh
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserID];
    if( ![sync startSync])
    {
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
    self.currentDoc = nil;
	[docView release];
}

- (void) tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
    WizDocument* doc = [[self.tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    self.currentDoc = doc;
    [self viewDocument];
    self.lastIndexPath = indexPath;
}


- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WizDocument* doc = [[self.tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:doc.guid forKey:TypeOfPhoneDocumentGuid];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPhoneDeleteDocument object:nil userInfo:userInfo];
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
    return  CELLHEIGHTWITHABSTRACT;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [WizNotificationCenter removeObserver:self];
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
        
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeleteDocument:) name:MessageOfPhoneDeleteDocument object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willReloadAllData) name:MessageOfDocumentlistWillReloadData object:nil];
    }
    return self;
}
@end
