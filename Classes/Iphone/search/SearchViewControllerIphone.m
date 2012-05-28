//
//  SearchViewControllerIphone.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchViewControllerIphone.h"

#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "CommonString.h"
#import "SearchHistoryView.h"
#import "WizAccountManager.h"
#import "WizFileManager.h"
#import "PhSearchResultViewController.h"
#import "WizSyncSearch.h"
#import "WizSyncManager.h"
@interface SearchViewControllerIphone()
{
    UISearchBar* searchBar;
    UISwitch*    localSearchSwitch;
    UILabel*    localSearchSwitchString;
    UIImageView*     localsearchView;
    UIAlertView* waitAlertView;
    NSString* currentKeyWords;
    SearchHistoryView* historyView;
}
@property (nonatomic, retain) UISearchBar* searchBar;
@property (nonatomic, retain) UISwitch*    localSearchSwitch;
@property (nonatomic, retain) UILabel*    localSearchSwitchString;
@property (nonatomic, retain) UIImageView*      localsearchView;
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) NSString* currentKeyWords;
@property (nonatomic, retain) SearchHistoryView* historyView;
@end
@implementation SearchViewControllerIphone
@synthesize searchBar;
@synthesize localSearchSwitch;
@synthesize localSearchSwitchString;
@synthesize localsearchView;
@synthesize waitAlertView;
@synthesize currentKeyWords;
@synthesize historyView;
-(void) dealloc
{
    [searchBar release];
    searchBar = nil;
    [localSearchSwitch release];
    [localSearchSwitchString release];
    [localsearchView release];
    [waitAlertView release];
    [currentKeyWords release];
    [historyView release];
    [super dealloc];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (nil == self.searchBar) {
            self.searchBar = [[[UISearchBar alloc] init] autorelease];
            self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        }
        if (nil == self.localsearchView) {
            self.localsearchView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 50, 320, 40)] autorelease];
            self.localsearchView.image = [UIImage imageNamed:@"searchBackgroud"];
            self.localsearchView.userInteractionEnabled = YES;
        }
        if (nil == self.localSearchSwitch) {
            self.localSearchSwitch = [[[UISwitch alloc] initWithFrame:CGRectMake(220, 5, 60, 40)] autorelease];
            [self.localsearchView addSubview:self.localSearchSwitch];
        }
        
        if (nil == self.localSearchSwitchString) {
            self.localSearchSwitchString = [[[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, 160, 40)] autorelease];
            self.localSearchSwitchString.backgroundColor = [UIColor clearColor];
            [self.localsearchView addSubview:self.localSearchSwitchString];
        }
        if (nil == self.historyView) {
            self.historyView = [[[SearchHistoryView alloc] init] autorelease];
            self.historyView.view.frame = CGRectMake(0.0, 0.0, 320, 327);
            self.historyView.historyDelegate = self;
            
        }
        self.title = WizStrSearch;
        self.searchBar.delegate = self;
        self.localSearchSwitchString.text = NSLocalizedString(@"Search local notes only" , nil);
        self.localSearchSwitchString.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.localsearchView cache:YES];
    self.historyView.tableView.tableHeaderView = self.localsearchView;
    [UIView commitAnimations];
 
}

- (void) addSearchHistory:(int)count
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:self.localSearchSwitch.on], @"search_local",
                         self.currentKeyWords, @"key_words",
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
- (void) didSearchKeywords:(NSString*)keywords isNewSearch:(BOOL)isNewSearch
{
	if (keywords == nil || [keywords length] == 0)
		return;
	//
	NSArray* arr = [WizDocument documentsByKey:keywords];
	//
	if (arr == nil || [arr count] == 0)
	{
		NSString* formatter = NSLocalizedString(@"Cannot find %@", nil);
		NSString* msg = [NSString stringWithFormat:formatter, keywords];
		//
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
        [self searchBarCancelButtonClicked:self.searchBar];
		return;
	}
    if (isNewSearch) {
        [self addSearchHistory:[arr count]];
    }
    PhSearchResultViewController* searchResultView = [[PhSearchResultViewController alloc] initWithResultArray:arr];
    [self.navigationController pushViewController:searchResultView animated:YES];
    [searchResultView release];

}
- (void) didSelectedSearchHistory:(NSString *)keyWords
{
    [self.searchBar resignFirstResponder];
    [self didSearchKeywords:keyWords isNewSearch:NO];
}
- (void) showSearchResult
{
    self.historyView.tableView.tableHeaderView = nil;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self didSearchKeywords:self.currentKeyWords isNewSearch:YES];
}

- (void) didSearchFild
{
    
}

- (void) didSearchSucceed
{
    NSLog(@"search succedd");
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentKeyWords = self.searchBar.text;
    NSString* keywords = self.currentKeyWords;
	if (keywords == nil || [keywords length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:NSLocalizedString(@"Please enter keywords!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (self.localSearchSwitch.on)
	{
		[self showSearchResult];
	}
	else 
	{
        [[WizSyncManager shareManager] searchKeywords:keywords searchDelegate:self];
	}
    
}



- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:NO animated:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.localsearchView cache:YES];
    self.historyView.tableView.tableHeaderView = nil;
    [UIView commitAnimations];
    [self.searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad
{

    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void) viewWillAppear:(BOOL)animated
{
    [self searchBarCancelButtonClicked:self.searchBar];
    self.searchBar.frame = self.navigationController.navigationBar.frame;
    self.view = self.historyView.view;
    self.navigationItem.titleView = self.searchBar;
    [self.historyView reloadData];
    self.localSearchSwitch.on = YES;
    [super viewWillAppear:animated];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar becomeFirstResponder];
}
@end
