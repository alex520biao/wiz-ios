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
        id<WizPadNewNoteTagAndFolderDelegate> noteNewDelegate;
}
@property (nonatomic, retain) UIPopoverController* currentPoperController;
@property (nonatomic, assign) id<WizPadNewNoteTagAndFolderDelegate> noteNewDelegate;
@end

@implementation WizPadViewController
@synthesize currentPoperController;
@synthesize noteNewDelegate;

- (void)dealloc
{
    if (self.currentPoperController) {
        [self.currentPoperController dismissPopoverAnimated:NO];
    }
    self.currentPoperController = nil;
    noteNewDelegate = nil;
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
    treeTable.checkDocuementDelegate = self;
    
    NSArray* array = [NSArray arrayWithObjects:base,treeTable,folder,tag, nil];
    NSArray* titles = @[WizStrRecentNotes ,NSLocalizedString(@"All Notes", nil),WizStrFolders,WizStrTags ];
    self = [super initWithViewControllers:array titles:titles];

    if (self) {
        self.noteNewDelegate = treeTable;
    }
    [base release];
    [tag release];
    [folder release];
    [treeTable release];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void) buildToolBar
{
    UIBarButtonItem* flexSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem* newNoteItem = [[UIBarButtonItem alloc] initWithTitle:WizStrNewNote style:UIBarButtonItemStyleBordered target:self action:@selector(newNote)];

    NSArray* arr = [NSArray arrayWithObjects:newNoteItem,flexSpaceItem, nil];

    [self setToolbarItems:arr];
    
    NSLog(@"self.toolbar %@",self.navigationController.toolbar);
    
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self buildToolBar];
    [self.navigationController setToolbarHidden:NO];
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
    if (self.navigationItem.rightBarButtonItem) {
        UIView* customView = self.navigationItem.rightBarButtonItem.customView;
        if ([customView isKindOfClass:[UISearchBar class]]) {
            UISearchBar* searchBar = (UISearchBar*) customView;
            [searchBar resignFirstResponder];
        }
    }
    self.currentPoperController = nil;
}
//check document
- (void) checkDocument:(NSInteger)type keyWords:(NSString *)keyWords selectedDocument:(WizDocument *)document
{
    WizPadDocumentViewController* check = [[WizPadDocumentViewController alloc] init];
    check.listType = type;
    check.documentListKey = keyWords;
    check.initDocument = document;
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
    WizDocument* document = [[WizDocument alloc] init];
    
    document.location = [self.noteNewDelegate folderForNewNote];
    document.tagGuids = [self.noteNewDelegate tagGuidForNewNote];
    newNote.docEdit = document;
    
    
    [document release];
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
    [self checkDocument:WizPadCheckDocumentSourceTypeOfSearch keyWords:keyWords selectedDocument:nil];
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
    [self checkDocument:WizPadCheckDocumentSourceTypeOfSearch keyWords:searchBar.text selectedDocument:nil];
    searchBar.text = @"";
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
}
@end
