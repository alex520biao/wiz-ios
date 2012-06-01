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
#import "WizUiTypeIndex.h"
#import "WizPadNotificationMessage.h"
#import "NewNoteView.h"
#import "WizPadEditNoteController.h"
#import "WizDictionaryMessage.h"
#import "UserSttingsViewController.h"
#import "WizNotification.h"
#import "WizSyncManager.h"
#import "WizPadFoldersViewController.h"
#import "WizPadTagsViewController.h"
#import "WizFileManager.h"

#define LanscapeTableViewFrame     CGRectMake(0.0, 0.0, 768, 960)

@interface WizPadMainViewController ()
{
    UISegmentedControl* mainSegment;
    UIPopoverController* currentPoperController;
    NSArray* viewControllers;
    
    UIActivityIndicatorView* activityIndicator;
    
    BOOL isWillReloadFolderTable;
    BOOL isWillReloadTagTable;
}
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@end

@implementation WizPadMainViewController


- (void) dealloc
{
    [currentPoperController release];
    [mainSegment release];
    //
    activityIndicator = nil;
    [viewControllers release];
    viewControllers = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) willReloadTagTable
{
    isWillReloadTagTable = YES;
}
- (void) willReloadFolderTable
{
    isWillReloadFolderTable = YES;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [nc addObserver:self selector:@selector(viewWillChange:) name:MessageOfViewWillOrientent object:nil];
        
        [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadFolderTable) name:MessageTypeOfUpdateFolderTable];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadTagTable) name:MessageTypeOfUpdateTagTable];
        [WizNotificationCenter addObserverWithKey:self selector:@selector(newNoteWillDisappear) name:MessageTypeOfPadSyncInfoEnd];
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
    NSInteger selectedIndex = [sender selectedSegmentIndex];
    UIViewController* controller = [viewControllers objectAtIndex:selectedIndex];
    self.view = controller.view;
}

- (void) popoverController:(UIViewController*)controller fromBarButtonItem:(UIBarButtonItem*)item permittedArrowDirections:(UIPopoverArrowDirection)arrowDirection
{
    if (self.currentPoperController != nil) {
        [self.currentPoperController dismissPopoverAnimated:YES];
        self.currentPoperController = nil;
    }
    UIPopoverController* pop = [[UIPopoverController alloc] initWithContentViewController:controller];
    pop.delegate = self;
    self.currentPoperController = pop;
    pop.popoverContentSize = CGSizeMake(320, 600);
    [pop presentPopoverFromBarButtonItem:item permittedArrowDirections:arrowDirection animated:YES];
    [pop release];
}
- (void) newNote
{
    WizPadEditNoteController* newNote = [[WizPadEditNoteController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
    newNote.navigateDelegate = self;
    controller.view.frame = CGRectMake(0.0, 0.0, 1024, 768);
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
}

- (void) refreshAccout
{
    WizSyncManager* syncMan = [WizSyncManager shareManager];
    if( ![syncMan isSyncing])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSyncError
                                                        message:WizStrSyncAlreadyInProcess
                                                       delegate:nil 
                                              cancelButtonTitle:WizStrOK 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        return;
    }
    [syncMan startSyncInfo];
}

- (void) refreshAccountBegin:(id) sender
{
    UIButton* btn = (UIButton*)sender;
    [btn removeTarget:self action:@selector(refreshAccountBegin:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(stopSyncByUser) forControlEvents:UIControlEventTouchUpInside];
    [self refreshAccout];
}
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.currentPoperController = nil;
}

- (UINavigationController*) settingsViewControllerParentViewController
{
    return self.navigationController;
}
- (void) setAccountSettings:(id)sender
{
    UserSttingsViewController* settings = [[UserSttingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settings.navigationDelegate = self;
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:settings];
    [self popoverController:controller fromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp];
    [settings release];
    [controller release];
}
- (void) buildToolBar
{
    UIBarButtonItem* flexSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* newNoteItem = [[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIBarButtonItem* refreshItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    NSArray* arr = [NSArray arrayWithObjects:newNoteItem,flexSpaceItem,refreshItem, nil];
    [self setToolbarItems:arr];
    [newNoteItem release];
    [refreshItem release];
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
- (void) addSearchHistory:(NSString*)keyWords  count:(NSInteger)count
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:YES], @"search_local",
                         keyWords, @"key_words",
                         [[NSDate date] stringSql] , @"date",
                         [NSNumber numberWithInt:count], @"count",
                         nil,nil];
    NSString* fileNamePath = [[WizFileManager shareManager] searchHistoryFilePath];
    NSMutableArray* history = [NSMutableArray arrayWithContentsOfFile:fileNamePath];
    if (!history) {
        history = [NSMutableArray array];
    }
    [history insertObject:dic atIndex:0];
    [dic writeToFile:fileNamePath atomically:NO];
    [history writeToFile:fileNamePath atomically:YES];
}
- (void) didSelectedSearchHistory:(NSString *)keyWords
{
    [self checkDocument:WizPadCheckDocumentSourceTypeOfSearch keyWords:keyWords sourceArray:nil];
}
- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    SearchHistoryView* historyController = [[SearchHistoryView alloc] init];
    historyController.historyDelegate = self;
    [self popoverController:historyController fromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionUp];
}
- (void) searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    if (self.currentPoperController != nil) {
        [self.currentPoperController dismissPopoverAnimated:YES];
        self.currentPoperController = nil;
    }
}

-  (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSArray* documents = [WizDocument documentsByKey:searchBar.text];
    [self addSearchHistory:searchBar.text count:[documents count]];
    [self checkDocument:WizPadCheckDocumentSourceTypeOfSearch keyWords:searchBar.text sourceArray:nil];
    searchBar.text = @"";
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
- (void) willChangAccount
{
    [self.navigationController popViewControllerAnimated:NO];
}

- (void) viewWillChange:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSNumber* interface = [userInfo valueForKey:TypeOfViewInterface];
    [self willAnimateRotationToInterfaceOrientation:[interface intValue] duration:0.5];
}
- (void) checkDocument:(NSInteger)type keyWords:(NSString *)keyWords sourceArray:(NSMutableArray *)sourceArray
{
    WizPadDocumentViewController* check = [[WizPadDocumentViewController alloc] init];
    check.listType = type;
    check.documentListKey = keyWords;
    if (WizPadCheckDocumentSourceTypeOfRecent == type) {
        NSMutableArray* source = [[NSMutableArray alloc] init];
        for (NSMutableArray* each in sourceArray) {
            NSMutableArray* array = [NSMutableArray arrayWithArray:each];
            [source addObject:array];
        }
        check.documentsArray = source;
        [source release];
    }
    [self.navigationController pushViewController:check animated:YES];
    [check release];
}
- (void) buildMainViewcontrollers
{
    WizPadListTableControllerBase* base= [[WizPadListTableControllerBase alloc] init];
    base.checkDocumentDelegate = self;
    WizPadFoldersViewController* folder = [[WizPadFoldersViewController alloc] init];
    folder.checkDelegate = self;
    WizPadTagsViewController *tag = [[WizPadTagsViewController alloc] init];
    tag.checkDelegate = self;
    NSArray* array = [NSArray arrayWithObjects:base,folder,tag, nil];
    viewControllers = [array retain];
    [base release];
    [tag release];
    [folder release];
}
- (void) buildMainSegment
{
    NSArray* arr = [NSArray arrayWithObjects:
                    WizStrRecentNotes,
                    WizStrFolders,
                    WizStrTags,
                    nil];
    mainSegment = [[UISegmentedControl alloc] initWithItems:arr];
    mainSegment.segmentedControlStyle = UISegmentedControlStyleBar;
    [mainSegment addTarget:self action:@selector(changeController:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = mainSegment;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self buildMainViewcontrollers];
    [self buildMainSegment];
    [self buildNavigationItems];
    [mainSegment setSelectedSegmentIndex:0];
    UIViewController* controller = [viewControllers objectAtIndex:0];
    self.view = controller.view;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    for (UIViewController* each in viewControllers) {
        [each willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didAnimateFirstHalfOfRotationToInterfaceOrientation:fromInterfaceOrientation];
    for (UIViewController* each in viewControllers) {
        [each didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}
- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [super viewWillAppear:animated];
    UIViewController* controller = [viewControllers objectAtIndex:mainSegment.selectedSegmentIndex];
    [controller viewWillAppear:animated];
}
- (void) newNoteWillDisappear
{
    if (isWillReloadTagTable) {
        WizPadTagsViewController* tag = [viewControllers objectAtIndex:2];
        [tag reloadAllData];
        isWillReloadTagTable = NO;
    }
    if (isWillReloadFolderTable) {
        WizPadFoldersViewController* folder = [viewControllers objectAtIndex:1];
        [folder reloadAllData];
        isWillReloadFolderTable = NO;
    }
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIViewController* controller = [viewControllers objectAtIndex:mainSegment.selectedSegmentIndex];
    [controller viewDidAppear:animated];
    [self buildToolBar];
    
    
}
- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    if (self.currentPoperController != nil) {
        [self.currentPoperController dismissPopoverAnimated:NO];
    }
}
@end
