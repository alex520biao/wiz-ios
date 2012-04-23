//
//  WizTableVIewCell.m
//  Wiz
//
//  Created by wiz on 12-3-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "WizTableVIewCell.h"

#import "WizGlobalData.h"
#import "TTTAttributedLabel.h"
#import "WizGlobals.h"
#import "CommonString.h"
#define CellWithImageFrame CGRectMake(10,10,225,70) 
#define CellWithoutImageFrame CGRectMake(10,10,300,70)
@interface WizTableViewCell()
{
    CALayer* backLayer;
}
@property (nonatomic, retain) CALayer* backLayer;
+ (NSMutableDictionary*) getDetailAttributes;
+ (NSMutableDictionary*) getNameAttributes;
+ (NSMutableDictionary*) getTimeAttributes;
@end
@implementation WizTableViewCell
@synthesize accountUserId;
@synthesize documemtGuid;
@synthesize backLayer;
static NSMutableDictionary* detailAttributes;
static NSMutableDictionary* nameAttributes;
static NSMutableDictionary* timeAttributes;
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
        UIFont* stringFont = [UIFont boldSystemFontOfSize:15];
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
        [timeAttributes setObject:(id)[[UIColor blueColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    return timeAttributes;
}
- (void) dealloc
{
    documemtGuid = nil;
    [super dealloc];
}
- (void) initBacklayer
{
    self.backLayer = [CALayer layer];
    backLayer.shadowColor = [[UIColor lightGrayColor] CGColor];
    backLayer.shadowRadius = 0.5f;
    backLayer.shadowOffset = CGSizeMake(1, 1);
    backLayer.shadowOpacity = 0.5f;
    backLayer.borderColor = [[UIColor whiteColor] CGColor];
    backLayer.borderWidth = 0.5f;
    backLayer.backgroundColor = [[UIColor clearColor]CGColor];
    backLayer.bounds = CGRectMake(0.0, 0.0, 80, 80);
    backLayer.position = CGPointMake(160, 40);
}
- (id) initWithUserIdAndDocGUID:(UITableViewCellStyle)style userId:(NSString *)userID
{
    self = [super initWithStyle:style reuseIdentifier:userID];
    if (self) {
        self.accountUserId = userID;
        [self initBacklayer];
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
    [dateStr addAttributes:[WizTableViewCell getTimeAttributes] range:NSMakeRange(0, dateStr.length)];
    return [dateStr autorelease];
}
- (NSMutableAttributedString*) decorateNameString:(NSString*)nameString
{
    nameString = [self display:nameString :320 :[UIFont systemFontOfSize:15]]; 
    NSMutableAttributedString* nameStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",nameString]];
    [nameStr addAttributes:[WizTableViewCell getNameAttributes] range:NSMakeRange(0, nameStr.length)];
    return [nameStr autorelease];
}

- (NSMutableAttributedString*) decorateDetailString:(NSString*)detailString
{
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithString:detailString];
    [text addAttributes:[WizTableViewCell getDetailAttributes] range:NSMakeRange(0, text.length)];
    return [text autorelease];
}
- (void) setFrameWithoutAbs
{
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
        NSString* tagName = getTagDisplayName(each.title);
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
    NSMutableAttributedString* timeStr = [self decorateTimeString:doc.dateCreated];
    NSMutableAttributedString* detailStr = [self decorateDetailString:detailText];
    [timeStr appendAttributedString:detailStr];
    [nameStr appendAttributedString:timeStr];
}
- (void) displayWithAbstract
{
    [self setFrameWithoutAbs];

}
- (void) drawRect:(CGRect)rect
{
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    WizDocument* doc = [index documentFromGUID:documemtGuid];
    WizAbstract* abstract = [index abstractOfDocument:documemtGuid];
    NSMutableAttributedString* nameStr = [self decorateNameString:doc.title];
    NSMutableAttributedString* timeStr = [self decorateTimeString:doc.dateModified];
    NSMutableAttributedString* detailStr = [self decorateDetailString:abstract.text];
    [timeStr appendAttributedString:detailStr];
    [nameStr appendAttributedString:timeStr];
    CGContextRef cgc = UIGraphicsGetCurrentContext();
    CGContextSaveGState(cgc);
    CGContextConcatCTM(cgc, CGAffineTransformScale(CGAffineTransformMakeTranslation(0, self.bounds.size.height), 1.0f, -1.0f));
    CTFramesetterRef famesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)nameStr);
    CGRect drawingRect = CGRectMake(0.0, 0.0, 200, 80);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(famesetter, CFRangeMake(0, 0), path, NULL);
    CGPathRelease(path);
    CFRelease(famesetter);
    CTFrameDraw(textFrame, cgc);
    CGContextRestoreGState(cgc);
    CALayer* lay =self.backLayer;
    lay.bounds = CGRectMake(0.0, 0.0, 80, 80);
    lay.position = CGPointMake([self.contentView bounds].size.width-50, [self.contentView bounds].size.height/2);
    if (!abstract.image) {
        UIImage* defaultImage = [UIImage imageNamed:@"documentWithoutData"];
        [defaultImage drawInRect:lay.frame];
    }
    else {
        [abstract.image drawInRect:lay.frame];
    }
    [[self.contentView layer] addSublayer:lay];
}
@end
