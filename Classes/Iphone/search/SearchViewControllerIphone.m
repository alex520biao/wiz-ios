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
    UISearchBar* searchBarLocal;
    UISwitch*    localSearchSwitch;
    UILabel*    localSearchSwitchString;
    UIImageView*     localsearchView;
    UIAlertView* waitAlertView;
    NSString* currentKeyWords;
    SearchHistoryView* historyView;
}
@property (nonatomic, retain) UIAlertView* waitAlertView;
@property (nonatomic, retain) NSString* currentKeyWords;
@end
@implementation SearchViewControllerIphone
@synthesize waitAlertView;
@synthesize currentKeyWords;
-(void) dealloc
{
    [searchBarLocal release];
    searchBarLocal = nil;
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
        searchBarLocal = [[UISearchBar alloc] init];
        localsearchView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 50, 320, 40)] ;
        localsearchView.image = [UIImage imageNamed:@"searchBackgroud"];
        localsearchView.userInteractionEnabled = YES;
        localSearchSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(220, 5, 60, 40)] ;
        
        localSearchSwitchString = [[UILabel alloc] initWithFrame:CGRectMake(10, 0.0, 160, 40)] ;
        localSearchSwitchString.backgroundColor = [UIColor clearColor];
        [localsearchView addSubview:localSearchSwitchString];
        historyView = [[SearchHistoryView alloc] init] ;
        historyView.view.frame = CGRectMake(0.0, 0.0, 320, 327);
        historyView.historyDelegate = self;
        self.title = WizStrSearch;
        searchBarLocal.delegate = self;
        localSearchSwitchString.text = NSLocalizedString(@"Search local notes only" , nil);
        localSearchSwitchString.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:localsearchView cache:YES];
    historyView.tableView.tableHeaderView = localsearchView;
    [UIView commitAnimations];
 
}

- (void) addSearchHistory:(int)count
{
    [historyView addSearchHistory:self.currentKeyWords notesNumber:count isSearchLoal:localSearchSwitch.on];
    
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
        [self searchBarCancelButtonClicked:searchBarLocal];
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
    [searchBarLocal resignFirstResponder];
    [self didSearchKeywords:keyWords isNewSearch:NO];
}
- (void) showSearchResult
{
    historyView.tableView.tableHeaderView = nil;
    [searchBarLocal setShowsCancelButton:NO animated:YES];
    [self didSearchKeywords:self.currentKeyWords isNewSearch:YES];
}

- (void) didSearchFild
{
    if (self.waitAlertView) {
        [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
}

- (void) didSearchSucceed:(NSArray *)array
{
    if (self.waitAlertView) {
        [self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    PhSearchResultViewController* searchResultView = [[PhSearchResultViewController alloc] initWithResultArray:array];
    [self.navigationController pushViewController:searchResultView animated:YES];
    [searchResultView release];
}
-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.currentKeyWords = searchBarLocal.text;
    NSString* keywords = self.currentKeyWords;
	if (keywords == nil || [keywords length] == 0)
	{
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:NSLocalizedString(@"Please enter keywords!", nil) delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	//
	if (localSearchSwitch.on)
	{
		[self showSearchResult];
	}
	else 
	{
        [[WizSyncManager shareManager] searchKeywords:keywords searchDelegate:self];
        UIAlertView* alert = nil;
        [WizGlobals showAlertView:WizStrSearch message:WizStrLoading delegate:self retView:&alert];
        waitAlertView = alert;
	}
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBarLocal setShowsCancelButton:NO animated:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:localsearchView cache:YES];
    historyView.tableView.tableHeaderView = nil;
    [UIView commitAnimations];
    [searchBarLocal resignFirstResponder];
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
    [self searchBarCancelButtonClicked:searchBarLocal];
    searchBarLocal.frame = self.navigationController.navigationBar.frame;
    self.view = historyView.view;
    self.navigationItem.titleView = searchBarLocal;
    searchBarLocal.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [historyView reloadData];
    localSearchSwitch.on = YES;
    [super viewWillAppear:animated];
    localSearchSwitch.frame = CGRectMake(self.view.frame.size.width-80, 5, 70, 40);
    localSearchSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [localsearchView addSubview:localSearchSwitch];
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [searchBarLocal becomeFirstResponder];
}
@end
