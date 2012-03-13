//
//  WizTableVIewCell.m
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizTableVIewCell.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "TTTAttributedLabel.h"
#import "WizGlobals.h"
#import "CommonString.h"
#define CellWithImageFrame CGRectMake(10,10,225,70) 
#define CellWithoutImageFrame CGRectMake(10,10,300,70)
@implementation WizTableViewCell
@synthesize abstractImageView;
@synthesize detailLabel;
@synthesize accountUserId;
@synthesize documemtGuid;
- (void) dealloc
{
    documemtGuid = nil;
    self.abstractImageView = nil;
    self.detailLabel = nil;
    [super dealloc];
}
- (id) initWithUserIdAndDocGUID:(UITableViewCellStyle)style userId:(NSString *)userID
{
    self = [super initWithStyle:style reuseIdentifier:userID];
    if (self) {
        self.accountUserId = userID;
        TTTAttributedLabel* label = [[TTTAttributedLabel alloc] init];
        self.detailLabel = label;
        label.numberOfLines  =0;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        label.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        label.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [label release];
        UIImageView* abstractImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(240, 10, 70, 70)];
        [self.contentView addSubview:abstractImageView_];
        self.abstractImageView = abstractImageView_;
        [abstractImageView_ release];
        CALayer* layer = [abstractImageView layer];
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.5;
        self.selectedBackgroundView = [[[UIView alloc] init] autorelease];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        UIImageView* breakView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 89, 320, 1)];
        breakView.image = [UIImage imageNamed:@"separetorLine"];
        [self addSubview:breakView];
        [breakView release];
        CALayer* selfLayer = [self.selectedBackgroundView layer];
        selfLayer.borderColor = [UIColor grayColor].CGColor;
        selfLayer.borderWidth = 0.5f;
        
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.abstractImageView];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (NSString*) display:(NSString*)str  :(CGFloat)width :(UIFont*)font
{
    CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, 20);
    CGSize requiredSize = [str sizeWithFont:font constrainedToSize:boundingSize
                              lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat requireWidth = requiredSize.width;
    if (requireWidth > width) {
        return [self display:[str substringToIndex:str.length -1] :width :font];
    }
    else
    {
        return str;
    }
    
}
- (NSMutableAttributedString*) decorateTimeString:(NSString*)timeString
{
    NSMutableAttributedString* dateStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",timeString]];
    [dateStr addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor lightGrayColor] CGColor] range:NSMakeRange(0,19)];
    return [dateStr autorelease];
}
- (NSMutableAttributedString*) decorateNameString:(NSString*)nameString
{
    nameString = [self display:nameString :320 :[UIFont systemFontOfSize:15]]; 
    NSMutableAttributedString* nameStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",nameString]];
    [nameStr addAttributes:[[WizGlobalData sharedData] attributesForDocumentListName] range:NSMakeRange(0, nameStr.length)];
    return [nameStr autorelease];
}

- (NSMutableAttributedString*) decorateDetailString:(NSString*)detailString
{
    UIFont* textFont = [UIFont systemFontOfSize:13];
    CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:detailString];
    [text addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor grayColor] CGColor] range:NSMakeRange(0,text.length)];
    [text addAttribute:(NSString*)kCTFontAttributeName value:(id)textCtfont range:NSMakeRange(0,text.length)];
    return [text autorelease];

}
- (void) setFrameWithoutAbs
{
    self.detailLabel.frame = CGRectMake(10.0, 10.0, 200, 80);
}
- (void) displayWithoutAbstract
{
    [self setFrameWithoutAbs];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:self.documemtGuid];
    NSString* detailText = nil;
    NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,doc.location == nil? @"":[WizGlobals folderStringToLocal:doc.location]];
    NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
    NSArray* tags = [index tagsByDocumentGuid:documemtGuid];
    for (WizTag* each in tags) {
        NSString* tagName = getTagDisplayName(each.name);
        tagstr = [tagstr stringByAppendingFormat:@"%@|",tagName];
    }
    if (![tagstr isEqualToString:[NSString stringWithFormat:@"%@:",WizStrTags]]) {
        tagstr = [tagstr substringToIndex:tagstr.length-1];
        folder = [folder stringByAppendingString:tagstr];
        detailText = folder;
    }
    else {
        detailText = folder;
    }
    NSMutableAttributedString* nameStr = [self decorateNameString:doc.title];
    NSMutableAttributedString* timeStr = [self decorateTimeString:doc.dateModified];
    NSMutableAttributedString* detailStr = [self decorateDetailString:detailText];
    [timeStr appendAttributedString:detailStr];
    [nameStr appendAttributedString:timeStr];
    self.abstractImageView.image = [UIImage imageNamed:@"documentWithoutData"];
    self.detailLabel.text = nameStr;
}
- (void) displayWithAbstract
{
    [self setFrameWithoutAbs];
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:documemtGuid];
    WizAbstract* abstract = [index abstractOfDocument:documemtGuid];
    if (!abstractImageView) {
        NSLog(@"no");
    }
    else {
        self.abstractImageView.image = abstract.image;
        NSMutableAttributedString* nameStr = [self decorateNameString:doc.title];
        NSMutableAttributedString* timeStr = [self decorateTimeString:doc.dateModified];
        NSMutableAttributedString* detailStr = [self decorateDetailString:abstract.text];
        [timeStr appendAttributedString:detailStr];
        [nameStr appendAttributedString:timeStr];
        self.detailLabel.text = nameStr;
    } 
}
- (void) drawRect:(CGRect)rect
{
    if (self.detailLabel.text == nil || [self.detailLabel.text isEqualToString:@"Loading..."]) {
        self.detailLabel.text = @"Loading...";
    }
    NSLog(@"%@",self.documemtGuid);
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    if ([index documentServerChanged:documemtGuid]) {
        [self performSelectorInBackground:@selector(displayWithoutAbstract) withObject:nil];
    }
    else {
        [self performSelectorInBackground:@selector(displayWithAbstract) withObject:nil];
    }
}
@end
