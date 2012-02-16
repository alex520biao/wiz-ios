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

#define CellWithImageFrame CGRectMake(10,10,225,70) 
#define CellWithoutImageFrame CGRectMake(10,10,300,70)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;
@implementation DocumentListViewCell
@synthesize abstractLabel;
@synthesize interfaceOrientation;
@synthesize abstractImageView;
@synthesize doc;
@synthesize accoutUserId;
@synthesize hasAbstract;


- (void) dealloc
{
    self.abstractLabel = nil;
    self.abstractImageView = nil;
    self.doc = nil;
    self.accoutUserId = nil;
    self.hasAbstract = NO;
    [super dealloc];
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
//        self.contentView.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0];
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
    }
    return self;
}

- (void) prepareForAppear
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accoutUserId];
    BOOL isAbstractExist = [index abstractExist:self.doc.guid];
    WizAbstract*   abstract = [index  abstractOfDocument:self.doc.guid];
    if (!isAbstractExist && ![index documentServerChanged:self.doc.guid]) {
        NSString* documentFilePath = [WizIndex documentFileName:self.accoutUserId documentGUID:self.doc.guid];
        if ([[NSFileManager defaultManager] fileExistsAtPath:documentFilePath]) {
            [index performSelectorInBackground:@selector(extractSummary:) withObject:doc.guid];
        }
        NSLog(@"%@",doc.title);
    }
    if ( isAbstractExist && abstract!= nil) {
        UIFont* stringFont = [UIFont boldSystemFontOfSize:15];
        NSString* title = [NSString stringWithString:self.doc.title];
        if (nil == abstract.image) {
            title = [self display:title :300 :stringFont];
            abstractImageView.hidden = YES;
            abstractLabel.frame = CellWithoutImageFrame;
        }
        else
        {
            title = [self display:title :230 :stringFont];
            abstractLabel.frame = CellWithImageFrame;
            abstractImageView.hidden = NO;
        }
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        NSMutableAttributedString* nameStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",title]];
        [nameStr addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:NSMakeRange(0, nameStr.length)];
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting settings[]={lineBreakMode};
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        [nameStr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphStyle range:NSMakeRange(0, nameStr.length)];
        NSMutableAttributedString* dateStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",self.doc.dateModified]];
        [dateStr addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor lightGrayColor] CGColor] range:NSMakeRange(0,19)];
        self.hasAbstract = YES;
        if (abstract.text == nil) {
            abstract.text = @"";
        }
        UIFont* textFont = [UIFont systemFontOfSize:13];
        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
        NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:abstract.text];
        [text addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor grayColor] CGColor] range:NSMakeRange(0,text.length)];
        [text addAttribute:(NSString*)kCTFontAttributeName value:(id)textCtfont range:NSMakeRange(0,text.length)];
        [dateStr appendAttributedString:text];
        [text release];
        self.abstractImageView.image = abstract.image;
        [nameStr appendAttributedString:dateStr];
        [self.abstractLabel setText:nameStr];
        [nameStr release];
        [dateStr release];

    }
    else
    {
        UIFont* stringFont = [UIFont boldSystemFontOfSize:15];
        NSString* title = [NSString stringWithString:self.doc.title];
        NSRange titleRange = NSMakeRange(0, 20<title.length?20:title.length);
        abstractLabel.frame = CellWithImageFrame;
        abstractImageView.hidden = NO;
        abstractImageView.image = [UIImage imageNamed:@"documentWithoutData"];
        title = [title substringWithRange:titleRange];
        CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
        NSMutableAttributedString* nameStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",title]];
        [nameStr addAttribute:(NSString*)kCTFontAttributeName value:(id)font range:NSMakeRange(0, nameStr.length)];
        CTLineBreakMode lineBreakMode = kCTLineBreakByCharWrapping;
        CTParagraphStyleSetting settings[]={lineBreakMode};
        CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings));
        [nameStr addAttribute:(id)kCTParagraphStyleAttributeName value:(id)paragraphStyle range:NSMakeRange(0, nameStr.length)];
        NSMutableAttributedString* dateStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",self.doc.dateModified]];
        [dateStr addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor lightGrayColor] CGColor] range:NSMakeRange(0,19)];
        
        NSString* tagstr = [NSString stringWithFormat:@"%@:%@\n%@:",NSLocalizedString(@"Folder", nil),self.doc.location == nil? @"":[WizGlobals folderStringToLocal:self.doc.location],NSLocalizedString(@"Tags", nil)];
        WizIndex* index = [[WizGlobalData sharedData] indexData:self.accoutUserId];
        NSArray* tags = [index tagsByDocumentGuid:self.doc.guid];
        for (WizTag* each in tags) {
            tagstr = [tagstr stringByAppendingFormat:@"|%@",NSLocalizedString(each.name, nil)];
        }
        
        UIFont* textFont = [UIFont systemFontOfSize:13];
        CTFontRef textCtfont = CTFontCreateWithName((CFStringRef)textFont.fontName, textFont.pointSize, NULL);
        NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:tagstr];
        [text addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor grayColor] CGColor] range:NSMakeRange(0,text.length)];
        [text addAttribute:(NSString*)kCTFontAttributeName value:(id)textCtfont range:NSMakeRange(0,text.length)];
        [dateStr appendAttributedString:text];
        [nameStr appendAttributedString:dateStr];
        [self.abstractLabel setText:nameStr];
        [dateStr release];
        [nameStr release];
        [text release];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
