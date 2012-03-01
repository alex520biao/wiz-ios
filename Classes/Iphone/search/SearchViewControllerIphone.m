//
//  SearchViewControllerIphone.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-8.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "SearchViewControllerIphone.h"
#import "WizIndex.h"
#import "WizGlobals.h"
#import "WizGlobalData.h"
#import "CommonString.h"
#import "SearchResultViewController.h"
#import "WizDocumentsByKey.h"
#import "SearchHistoryView.h"
@implementation SearchViewControllerIphone
@synthesize searchBar;
@synthesize localSearchSwitch;
@synthesize localSearchSwitchString;
@synthesize localsearchView;
@synthesize accountUserId;
@synthesize accountUserPassword;
@synthesize waitAlertView;
@synthesize currentKeyWords;
@synthesize historyView;
-(void) dealloc
{
    self.searchBar = nil;
    self.localSearchSwitch = nil;
    self.localSearchSwitchString = nil;
    self.localsearchView = nil;
    self.accountUserId = nil;
    self.accountUserPassword = nil;
    self.waitAlertView = nil;
    self.currentKeyWords = nil;
    self.historyView = nil;
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

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.localsearchView cache:YES];
    self.localsearchView.hidden = NO;
    [self.view bringSubviewToFront:self.localsearchView];
    [UIView commitAnimations];
 
}

- (void) addSearchHistory:(int)count
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [NSNumber numberWithBool:self.localSearchSwitch.on], @"search_local",
                         self.currentKeyWords, @"key_words",
                         dateString, @"date",
                         [NSNumber numberWithInt:count], @"count",
                         nil,nil];
    NSString* objectPath = [WizIndex documentFilePath:self.accountUserId documentGUID:@"SearchHistoryDir"];
    [WizGlobals ensurePathExists:objectPath];
    NSString* fileNamePath = [objectPath stringByAppendingPathComponent:@"history.dat"];
    NSMutableArray* history = [NSMutableArray arrayWithContentsOfFile:fileNamePath];
    if (!history) {
        history = [NSMutableArray array];
    }
    [history insertObject:dic atIndex:0];
    [dic writeToFile:fileNamePath atomically:NO];
    [history writeToFile:fileNamePath atomically:YES];
}
- (void) showSearchResult
{
    
    self.localsearchView.hidden = YES;
    self.searchBar.showsCancelButton = NO;
    NSString* keywords = self.currentKeyWords;
	if (keywords == nil || [keywords length] == 0)
		return;
	//
	WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
	NSArray* arr = [index documentsByKey:keywords];
	//
	if (arr == nil || [arr count] == 0)
	{
		NSString* formatter = NSLocalizedString(@"Can not find %@", nil);
		NSString* msg = [NSString stringWithFormat:formatter, keywords];
		//
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrSearch message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
		[alert show];
		[alert release];
        [self searchBarCancelButtonClicked:self.searchBar];
		return;
	}
    
    [self addSearchHistory:[arr count]];
    SearchResultViewController* searchResultView = [[SearchResultViewController alloc] initWithStyle:UITableViewStylePlain];
    searchResultView.accountUserID = accountUserId;
    searchResultView.searchResult = arr;
    

    
    [self.navigationController pushViewController:searchResultView animated:YES];
    [searchResultView release];
}


- (void) xmlrpcDone: (NSNotification*)nc
{
	NSDictionary* userInfo = [nc userInfo];
	//
	BOOL succeeded = [[userInfo valueForKey:@"succeeded"] boolValue];
	//
	if (!succeeded)
	{
		if (self.waitAlertView)
		{
			[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
			self.waitAlertView = nil;
		}
		//
	}
	
	NSString* method = [userInfo valueForKey:@"method"];
	if (method != nil && [method isEqualToString:SyncMethod_DocumentsByKey])
	{
		if (succeeded)
		{
			if (self.waitAlertView)
			{
				[self.waitAlertView dismissWithClickedButtonIndex:0 animated:YES];
				self.waitAlertView = nil;
			}
			//
			[self showSearchResult];
		}
		else 
		{
			NSError* error = [userInfo valueForKey:@"ret"];
			//
			NSString* msg = nil;
			if (error != nil)
			{
				msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login!\n%@", nil), [error localizedDescription]];
			}
			else 
			{
				msg = NSLocalizedString(@"Failed to login!\nUnknown error!", nil);
			}
			
			UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WizStrError message:msg delegate:self cancelButtonTitle:WizStrOK otherButtonTitles:nil];
			
			[alert show];
			[alert release];
		}
	}
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
		WizDocumentsByKey* api = [[WizGlobalData sharedData] documentsByKeyData:self.accountUserId];
		if (api.busy)
			return;
		NSString* notificationName = [api notificationName:WizSyncXmlRpcDoneNotificationPrefix];
		//
		NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
		[nc removeObserver:self];
		//
		[nc addObserver:self selector:@selector(xmlrpcDone:) name:notificationName object:nil];
		//
		UIAlertView* alert = nil;
		[WizGlobals showAlertView:WizStrSearch message:NSLocalizedString(@"Please wait while searching!", nil) delegate:self retView:&alert];
		[alert show];
		//
		self.waitAlertView = alert;
		//
		[alert release];
		//
		api.keywords = keywords;
		[api searchDocuments];
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
    self.localsearchView.hidden = YES;
    [self.view bringSubviewToFront:self.historyView.view];
    [UIView commitAnimations];
    [self.searchBar resignFirstResponder];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad
{
    if (nil == self.searchBar) {
        self.searchBar = [[[UISearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, 50)] autorelease];
        [self.view addSubview:self.searchBar];
    }
    if (nil == self.localsearchView) {
        self.localsearchView = [[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 50, 320, 40)] autorelease];
        self.localsearchView.image = [UIImage imageNamed:@"searchBackgroud"];
        self.localsearchView.userInteractionEnabled = YES;
        [self.view addSubview:self.localsearchView];
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
        self.historyView.accountUserId = self.accountUserId;
        self.historyView.view.frame = CGRectMake(0.0, 0.0, 320, 327);
        self.historyView.owner = self;
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 50, 320, 317)];
        [view addSubview:self.historyView.view];
        [self.view addSubview:view];
        [view release];
    }
    self.title = WizStrSearch;
    self.localsearchView.hidden = YES;
    self.searchBar.delegate = self;
    self.localSearchSwitchString.text = NSLocalizedString(@"Search local notes only" , nil);
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    [self searchBarCancelButtonClicked:self.searchBar];
    [self.historyView reloadData];
    self.localSearchSwitch.on = YES;
    [super viewWillAppear:animated];
}

@end
