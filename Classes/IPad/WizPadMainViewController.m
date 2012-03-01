//
//  WizPadMainViewController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadMainViewController.h"
#import "WizPadListTableControllerBase.h"
#import "WizPadDocumentViewController.h"
#import "PadFoldersController.h"
#import "WizUiTypeIndex.h"
#import "WizPadNotificationMessage.h"
#import "PadTagController.h"
#import "NewNoteView.h"
#import "WizSync.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizPadEditNoteController.h"
#import "WizDictionaryMessage.h"
#import "UserSttingsViewController.h"
#import "SearchResultViewController.h"

#define LanscapeTableViewFrame     CGRectMake(0.0, 0.0, 768, 960)
@implementation WizPadMainViewController
@synthesize mainSegment;
@synthesize accountUserId;
@synthesize controllersArray;
@synthesize selectedControllerIndex;
@synthesize currentPoperController;
@synthesize refreshProcessLabel;
@synthesize refreshItem;
@synthesize stopRefreshItem;
@synthesize recentList;
@synthesize tagList;
@synthesize folderList;
@synthesize syncWillStop;
@synthesize refreshButton;
- (void) dealloc
{
    self.refreshButton = nil;
    self.tagList = nil;
    self.folderList = nil;
    self.recentList = nil;
    self.refreshItem = nil;
    self.stopRefreshItem = nil;
    self.currentPoperController = nil;
    self.controllersArray = nil;
    self.accountUserId = nil;
    self.mainSegment = nil;
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
- (void) changeController:(id) sender
{
    int willSelectedControllerIndex = -2;
    if ([sender isKindOfClass:[NSNumber class]]) {
        willSelectedControllerIndex = 0;
    }
    else
    {
        if ([sender selectedSegmentIndex] == self.selectedControllerIndex) {
            return;
        }
        else
        {
            willSelectedControllerIndex = [sender selectedSegmentIndex];
        }
    }
    switch (willSelectedControllerIndex) {
        case 2:
            if (nil == self.tagList) {
                self.tagList = [[[PadTagController alloc] init] autorelease];
                self.tagList.accountUserId = self.accountUserId;
                tagList.willToOrientation = self.interfaceOrientation;
            }
            self.view = tagList.view;

            self.selectedControllerIndex = 2;
            break;
        case 1:
            if (nil == self.folderList) {
                self.folderList = [[[PadFoldersController alloc] init] autorelease];
                self.folderList.accountUserId = accountUserId;
                folderList.willToOrientation = self.interfaceOrientation;
            }
            self.view = folderList.view;

            self.selectedControllerIndex = 1;
            break;
        case 0:
            if (nil == self.recentList) {
                self.recentList = [[[WizPadListTableControllerBase alloc] init] autorelease];
                self.recentList.accountUserID = accountUserId;
            }
            self.view = recentList.view;          
            self.selectedControllerIndex = 0;
            break;
        default:
            break;
    }
}



- (void) newNote
{
    WizPadEditNoteController* newNote = [[WizPadEditNoteController alloc] init];
    newNote.accountUserId = self.accountUserId;
    NSMutableDictionary* data = [NSMutableDictionary dictionary];
    [newNote prepareNewDocumentData:data];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    controller.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
}
- (void) changeTitle
{
    UIBarButtonItem* item = [self.toolbarItems objectAtIndex:2];
    [item setTitle:@"dddd"];
}
-(void) syncGoing:(NSNotification*) nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSString* methodName = [userInfo objectForKey:@"sync_method_name"];
    NSString* processText = @"";
    NSNumber* total = [userInfo objectForKey:@"sync_method_total"];
    NSNumber* current = [userInfo objectForKey:@"sync_method_current"];
    NSString* objectName = [userInfo objectForKey:@"object_name"];

    if ([methodName isEqualToString:SyncMethod_ClientLogin]) {
        processText = NSLocalizedString(@"Signing in", nil);
    }
    
    else if ([methodName isEqualToString:SyncMethod_ClientLogout]) {
        processText = NSLocalizedString(@"Signing out", nil);
    }
    
    
    else if ([methodName isEqualToString:SyncMethod_GetAllTags]) {
        processText = NSLocalizedString(@"Syncing tags", nil);
    }
    
    else if([methodName isEqualToString:SyncMethod_PostTagList])
    {
        processText = NSLocalizedString(@"Syncing tags", nil);
    }
    
    else if ([methodName isEqualToString:SyncMethod_DownloadDocumentList]) {
        processText = NSLocalizedString(@"Syncing notes list", nil);
    }
    
    else if ([methodName isEqualToString:SyncMethod_GetAttachmentList]) {
        processText = NSLocalizedString(@"Syncing attachment list", nil);
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetAllCategories])
    {
        processText = NSLocalizedString(@"Syncing folders", nil);
    }
    
    else if ( [methodName isEqualToString:SyncMethod_GetUserInfo])
    {
        processText = NSLocalizedString(@"Syncing user information", nil);
    }
    
    else if ( [methodName isEqualToString:SyncMethod_UploadDeletedList])
    {
        processText = NSLocalizedString(@"Syncing deleted notes", nil);
    }
    
    else if ( [methodName isEqualToString:SyncMethod_DownloadDeletedList])
    {
        processText = NSLocalizedString(@"Syncing deleted notes", nil);
    }
    else if ([methodName isEqualToString:SyncMethod_UploadObject]) {
        processText = NSLocalizedString(@"Uploading notes", nil);
        NSRange range = NSMakeRange(0, 20);
        NSString* displayName = nil;
        if (objectName.length >= 20) {
            displayName = [objectName substringWithRange:range];
        }
        else
        {
            displayName = objectName;
        }
        processText = [NSString stringWithFormat:@"%@ %d%%",displayName,(int)([current floatValue]/[total floatValue]*100)];
        if ([total isEqualToNumber:current]) {
            processText = [NSString stringWithFormat:@"%@ %@",
                                            displayName,
                                            NSLocalizedString(@"Upload successfully", nil)];
        }
    }
    
    if ([methodName isEqualToString:SyncMethod_DownloadObject]) {
        processText = NSLocalizedString(@"Downloading notes data", nil);
        NSRange range = NSMakeRange(0, 20);
        NSString* displayName = nil;
        if (objectName.length >= 20) {
            displayName = [objectName substringWithRange:range];
        }
        else
        {
            displayName = objectName;
        }
        processText = [NSString stringWithFormat:@"%@ %d%%",displayName,(int)([current floatValue]/[total floatValue]*100)];
        if ([total isEqualToNumber:current]) {
            processText=[NSString stringWithFormat:@"%@ %@",
                                           displayName,
                                           NSLocalizedString(@"download successfully", nil)];        }
    }
    if ([processText isEqualToString:@""]) {
        processText = @"...";
    }
    self.refreshProcessLabel.text = processText;
    return;
}
- (void) stopSyncByUser
{
    UIAlertView* alert = [[[UIAlertView alloc] 
                           initWithTitle:NSLocalizedString(@"Please confirm",nil)
                           message:NSLocalizedString(@"The sync process will stop!",nil)
                           delegate:self 
                           cancelButtonTitle:WizStrCancel
                           otherButtonTitles:WizStrOK, nil] autorelease];
    alert.delegate = self;
    [alert show];
}
- (void) onSyncEnd
{
    self.refreshProcessLabel.text = @"";
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:MessageOfPadFolderWillReload object:nil userInfo:nil];
    [nc postNotificationName:MessageOfPadTagWillReload object:nil userInfo:nil];
    WizSync* sync = [[WizGlobalData sharedData] syncData:self.accountUserId];
    [nc removeObserver:self name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil ];
    [nc removeObserver:self name:[sync notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
    [nc removeObserver:self name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
    self.syncWillStop = NO;
    [self.refreshButton removeTarget:self action:@selector(stopSyncByUser) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton addTarget:self action:@selector(refreshAccountBegin:) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshButton setImage:[UIImage imageNamed:@"sync_gray"] forState:UIControlStateNormal];
    [self.recentList reloadAllData];
    
}
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {

    }
    else
    {
        WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserId];
        self.syncWillStop = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:[sync notificationName:WizGlobalStopSync] object: nil userInfo:nil];
    }
}
- (void) refreshAccout
{
    WizSync* sync = [[WizGlobalData sharedData] syncData: self.accountUserId];
    if( ![sync startSync])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sync error", nil)
                                                        message:NSLocalizedString(@"Sync already in progress, please wait...", nil)
                                                       delegate:nil 
                                              cancelButtonTitle:WizStrOK 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncEndNotificationPrefix] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncEnd) name:[sync notificationName:WizSyncXmlRpcErrorNotificationPrefix] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncGoing:) name:[sync notificationName:WizGlobalSyncProcessInfo] object:nil];
}

- (void) refreshAccountBegin:(id) sender
{
    UIButton* btn = (UIButton*)sender;
    [btn removeTarget:self action:@selector(refreshAccountBegin:) forControlEvents:UIControlEventTouchUpInside];
//    [sender removeTarget:self action:@selector(refreshAccountBegin:)];
    [btn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(stopSyncByUser) forControlEvents:UIControlEventTouchUpInside];
    self.refreshProcessLabel.text = NSLocalizedString(@"Start syncing", nil);

    
    [self refreshAccout];
}
- (void) didChangedSortedOrder:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSNumber* orderIndex = [userInfo valueForKey:TypeOfChangeSortedOrderIndex];
    self.recentList.kOrderIndex = [orderIndex intValue];
    [self.currentPoperController dismissPopoverAnimated:YES];
    self.currentPoperController = nil;
    [recentList reloadAllData];
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.currentPoperController = nil;
}

- (void) popoverControllerWillDismiss
{
    [self.currentPoperController dismissPopoverAnimated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MessageOfPoperviewDismiss object:nil];
}

- (void) setAccountSettings:(id)sender
{
    if (nil != self.currentPoperController) {
        [currentPoperController dismissPopoverAnimated:YES];
    }
    UserSttingsViewController* settings = [[UserSttingsViewController alloc] initWithNibName:@"UserSttingsViewController" bundle:nil ];
    settings.accountUserId = self.accountUserId;
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:settings];
    [settings release];
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:controller];
    [controller release];
    self.currentPoperController = pop;
    [pop release];
    self.currentPoperController.delegate = self;
    self.currentPoperController.popoverContentSize = CGSizeMake(320, 600);
    [self.currentPoperController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popoverControllerWillDismiss) name:MessageOfPoperviewDismiss object:nil];
}
- (void) buildToolBar
{

    
    UIBarButtonItem* flexSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* newNoteItem = [[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"sync_gray"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0.0, 0.0, 44, 44);
    [btn addTarget:self action:@selector(refreshAccountBegin:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem* refreshItem_ = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.refreshButton = btn;
    self.refreshItem = refreshItem_;

    


    self.refreshProcessLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 44)] autorelease];
    [self.refreshProcessLabel setFont:[UIFont systemFontOfSize:13]];
    refreshProcessLabel.backgroundColor = [UIColor clearColor];
    refreshProcessLabel.textAlignment = UITextAlignmentRight;
    
     UIBarButtonItem* refreshItemInfo = [[UIBarButtonItem alloc] initWithCustomView:refreshProcessLabel];
    NSArray* arr = [NSArray arrayWithObjects:newNoteItem,flexSpaceItem,refreshItemInfo,refreshItem, nil];
    [self setToolbarItems:arr];
    [refreshItem_ release];
    [refreshItemInfo release];
    [newNoteItem release];
    [flexSpaceItem release];
}

- (void) buildNavigationItems
{
    UIBarButtonItem* settingItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"setting1"] style:UIBarButtonItemStyleBordered target:self action:@selector(setAccountSettings:)];
    self.navigationItem.leftBarButtonItem = settingItem;
    [settingItem release];
    
    UISearchBar* searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 200, 44)];
    searchBar.showsCancelButton = YES;
    UIBarButtonItem* searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBar];
    searchBar.delegate = self;
    self.navigationItem.rightBarButtonItem = searchItem;
    [searchItem release];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
}
- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  
}

-  (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:searchBar.text forKey:TypeOfCheckDocumentListKey];
    [userInfo setObject:[NSNumber numberWithInt:TypeOfKey] forKey:TypeOfCheckDocumentListType];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
- (void) buildMainSegment
{
    self.controllersArray = [NSMutableArray array] ;
    if (nil == self.mainSegment) {
        NSArray* arr = [NSArray arrayWithObjects:
                        NSLocalizedString(@"Recent notes", nil),
                        WizStrFolders,
                        WizStrTags,
                        nil];
        UISegmentedControl* main = [[UISegmentedControl alloc] initWithItems:arr];
        self.mainSegment = main;
        [main release];
    }
    self.mainSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [self.mainSegment addTarget:self action:@selector(changeController:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.mainSegment;
    [self changeController:[NSNumber numberWithInt:-1]];
}

- (void) willChangeUser
{
    [[WizGlobalData sharedData] removeAccountData:self.accountUserId];
    [self.currentPoperController dismissPopoverAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageOfPadLoginViewChangeUser object:nil userInfo:nil];
}

- (void) viewWillChange:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSNumber* interface = [userInfo valueForKey:TypeOfViewInterface];
    [self willAnimateRotationToInterfaceOrientation:[interface intValue] duration:0.5];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedControllerIndex = -1;
    [self buildMainSegment];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [nc addObserver:self selector:@selector(checkDocument:) name:TypeOfCheckDocument object:nil];
    [nc addObserver:self selector:@selector(willChangeUser) name:MessageOfPadChangeUser object:nil];
    [nc addObserver:self selector:@selector(viewWillChange:) name:MessageOfViewWillOrientent object:nil];
    [nc addObserver:self selector:@selector(newNote) name:MessageOfNewFirstDocument object:nil];
    [self buildToolBar];
    [self buildNavigationItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void) viewDidAppear:(BOOL)animated
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if ([index isFirstLog] ) {
        [self refreshAccountBegin:self.refreshButton];
        [index setFirstLog:YES];
    }
    self.mainSegment.selectedSegmentIndex = 0;
}
- (void) checkDocument:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSNumber* listType = [userInfo objectForKey:TypeOfCheckDocumentListType];
    NSString* listKey = [userInfo objectForKey:TypeOfCheckDocumentListKey];
    WizPadDocumentViewController* check = [[WizPadDocumentViewController alloc] init];
    check.accountUserId = self.accountUserId;
    check.listType = [listType intValue];
    check.documentListKey = listKey;
    [self.navigationController pushViewController:check animated:YES];
    [check release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (nil != self.recentList) {
        [recentList willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    if (nil != tagList) {
        [tagList willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
    if (nil != folderList) {
        [folderList willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}
@end
