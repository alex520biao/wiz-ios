//
//  TagsListTreeControllerNew.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TagsListTreeControllerNew.h"
#import "TreeViewBaseController.h"
#import "WizGlobalData.h"
#import "LocationTreeNode.h"
#import "LocationTreeViewCell.h"
#import "WizPhoneNotificationMessage.h"
#import "WizDbManager.h"
#import "PhTagListViewController.h"


@implementation TagsListTreeControllerNew

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadAllData) name:MessageTypeOfUpdateTagTable];
    }
    return self;
}
- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void) removeBlockLocationNode:(LocationTreeNode*)node
{
    if ([node hasChildren]) {
        NSArray* arr = [node.children copy];
        for (LocationTreeNode* each in arr) {
            [self removeBlockLocationNode:each];
        }
        if (![node hasChildren] && ![WizTag fileCountOfTag:node.locationKey]) {
            [node.parentLocationNode removeChild:node];
        }
        [arr release];
    }
    else
    {
        if (![[WizDocument documentsByTag:node.locationKey] count]) {
            [node.parentLocationNode removeChild:node];
        }
    }
}


- (void) genTagNamePath:(LocationTreeNode*)parentTag rest:(NSMutableArray*)rest
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentGUID == %@",parentTag.locationKey];
    NSPredicate* rpredicate = [NSPredicate predicateWithFormat:@"parentGUID != %@",parentTag.locationKey];
    NSArray* section = [rest filteredArrayUsingPredicate:predicate];
    [rest filterUsingPredicate:rpredicate];
    for (WizTag* each in section) {
        LocationTreeNode* node = [[LocationTreeNode alloc] init];
        node.title = each.title;
        node.locationKey = each.guid;
        [parentTag addChild:node];
        [self genTagNamePath:node rest:rest];
        [node release];
    }
}
- (void) reloadAllData
{
    NSMutableArray* tagArray = [NSMutableArray arrayWithArray:[[[WizDbManager shareDbManager] shareDataBase] allTagsForTree]];
    
    tree = [[LocationTreeNode alloc]init];
    tree.deep = 0;
    tree.title = @"/";
    tree.locationKey = @"/";
    tree.hidden = YES;
    tree.expanded =YES;

    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"parentGUID.length != 0"];
    NSPredicate* rPredicate = [NSPredicate predicateWithFormat:@"parentGUID.length == 0"];
    NSArray* root = [tagArray filteredArrayUsingPredicate:rPredicate];
    NSMutableArray* rest =[NSMutableArray arrayWithArray:[tagArray filteredArrayUsingPredicate:predicate]];
    for (WizTag* each in root) {
        LocationTreeNode* node = [[LocationTreeNode alloc] init];
        node.title = each.title;
        node.locationKey = each.guid;
        [tree addChild:node];
        [self genTagNamePath:node rest:rest];
         [node release];
    }
    
    if (nil == self.displayNodes) {
        self.displayNodes = [NSMutableArray array];
    } else
    {
        [self.displayNodes removeAllObjects];
    }
    [LocationTreeNode getLocationNodes:self.tree :self.displayNodes];
    [self setNodeRow];
    [self.tableView reloadData];
    
    NSLog(@"self retain count %d",[self retainCount]);
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.closedImage = [UIImage imageNamed:@"treePlus"];
    self.expandImage = [UIImage imageNamed:@"treeCut"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[self.displayNodes count]])];
    UIImageView* searchFooter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tagTableFooter"]];
    [footerView addSubview:searchFooter];
    self.tableView.tableFooterView = footerView;
    footerView.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
    [searchFooter release];
    [footerView release];
    UITextView* remind = [[UITextView alloc] initWithFrame:CGRectMake(90, 0, 200, 100)];
    remind.text = NSLocalizedString(@"Tap on a tag above to see all notes with that tag. Make your notes easier to find by creating and assinging more tags.", nil);
    remind.backgroundColor = [UIColor clearColor];
    remind.textColor = [UIColor grayColor];
    [searchFooter addSubview:remind];
    [remind release];
}

- (void) setDetail:(LocationTreeViewCell *)cell
{
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),[WizTag fileCountOfTag:cell.treeNode.locationKey]];
    if (![cell.treeNode hasChildren]) {
        cell.imageView.image = [UIImage imageNamed:@"treeTag"];
    }
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WizTag* tag =  [WizTag tagFromDb:[[self.displayNodes objectAtIndex:indexPath.row] locationKey]];;
    PhTagListViewController* tagView = [[PhTagListViewController alloc] initWithTagGuid:tag.guid];
    [self.navigationController pushViewController:tagView animated:YES];
    [tagView release];
}

@end
