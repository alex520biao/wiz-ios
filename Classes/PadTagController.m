//
//  PadTagController.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PadTagController.h"
#import "WizGlobalData.h"
#import "WizIndex.h"
#import "WizPadNotificationMessage.h"
#import "WizUiTypeIndex.h"
#import "CatelogTagCell.h"
#import "TTTAttributedLabel.h"
@implementation PadTagController

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


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void) reloadAllData
{
    NSMutableDictionary* attributeDic = [NSMutableDictionary dictionary];
    [attributeDic setObject:(id)[[UIColor grayColor] CGColor]  forKey:(NSString *)kCTForegroundColorAttributeName];


    
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    NSArray* tags = [index allTagsForTree];
    NSMutableArray* tagsWithoutBlank = [NSMutableArray array];
    for (WizTag* eachTag in tags) {
        NSArray* documents = [index documentsByTag:eachTag.guid];
        if ([documents count]) {
            WizPadCatelogData* data = [[WizPadCatelogData alloc] init];
            data.name = eachTag.name;
            data.count = [NSString stringWithFormat:@"%d %@",[documents count],NSLocalizedString(@"notes", nil)];
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
            long characheterSpacing = 0.5f;
            CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &characheterSpacing);
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
            data.keyWords = eachTag.guid;
            [tagsWithoutBlank addObject:data];
            [data release];
        }
    }
    if (nil == self.landscapeContentArray) {
        self.landscapeContentArray = [NSMutableArray array];
    }
    if (nil == self.portraitContentArray) 
    {
        self.portraitContentArray = [NSMutableArray array];
    }
    self.portraitContentArray =  [[self arrayToPotraitCellArraty:tagsWithoutBlank]mutableCopy];
    self.landscapeContentArray =  [[self arrayToLoanscapeCellArray:tagsWithoutBlank] mutableCopy];
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
    if (UIInterfaceOrientationIsLandscape(self.willToOrientation)) {
        [cell setContent:[self.landscapeContentArray objectAtIndex:indexPath.row]];
    }
    else
    {
        [cell setContent:[self.portraitContentArray objectAtIndex:indexPath.row]];
    }
    return cell;
}
@end
