//
//  WizPadFoldersViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadFoldersViewController.h"
#import "WizFolderCatelogView.h"
#import "WizUiTypeIndex.h"
#import "WizNotification.h"
@interface WizPadFoldersViewController ()

@end

@implementation WizPadFoldersViewController

- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
- (void) willReloadFolderTable
{
    [self reloadAllData];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadFolderTable) name:MessageTypeOfUpdateFolderTable];
    }
    return self;
}

- (NSArray*) catelogDataSourceArray
{
    NSArray* locationKeys = [WizObject allLocationsForTree];
    NSMutableArray* arr = [NSMutableArray array];
    for (NSString* each in locationKeys) {
        if ([WizObject fileCountOfLocation:each] != 0) {
            [arr addObject:each];
        }
    }
    return arr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void) didSelectedCateLogViewForKey:(id)keyWords
{
    NSString* folder = (NSString*)keyWords;
    [self.checkDelegate checkDocument:WizPadCheckDocumentSourceTypeOfFolder keyWords:folder selectedDocument:nil];
}

- (void) setContentForCatelogView:(id)content catelogView:(CatelogView *)view
{
    NSString* folder = (NSString*)content;
    WizFolderCatelogView* tagView = (WizFolderCatelogView*)view;
    tagView.folderKey = folder;
    [tagView setNeedsDisplay];
}
- (CatelogView*) catelogViewForTableView:(UITableView *)tableView
{
    WizFolderCatelogView* cateLog = [[WizFolderCatelogView alloc] init];
    return [cateLog autorelease];
}
@end
