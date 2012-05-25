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
#import "WizGlobalData.h"
#import "WizPadEditNoteController.h"
#import "WizDictionaryMessage.h"
#import "UserSttingsViewController.h"
#import "WizNotification.h"
#import "WizSyncManager.h"
#import "WizPadFoldersViewController.h"

#import "WizPadTagsViewController.h"

#define LanscapeTableViewFrame     CGRectMake(0.0, 0.0, 768, 960)

@interface WizPadMainViewController ()
{
    UISegmentedControl* mainSegment;
    UIPopoverController* currentPoperController;
    UILabel* refreshProcessLabel;
    UIBarButtonItem* refreshItem;
    UIBarButtonItem* stopRefreshItem;
    BOOL syncWillStop;
    UIButton* refreshButton;
    //
    NSArray* viewControllers;
}
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@end

@implementation WizPadMainViewController


- (void) dealloc
{
    [refreshButton release];
    [refreshItem release];
    [stopRefreshItem release];
    [currentPoperController release];
    [mainSegment release];
    //
    [viewControllers release];
    viewControllers = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self];
        [nc addObserver:self selector:@selector(willChangeUser) name:MessageOfPadChangeUser object:nil];
        [nc addObserver:self selector:@selector(viewWillChange:) name:MessageOfViewWillOrientent object:nil];
        [nc addObserver:self selector:@selector(newNote) name:MessageOfNewFirstDocument object:nil];
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


- (void) newNote
{
    
    WizPadEditNoteController* newNote = [[WizPadEditNoteController alloc] init];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    controller.modalPresentationStyle = UIModalPresentationPageSheet;
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
    UserSttingsViewController* settings = [[UserSttingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
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

    


    refreshProcessLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 300, 44)];
    [refreshProcessLabel setFont:[UIFont systemFontOfSize:13]];
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
    [userInfo setObject:[NSNumber numberWithInt:WizPadCheckDocumentSourceTypeOfRecent] forKey:TypeOfCheckDocumentListType];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}

- (void) willChangeUser
{
    [self.navigationController popViewControllerAnimated:NO];
//    [WizNotificationCenter postChangeAccountMessage];
}

- (void) viewWillChange:(NSNotification*)nc
{
    NSDictionary* userInfo = [nc userInfo];
    NSNumber* interface = [userInfo valueForKey:TypeOfViewInterface];
    [self willAnimateRotationToInterfaceOrientation:[interface intValue] duration:0.5];
}
- (void) checkDocument:(NSInteger)type keyWords:(NSString *)keyWords
{
    WizPadDocumentViewController* check = [[WizPadDocumentViewController alloc] init];
    check.listType = type;
    check.documentListKey = keyWords;
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
