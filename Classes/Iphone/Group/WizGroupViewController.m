//
//  WizGroupViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-6-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizGroupViewController.h"
#import "GMGridView.h"
#import "WizAccountManager.h"
#import "PickViewController.h"
#import "UserSttingsViewController.h"
#import "WizGroupViewCell.h"
#import "WizDbManager.h"


@interface WizGroupViewController () <GMGridViewDataSource, GMGridViewActionDelegate>
{
    GMGridView* groupView;
    NSMutableArray* groupDataArray;
}
@property (nonatomic, retain) NSMutableArray* groupDataArray;
@end

@implementation WizGroupViewController
- (void) dealloc
{
    [groupView release];
    [groupDataArray release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.groupDataArray = [NSMutableArray arrayWithArray:[[WizAccountManager defaultManager] activeAccountGroups]];
    }
    return self;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) loadView
{
    [super loadView];
    GMGridView *gmGridView = [[GMGridView alloc] initWithFrame:self.view.bounds];
    gmGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:gmGridView];
    groupView = gmGridView;
    groupView.style = GMGridViewStylePush;
    groupView.centerGrid = NO;
    groupView.dataSource = self;
    groupView.actionDelegate = self;
}
- (void) setupAccount
{
    UserSttingsViewController* editAccountView = [[UserSttingsViewController alloc] initWithStyle:UITableViewStyleGrouped ];
    editAccountView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editAccountView animated:YES];
    [editAccountView release];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
   
    groupView.mainSuperView = self.navigationController.view;
    [self.navigationController setNavigationBarHidden:NO];
    
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:WizStrSettings style:UIBarButtonItemStyleBordered target:self action:@selector(setupAccount)];
    self.navigationItem.leftBarButtonItem = item;
    self.navigationController.navigationBar.tintColor = [UIColor lightGrayColor];
    [item release];
    
}
- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    
    return [self.groupDataArray count];
}
- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) 
    {
        return CGSizeMake(170, 135);
    }
    else
    {
        return CGSizeMake(150, 120);
    }
}
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    WizGroupViewCell *cell = (WizGroupViewCell*)[gridView dequeueReusableCell];
    if (!cell) 
    {
        cell = [[WizGroupViewCell alloc] initWithSize:size];
        
    }
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    WizGroup* group = [self.groupDataArray objectAtIndex:index];
    cell.textLabel.text = group.kbName;
    
    WizAbstract* abs = [[[WizDbManager shareDbManager] shareDataBase] abstractOfDocument:group.kbguid];
    if (abs) {
        cell.imageView.image = abs.image;
    }
    
    return cell;
}
- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    WizGroup* group = [self.groupDataArray objectAtIndex:position];
    [[WizAccountManager defaultManager] registerActiveGroup:group];
    PickerViewController* pick =[[PickerViewController alloc] init];
    [self.navigationController pushViewController:pick animated:YES];
    [pick release];
}
@end
