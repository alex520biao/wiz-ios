//
//  DocumentListViewCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-12-31.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "DocumentListViewCell.h"
#import "WizGlobalData.h"
#import "TTTAttributedLabel.h"
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizAbstractCache.h"
#import "WizDecorate.h"
#import "WizNotification.h"
#import "WizDbManager.h"

//#define CellWithImageFrame CGRectMake(8,8,225,74)
//#define CellWithoutImageFrame CGRectMake(8,8,300,74)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;

#define AbstractImageWidth  75
@interface DocumentListViewCell()
{
    UIImageView* imageView;
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
}
@property (nonatomic, retain) UIImageView* imageView;
@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UILabel* timeLabel;
@property (nonatomic, retain) UILabel* detailLabel;
@end
@implementation DocumentListViewCell
@synthesize doc;
@synthesize downloadIndicator;
@synthesize abstractData;
@synthesize imageView;
@synthesize nameLabel;
@synthesize timeLabel;
@synthesize detailLabel;
+ (UIImage*) documentNoDataImage
{
    static UIImage* placeHoderImage;
    @synchronized (placeHoderImage)
    {
        if (nil == placeHoderImage) {
            placeHoderImage = [UIImage imageNamed:@"documentWithoutData"];
        }
    }
    return placeHoderImage;
}
- (void) dealloc
{
    [WizNotificationCenter removeObserver:self];
    [abstractData release];
    [doc release];
    [super dealloc];
}
- (CGRect) getRectWithImage
{
    return CGRectMake(8, 8, self.contentView.frame.size.width-20-75, 74);
}

- (CGRect) getRectWithoutImage
{
    return CGRectMake(8, 8, self.contentView.frame.size.width-20, 74);
}
- (void) updateAbstract:(NSNotification*)nc
{
    NSString* documentGuid = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    if ([documentGuid isEqualToString:self.doc.guid]) {
        [self prepareForAppear];
    }
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[[UIView alloc] init] autorelease];
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:0.5];
        UIImageView* breakView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 89, 480, 1)];
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
        
        UIImageView* imageV = [[UIImageView alloc] init];
        CGRect imageRect = CGRectMake(self.contentView.frame.size.width-80, 7, 75, 75);
        self.imageView = imageV;
        self.imageView.frame = imageRect;
        [self.contentView addSubview:self.imageView];
        [imageV release];
        
        CALayer* layer =  self.imageView.layer;
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.9;
        [WizNotificationCenter addObserverForUpdateCache:self selector:@selector(updateAbstract:)];
        
        
        UILabel* l1 = [[UILabel alloc] init];
        self.timeLabel = l1;
        l1.font = [UIFont systemFontOfSize:12];
        l1.textColor = [UIColor lightGrayColor];
        l1.backgroundColor = [UIColor clearColor];
        [l1 release];
        
        UILabel* l2 = [[UILabel alloc] init];
        self.nameLabel = l2;
        l2.backgroundColor = [UIColor clearColor];
        l2.font = [UIFont boldSystemFontOfSize:16];
        [l2 release];
        
        UILabel* l3 = [[UILabel alloc] init];
        self.detailLabel = l3;
        l3.font = [UIFont systemFontOfSize:13];
        l3.backgroundColor = [UIColor clearColor];
        l3.numberOfLines = 0;
        [l3 release];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.detailLabel];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.5];
    }
    return self;
}

- (void) prepareForAppear
{
    self.doc = [WizDocument documentFromDb:self.doc.guid];
    WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstractForIphone:self.doc];
    self.abstractData = abstract;
    [self performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:YES];
}
- (void) drawRect:(CGRect)rect
{
    NSInteger leftBreakWidth = 10;

    NSInteger rightBreakWidth = 90;
    if (nil != self.abstractData && nil ==self.abstractData.image) {
        self.imageView.hidden = YES;
        rightBreakWidth = 20;
    }
    else {
        self.imageView.frame = CGRectMake(self.frame.size.width-80, 10, 70, 70);
        self.imageView.hidden = NO;
    }
    self.nameLabel.frame = CGRectMake(leftBreakWidth, 8, self.frame.size.width-rightBreakWidth, 20);
    self.timeLabel.frame = CGRectMake(leftBreakWidth, 30, self.frame.size.width-rightBreakWidth, 12);
    self.detailLabel.frame = CGRectMake(leftBreakWidth, 42, self.frame.size.width-rightBreakWidth, 40);
    self.nameLabel.text = self.doc.title;
    self.timeLabel.text = [self.doc.dateModified stringSql];
    self.detailLabel.text = self.abstractData.text;
    if (nil != self.abstractData && nil != self.abstractData.image) {
        self.imageView.image = abstractData.image;
    }
    else {
        self.imageView.image = [DocumentListViewCell documentNoDataImage];
    }
}
//- (void) drawRect:(CGRect)rect
//{
//    NSInteger leftBreakWidth = 10;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSaveGState(context);
//    //trans View
//    CGAffineTransform textTransform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f);
//	CGContextSetTextMatrix(context, textTransform);
//	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
//    NSInteger rightBreakWidth = 90;
//    if (nil != self.abstractData && nil ==self.abstractData.image) {
//        self.imageView.hidden = YES;
//        rightBreakWidth = 10;
//    }
//    else {
//        self.imageView.frame = CGRectMake(self.frame.size.width-80, 10, 70, 70);
//        self.imageView.hidden = NO;
//    }
//    //title
//    NSAttributedString* title = [[NSAttributedString alloc] initWithString:[WizDecorate nameToDisplay:self.doc.title width:self.contentView.frame.size.width-rightBreakWidth] attributes:[WizDecorate getNameAttributes]];
//    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)title);
//    CGContextSetTextPosition(context, leftBreakWidth, 20);
//    CTLineDraw(line, context);
//    CFRelease(line);
//    [title release];
//    //time
//    NSAttributedString* time = [[NSAttributedString alloc] initWithString:[self.doc.dateCreated stringLocal] attributes:[WizDecorate getTimeAttributes]];
//    CTLineRef timeLine = CTLineCreateWithAttributedString((CFAttributedStringRef)time);
//    CGContextSetTextPosition(context, leftBreakWidth, 35);
//    CTLineDraw(timeLine, context);
//    CFRelease(timeLine);
//    [time release];
//   //
//    NSString* folderString = [WizGlobals folderStringToLocal:self.doc.location];
//    NSString* detailStr = @"";
//    if (self.abstractData.text != nil) {
//        detailStr = [self.abstractData.text stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
//    }
//    else if (folderString != nil){
//        detailStr = folderString;
//    }
//    NSAttributedString* detail = [[NSAttributedString alloc] initWithString:detailStr attributes:[WizDecorate getDetailAttributes]];
//    CGContextSetTextMatrix(context , CGAffineTransformIdentity);
//    CGContextTranslateCTM(context , 0 ,self.bounds.size.height);
//    CGContextScaleCTM(context, 1.0 ,-1.0);
//    CTFramesetterRef frameStter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)detail);
//    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
//    CGPathAddRect(leftColumnPath, NULL, CGRectMake(leftBreakWidth, 5, self.bounds.size.width-rightBreakWidth, self.bounds.size.height-45));
//    CTFrameRef textFrame = CTFramesetterCreateFrame(frameStter, CFRangeMake(0.0, 0.0), leftColumnPath, NULL);
//    CTFrameDraw(textFrame, context);
//    CFRelease(textFrame);
//    CFRelease(frameStter);
//    CFRelease(leftColumnPath);
//    [detail release];
//    if (nil != self.abstractData && nil != self.abstractData.image) {
//        self.imageView.image = abstractData.image;
//    }
//    else {
//        self.imageView.image = [DocumentListViewCell documentNoDataImage];
//    }
//    CGContextRestoreGState(context);
//}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
