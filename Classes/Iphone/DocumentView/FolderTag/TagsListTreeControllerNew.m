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



- (void) reloadAllData
{
    NSArray* tagArray = [[[WizDbManager shareDbManager] shareDataBase] allTagsForTree];
    tree = [[LocationTreeNode alloc]init] ;
    tree.deep = 0;
    tree.title = @"/";
    tree.locationKey = @"/";
    tree.hidden = YES;
    tree.expanded =YES;
    for (WizTag* each in tagArray)
    {
        LocationTreeNode* node = [[LocationTreeNode alloc] init];
        NSString* tagName = getTagDisplayName(each.title);
        node.title = tagName;
        node.locationKey = each.guid;
        if (nil != each.parentGUID && ![each.parentGUID isEqualToString:@""]) {
            LocationTreeNode* parent = [LocationTreeNode findNodeByKey:each.parentGUID :self.tree];
            if (nil == parent) {
                WizTag* parentTag = [WizTag  tagFromDb:each.parentGUID];
                LocationTreeNode* nodee = [[LocationTreeNode alloc] init];
                nodee.title = parentTag.title;
                nodee.locationKey = parentTag.guid;
                [tree addChild:parent];
                [nodee addChild:node];
                [nodee release];
                [node release];
                continue;
            }
            else
            {
                [parent addChild:node];
                [node release];
                continue;
            }
        }
        else
        {
            [tree addChild:node];
            [node release];
        }
        
    }
    if (nil == self.displayNodes) {
        self.displayNodes = [NSMutableArray array];
    } else
    {
        [self.displayNodes removeAllObjects];
    }
//    [self removeBlockLocationNode:tree];
    [LocationTreeNode getLocationNodes:self.tree :self.displayNodes];
    [self setNodeRow];
    [self.tableView reloadData];
    
    self.tableFooterRemindView.frame = CGRectMake(0.0, 0.0, 320, [WizGlobals heightForWizTableFooter:[self.displayNodes count]]);
    self.tableView.tableFooterView = self.tableFooterRemindView;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.closedImage = [UIImage imageNamed:@"treePlus"];
    self.expandImage = [UIImage imageNamed:@"treeCut"];
    
    self.tableFooterRemindView.imageView.image = [UIImage imageNamed:@"tagTableFooter"];
    self.tableFooterRemindView.textLabel.text = NSLocalizedString(@"Tap on a tag above to see all notes with that tag. Make your notes easier to find by creating and assinging more tags.", nil);
    

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) setDetail:(LocationTreeViewCell *)cell
{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger fileNumber = [WizTag fileCountOfTag:cell.treeNode.locationKey];
//        dispatch_async(dispatch_get_main_queue(), ^
//        {
            NSString* count = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),fileNumber];
            cell.detailTextLabel.text = count;
//        });
//    });

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
