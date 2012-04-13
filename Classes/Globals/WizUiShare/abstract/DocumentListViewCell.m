//
//  DocumentListViewCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "DocumentListViewCell.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "TTTAttributedLabel.h"
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizAbstractCache.h"

#define CellWithImageFrame CGRectMake(8,8,225,74) 
#define CellWithoutImageFrame CGRectMake(8,8,300,74)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;

@interface DocumentListViewCell()
+ (NSMutableDictionary*) getDetailAttributes;
+ (NSMutableDictionary*) getNameAttributes;
+ (NSMutableDictionary*) getTimeAttributes;
+ (UIFont*) nameFont;
@end
@implementation DocumentListViewCell
@synthesize abstractLabel;
@synthesize interfaceOrientation;
@synthesize abstractImageView;
@synthesize doc;
@synthesize accoutUserId;
@synthesize hasAbstract;
@synthesize downloadIndicator;
static NSMutableDictionary* detailAttributes;
static NSMutableDictionary* nameAttributes;
static NSMutableDictionary* timeAttributes;
static UIFont* nameFont;

+ (UIFont*) nameFont
{
    if(nameFont == nil)
    {
        nameFont = [UIFont boldSystemFontOfSize:15];
    }
    return nameFont;
}

+ (NSMutableDictionary*) getDetailAttributes
{
    if (detailAttributes == nil) {
        detailAttributes = [[NSMutableDictionary alloc] init];
        UIFont* textFont = [UIFont systemFontOfSize:13];
        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
        [detailAttributes setObject:(id)[[UIColor grayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
        [detailAttributes setObject:(id)textCtfont forKey:(NSString*)kCTFontAttributeName];
    }
    return detailAttributes;
}
+ (NSMutableDictionary*) getNameAttributes
{
    if (nameAttributes == nil) {
        nameAttributes = [[NSMutableDictionary alloc] init];
        UIFont* stringFont = [self nameFont];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        [nameAttributes setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting settings[]={lineBreakMode};
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        [nameAttributes setObject:(id)paragraphStyle forKey:(NSString*)kCTParagraphStyleAttributeName];
    }
    return nameAttributes;
}

+ (NSMutableDictionary*) getTimeAttributes
{
    if (timeAttributes == nil) {
        timeAttributes = [[NSMutableDictionary alloc] init];
        [timeAttributes setObject:(id)[[UIColor lightGrayColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    return timeAttributes;
}
- (void) dealloc
{
    self.abstractLabel = nil;
    self.abstractImageView = nil;
    self.doc = nil;
    self.accoutUserId = nil;
    self.hasAbstract = NO;
    self.downloadIndicator = nil;
    [super dealloc];
}

- (NSString*) nameToDisplay:(NSString*)str   width:(CGFloat)width
{
    UIFont* nameFont = [DocumentListViewCell nameFont];
    CGSize boundingSize = CGSizeMake(CGFLOAT_MAX, 20);
    CGSize requiredSize = [str sizeWithFont:nameFont constrainedToSize:boundingSize
                              lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat requireWidth = requiredSize.width;
    if (requireWidth > width) {
        if (nil == str || str.length <1) {
            return @"";
        }
        return [self nameToDisplay:[str substringToIndex:str.length-1 ] width:width];
    }
    else
    {
        return str;
    }
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        TTTAttributedLabel* abstractLabel_ = [[TTTAttributedLabel alloc] initWithFrame:CellWithImageFrame];
        abstractLabel_.numberOfLines  =0;
        abstractLabel_.backgroundColor = [UIColor clearColor];
        abstractLabel_.textAlignment = UITextAlignmentLeft;
        abstractLabel_.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        abstractLabel_.linkAttributes = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
        [self.contentView addSubview:abstractLabel_];
        self.abstractLabel = abstractLabel_;
        [abstractLabel_ release];
        UIImageView* abstractImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(240, 10, 70, 70)];
        [self.contentView addSubview:abstractImageView_];
        self.abstractImageView = abstractImageView_;
        [abstractImageView_ release];
        self.interfaceOrientation = UIInterfaceOrientationPortrait;
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
        UIActivityIndicatorView* downloadInc = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.downloadIndicator = downloadInc;
        self.downloadIndicator.hidesWhenStopped = YES;
        self.downloadIndicator.frame = CGRectMake(25, 25, 20, 20);
        [downloadInc release];
        [self.abstractImageView addSubview:self.downloadIndicator];
    }
    return self;
}

- (void) prepareForAppear
{
    WizAbstractData* abstract = [[WizAbstractCache shareCache] documentAbstractForIphone:self.doc.guid userID:self.accoutUserId];
   if (abstract.image != nil) {
        self.abstractLabel.frame = CellWithImageFrame;
        self.abstractImageView.hidden = NO;
    }
    else {
        self.abstractLabel.frame = CellWithoutImageFrame;
        self.abstractImageView.hidden = YES;
    }
    self.abstractLabel.text = abstract.text;
    self.abstractImageView.image = abstract.image;
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
