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
@implementation PadFoldersController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



- (void) reloadAllData
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* locationKeys = [index allLocationsForTree];
    
    NSMutableArray* foldersWithoutBlank = [NSMutableArray array];
    for (NSString* each in locationKeys) {
        NSArray* documents = [index documentsByLocation:each];
        if ([documents count] == 0 && ![each isEqualToString:@"/My Mobiles/"]) {
            continue;
        }
        WizPadCatelogData* data = [[WizPadCatelogData alloc] init];
        data.name = [WizGlobals folderStringToLocal:each];
        data.count = [NSString stringWithFormat:@"%d %@",[documents count],WizStrNotes];
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
        long characheterSpacing = 0.5f;
        CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberLongType, &characheterSpacing);
        [attibuteString addAttribute:(NSString *)kCTKernAttributeName value:(id)num range:NSMakeRange(0, attibuteString.length)];
        CGFloat lineSpace = 18;
        CTParagraphStyleSetting lineSpaceStyle;
        lineSpaceStyle.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
        lineSpaceStyle.valueSize = sizeof(lineSpace);
        lineSpaceStyle.value = &lineSpace;
        CTParagraphStyleSetting settings[] = {lineSpaceStyle};
        CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings));
        [attibuteString addAttribute:(id)kCTParagraphStyleAttributeName value:(id)style range:NSMakeRange(0, attibuteString.length)];
        UIFont* stringFont = [UIFont systemFontOfSize:13];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        [attibuteString addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:NSMakeRange(0, attibuteString.length)];
        data.abstract = attibuteString;
        [foldersWithoutBlank addObject:data];
        [data release];
        [attibuteString release];
    }
    
    if (nil == self.landscapeContentArray) {
        self.landscapeContentArray = [NSMutableArray array];
    }
    
    if (nil == self.portraitContentArray) 
    {
        self.portraitContentArray = [NSMutableArray array];
    }
    self.portraitContentArray =  [NSMutableArray arrayWithArray:[self arrayToPotraitCellArraty:foldersWithoutBlank]];
    self.landscapeContentArray =  [NSMutableArray arrayWithArray:[self arrayToLoanscapeCellArray:foldersWithoutBlank] ];
    [self.tableView reloadData];
}
- (void) viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAllData) name:MessageOfPadFolderWillReload object:nil];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void) didSelectedCatelog:(NSString *)keywords
{
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:TypeOfLocation], TypeOfCheckDocumentListType, keywords, TypeOfCheckDocumentListKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:TypeOfCheckDocument object:nil userInfo:userInfo];
}

@end
