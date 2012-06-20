
 //
 //  PickerViewController.m
 //  Wiz
 //
 //  Created by dong zhao on 11 11 25.
 //  Copyright 2011年 __MyCompanyName__. All rights reserved.
 //
 
#import "PickViewController.h"
#import "TagsListTreeControllerNew.h"
#import "NewNoteView.h"
#import "UIView-TagExtensions.h"
#import "WizGlobalData.h"

#import "SearchViewControllerIphone.h"
#import "WizPhoneNotificationMessage.h"
#import "UserSttingsViewController.h"
#import "WizAccountManager.h"
//wiz-dzpqzb test
#import "FoldersViewControllerNew.h"
#import "WizNotification.h"
//wiz-dzpqzb test
#import "PhRecentViewController.h"

 #define NEWNOTEENTRY 101

@interface PickerViewController()
{
    BOOL canNewDocument;
}
@end
 
@implementation PickerViewController
-(void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    for (UINavigationController* each in self.viewControllers) {
        NSLog(@"retaun count is %d %d",[each retainCount], [[each.viewControllers lastObject] retainCount]);
    }
    [super dealloc];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
-(void) newNote
{
    NewNoteView* newNote= [[NewNoteView alloc]init];
    WizDocument* doc = [[WizDocument alloc] init];
    newNote.docEdit = doc;
    [doc release];
    UINavigationController* controller = [[UINavigationController alloc] initWithRootViewController:newNote];
    [self.navigationController presentModalViewController:controller animated:YES];
    [newNote release];
    [controller release];
}
 
- (id)init
{
    self = [super init];
    if (self) {
        [WizNotificationCenter addObserverForIphoneSetupAccount:self selector:@selector(setupAccount)];
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:animated];
   
}
 
- (void)didReceiveMemoryWarning
{
     [super didReceiveMemoryWarning];
}
 
 #pragma mark   View lifecycle
 
- (void) popSelf
{
    [self.navigationController popViewControllerAnimated:NO];
}
- (void) setupAccount
{

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    WizGroup* current = [[WizAccountManager defaultManager] activeAccountActiveGroup];
    canNewDocument = [current canEditDocument];
    
    PhRecentViewController* recent = [[PhRecentViewController alloc]init] ;
    UINavigationController* recentController = [[UINavigationController alloc]init];
    [recentController pushViewController:recent animated:NO];
    recentController.tabBarItem.image = [UIImage imageNamed:@"barItemRecent"];
    [recent release];
    //
    FoldersViewControllerNew* folderView = [[FoldersViewControllerNew alloc] init];
    UINavigationController* folderController = [[UINavigationController alloc] init] ;
    [folderController  pushViewController:folderView animated:NO];
    folderView.title = WizStrFolders;
    folderController.tabBarItem.image = [UIImage imageNamed:@"barItemFolde"];
    [folderView release];
    
    TagsListTreeControllerNew* tagView = [[TagsListTreeControllerNew alloc] init];
    UINavigationController* tagController = [[UINavigationController alloc] init];
    tagView.title = WizStrTags;
    [tagController pushViewController:tagView animated:NO];
    tagController.tabBarItem.image = [UIImage imageNamed:@"barItemTag"];
    [tagView release];
    
    SearchViewControllerIphone *searchView = [[SearchViewControllerIphone alloc] init];
    UINavigationController* searchController = [[UINavigationController alloc]initWithRootViewController:searchView ];
    searchController.title = WizStrSearch;
    searchController.tabBarItem.image = [UIImage imageNamed:@"barItemSearch"];
    [searchView release];
    if (canNewDocument) {
        UIImageView* view = [[UIImageView alloc] init] ;
        UINavigationController* emptyController = [[UINavigationController alloc]init];
        emptyController.title = NSLocalizedString(@"New", nil);
        emptyController.tabBarItem.tag = NEWNOTEENTRY;
        emptyController.tabBarItem.image = [UIImage imageNamed:@"barItemNewNote"];
        [emptyController.view addSubview:view];
        [view release];
        self.viewControllers = [NSArray arrayWithObjects:recentController,folderController, emptyController, tagController ,searchController, nil];
         [emptyController release];
    }
    else
    {
        self.viewControllers = [NSArray arrayWithObjects:recentController,folderController,  tagController ,searchController, nil];
    }
    
    [recentController release];
    [folderController release];
    [tagController release];
    [searchController release];
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.viewControllers = nil;
}
 
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
 
- (void) dismissModalViewControllerAnimated:(BOOL)animated
{
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if(item.tag == NEWNOTEENTRY)
    {
        [self newNote];
    }
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if (self.selectedIndex == 2 && canNewDocument) {
        [self setSelectedIndex:0];
    }
    
    
    for (UINavigationController* each in self.viewControllers) {
        NSLog(@"view retain count is %d",[[each.viewControllers lastObject] retainCount]);
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    for (UINavigationController* each in self.viewControllers) {
        NSLog(@"view disappear retain count is %d",[[each.viewControllers lastObject] retainCount]);
    }
}
@end

