//
//  WizPadFoldersViewController.m
//  Wiz
//
//  Created by 朝 董 on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadFoldersViewController.h"
#import "WizTagCatelogView.h"
#import "WizUiTypeIndex.h"
@interface WizPadFoldersViewController ()

@end

@implementation WizPadFoldersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self.checkDelegate checkDocument:WizPadCheckDocumentSourceTypeOfTag keyWords:tag.guid];
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
