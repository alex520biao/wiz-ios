//
//  WizPadViewController.m
//  Wiz
//
//  Created by wiz on 12-8-14.
//
//

#import "WizPadViewController.h"
#import "WizPadListTableControllerBase.h"
#import "WizPadFoldersViewController.h"
#import "WizPadTagsViewController.h"
#import "UserSttingsViewController.h"
#import "WizPadEditNoteController.h"
#import "SearchHistoryView.h"
#import "WizPadDocumentViewController.h"
#import "WizPadViewDocumentDelegate.h"
//
#import "WizPadAllNotesViewController.h"
//
#import "WizPadAllNotesViewController.h"

@interface WizPadViewController () <UIPopoverControllerDelegate,UISearchBarDelegate,WizSettingsParentNavigationDelegate,WizSearchHistoryDelegate,WizPadViewDocumentDelegate>
{
    UIPopoverController* currentPoperController;
}
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@end

@implementation WizPadViewController
@synthesize currentPoperController;


- (void)dealloc
{
    if (self.currentPoperController) {
        [self.currentPoperController dismissPopoverAnimated:NO];
    }
    self.currentPoperController = nil;
    [super dealloc];
}

- (id) init
{
    WizPadListTableControllerBase* base= [[WizPadListTableControllerBase alloc] init];
    base.checkDocumentDelegate = self;
    
    WizPadFoldersViewController* folder = [[WizPadFoldersViewController alloc] init];

    folder.checkDelegate = self;
    WizPadTagsViewController *tag = [[WizPadTagsViewController alloc] init];
    tag.checkDelegate = self;
    
    WizPadAllNotesViewController* treeTable = [[WizPadAllNotesViewController alloc] initWithNibName:@"WizPadAllNotesViewController" bundle:nil];
    
    
    NSArray* array = [NSArray arrayWithObjects:base,folder,tag,treeTable, nil];
    NSArray* titles = @[WizStrRecentNotes ,WizStrFolders,WizStrTags,NSLocalizedString(@"Tree", nil) ];
    self = [super initWithViewControllers:array titles:titles];
    [base release];
    [tag release];
    [folder release];
    [treeTable release];
    if (self) {
        
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) buildToolBar
{
    UIBarButtonItem* flexSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* newNoteItem = [[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];

    NSArray* arr = [NSArray arrayWithObjects:newNoteItem,flexSpaceItem, nil];
    [self setToolbarItems:arr];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self buildNavigationItems];
    [self buildToolBar];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

//poper
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
- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.currentPoperController = nil;
}
//check document
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
// setting

- (void) setAccountSettings:(id)sender
{
    UserSttingsViewController* settings = [[UserSttingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    settings.navigationDelegate = self;
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:settings];
    [self popoverController:controller fromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp];
    [settings release];
    [controller release];
}

- (UINavigationController*) settingsViewControllerParentViewController
{
    return self.navigationController;
}

- (void) willChangAccount
{
    [self.navigationController popViewControllerAnimated:NO];
}
// new note
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
// search
- (void) addSearchHistory:(NSString*)keyWords  count:(NSInteger)count
{
    if (self.currentPoperController) {
        if ([self.currentPoperController.contentViewController isKindOfClass:[SearchHistoryView class]]) {
            SearchHistoryView* searchView = (SearchHistoryView*)self.currentPoperController.contentViewController;
            [searchView addSearchHistory:keyWords notesNumber:count isSearchLoal:YES];
        }
    }
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
@end
