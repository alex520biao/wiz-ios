//
//  PadFoldersController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PadFoldersController.h"
#import "WizUiTypeIndex.h"
#import "WizPadNotificationMessage.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizGlobals.h"
#import "TTTAttributedLabel.h"
#import "CatelogTagCell.h"
@implementation PadFoldersController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) configureCellWithArray:(UITableViewCell *)cell array:(NSArray *)array
{
    NSMutableArray* decorateArray = [NSMutableArray array];
    for (NSString* each in array) {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        NSArray* documents = [index documentsByLocation:each];
        if ([documents count] == 0 && ![each isEqualToString:@"/My Mobiles/"]) {
            continue;
        }
        WizPadCatelogData* data = [[WizPadCatelogData alloc] init];
        data.name = [WizGlobals folderStringToLocal:each];
        data.count = [NSString stringWithFormat:@"%d %@",[index fileCountOfLocation:each],WizStrNotes];
        data.keyWords = each;
        NSMutableAttributedString* attibuteString = [[NSMutableAttributedString alloc] init];
        int max = ([documents count] > 8? 8:[documents count]);
        for (int i = 0; i <max; i++) {
            WizDocument* doc = [documents objectAtIndex:i];
            NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@\n",i+1, doc.title]];
            [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, 1)];
            [str addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor grayColor].CGColor range:NSMakeRange(1, str.length-1)];
            [attibuteString appendAttributedString:str];
            [str release];
        }
        [attibuteString addAttributes:[CatelogBaseController paragrahAttributeDic] range:NSMakeRange(0, attibuteString.length)];
        data.abstract = attibuteString;

        [attibuteString release];
        [decorateArray addObject:data];
                [data release];
    }
    CatelogBaseCell* cateCell = (CatelogBaseCell*)cell;
    [cateCell setContent:decorateArray];
}

- (void) reloadAllData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* locationKeys = [index allLocationsForTree];
    NSMutableArray* arr = [NSMutableArray arrayWithArray:locationKeys];
    [self.dataArray removeAllObjects];
    if (self.dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }
    for (NSString* each in arr) {
        if ([index fileCountOfLocation:each] != 0) {
            [self.dataArray addObject:each];
        }
    }
    
}
- (void) reloadTableData
{
    [self reloadAllData];
    [self.tableView reloadData];
}
- (void) viewDidLoad
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


- (void) didSelectedCatelog:(NSString *)keywords
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:TypeOfLocation], TypeOfCheckDocumentListType, keywords, TypeOfCheckDocumentListKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData) name:MessageOfPadFolderWillReload object:nil];
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableData) name:MessageOfPadFolderWillReload object:nil];
    }
    return self;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
