//
//  PadTagController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PadTagController.h"
#import "WizGlobalData.h"
#import "WizPadNotificationMessage.h"
#import "WizUiTypeIndex.h"
#import "CatelogTagCell.h"
#import "TTTAttributedLabel.h"
@implementation PadTagController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void) configureCellWithArray:(UITableViewCell *)cell array:(NSArray *)array
{
    NSMutableArray* decorateArray = [NSMutableArray array];
    for (WizTag* eachTag in array) {
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
        NSArray* documents = [index documentsByTag:eachTag.guid];
        WizPadCatelogData* data = [[WizPadCatelogData alloc] init];
        data.name = eachTag.title;
        data.count = [NSString stringWithFormat:@"%d %@",[documents count],WizStrNotes];
        data.keyWords = eachTag.guid;
        NSMutableAttributedString* attibuteString = [[NSMutableAttributedString alloc] init];
        int max = ([documents count] > 8? 8:[documents count]);
        for (int i = 0; i <max; i++) {
            WizDocument* doc = [documents objectAtIndex:i];
            NSMutableAttributedString* str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d %@\n",i, doc.title]];
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
- (void) reloadTableView
{
    [self reloadAllData];
    [self.tableView performSelectorInBackground:@selector(reloadData) withObject:nil];
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
    // Return YES for supported orientations
	return YES;
}

- (void) reloadAllData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* tags = [index allTagsForTree];
    NSMutableArray* arr = [NSMutableArray arrayWithArray:tags];
    [self.dataArray removeAllObjects];
    if (self.dataArray == nil) {
        self.dataArray = [NSMutableArray array];
    }
    for (WizTag* eachTag in arr) {
        if ([index fileCountOfTag:eachTag.guid] != 0) {
            [self.dataArray addObject:eachTag];
        }
    }
}

- (void) didSelectedCatelog:(NSString *)keywords
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:TypeOfTag], TypeOfCheckDocumentListType, keywords, TypeOfCheckDocumentListKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CatelogTagCell *cell = (CatelogTagCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CatelogTagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accountUserId = self.accountUserId;
        cell.owner = self;
        
    }
    NSInteger documentsCount =0;
    if (UIInterfaceOrientationIsLandscape(self.willToOrientation)) {
        documentsCount = 4;
    }
    else
    {
        documentsCount = 3;
    }
    NSUInteger needLength = documentsCount*(indexPath.row+1);
    NSLog(@"needLength is %d",needLength);
    NSLog(@"dataArray count is %d",[self.dataArray count]);
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([self.dataArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, [self.dataArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    
    NSLog(@"range is %d %d",docRange.location, docRange.length);
    cellArray = [self.dataArray subarrayWithRange:docRange];
    NSLog(@"cell array %d",[cellArray count]);
    [self configureCellWithArray:cell array:cellArray];
    return cell;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:MessageOfPadTagWillReload object:nil];
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView) name:MessageOfPadTagWillReload object:nil];
    }
    return self;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
@end
