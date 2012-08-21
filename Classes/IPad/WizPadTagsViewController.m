//
//  WizPadTagsViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadTagsViewController.h"
#import "WizTagCatelogView.h"
#import "WizUiTypeIndex.h"
#import "WizNotification.h"
@implementation WizPadTagsViewController

- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}

- (void) willReloadTagTable
{
    [self reloadAllData];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
         [WizNotificationCenter addObserverWithKey:self selector:@selector(willReloadTagTable) name:MessageTypeOfUpdateTagTable];
    }
    return self;
}
- (NSArray*) catelogDataSourceArray
{
    NSArray* tags = [WizTag allTags];
    NSMutableArray* arr = [NSMutableArray array];
    for (WizTag* eachTag in tags) {
        if ([WizTag fileCountOfTag:eachTag.guid] != 0) {
            [arr addObject:eachTag];
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
    WizTag* tag = (WizTag*)keyWords;
    [self.checkDelegate checkDocument:WizPadCheckDocumentSourceTypeOfTag keyWords:tag.guid selectedDocument:nil];
}

- (void) setContentForCatelogView:(id)content catelogView:(CatelogView *)view
{
    WizTag* tag = (WizTag*)content;
    WizTagCatelogView* tagView = (WizTagCatelogView*)view;
    tagView.wizTag = tag;
    [tagView setNeedsDisplay];
}
- (CatelogView*) catelogViewForTableView:(UITableView *)tableView
{
    WizTagCatelogView* cateLog = [[WizTagCatelogView alloc] init];
    return [cateLog autorelease];
}
@end
