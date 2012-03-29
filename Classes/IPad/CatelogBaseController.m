//
//  CatelogBaseController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogBaseController.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "CatelogBaseCell.h"
#import "TTTAttributedLabel.h"
@implementation WizPadCatelogData
@synthesize name;
@synthesize count;
@synthesize abstract;
@synthesize keyWords;
@end

@implementation CatelogBaseController
@synthesize accountUserId;
@synthesize willToOrientation;
static NSDictionary* paragrahAttributeDic;
+ (NSDictionary*) paragrahAttributeDic
{
    if (paragrahAttributeDic == nil) {
        paragrahAttributeDic = [NSMutableArray array];
        long characheterSpacing = 0.5f;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &characheterSpacing);
        CGFloat lineSpace = 18;
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value = &lineSpace;
        CTParagraphStyleSetting settings[] = {lineSpaceStyle};
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings));
        UIFont* stringFont = [UIFont systemFontOfSize:13];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        paragrahAttributeDic = [[NSDictionary alloc] initWithObjectsAndKeys:(id)num,(NSString *)kCTKernAttributeName,(id)style,(id)kCTParagraphStyleAttributeName, (id)font,(NSString*)kCTFontAttributeName,nil];
        CFRelease(num);
    }
    return paragrahAttributeDic;
}

- (void) dealloc{
    self.accountUserId = nil;
    [super dealloc];
}
-(void) didSelectedCatelog:(NSString *)keywords
{
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}
- (id) init
{
    self = [super init];
    if (self) {
        self.dataArray = [NSMutableArray array];
    }
    return self;
}
- (void) reloadAllData
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor grayColor];
    [self reloadAllData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
- (void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.willToOrientation = toInterfaceOrientation;
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = 0;
    if (UIInterfaceOrientationIsLandscape(self.willToOrientation)) {
        count = 4;
    }
    else
    {
        count = 3;
    }
    
    if ([self.dataArray  count]%count>0) {
        return  [self.dataArray count]/count+1;
    }
    else {
        return [self.dataArray count]/count  ;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CatelogBaseCell *cell = (CatelogBaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[CatelogBaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
    NSArray* cellArray=nil;
    NSRange docRange;
    if ([self.dataArray count] < needLength) {
        docRange =  NSMakeRange(documentsCount*indexPath.row, [self.dataArray count]-documentsCount*indexPath.row);
    }
    else {
        docRange = NSMakeRange(documentsCount*indexPath.row, documentsCount);
    }
    
    cellArray = [self.dataArray subarrayWithRange:docRange];
    [self configureCellWithArray:cell array:cellArray];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 300;
}
@end
