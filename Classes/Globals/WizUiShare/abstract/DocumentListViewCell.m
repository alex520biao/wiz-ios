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
}
@property (nonatomic, retain) UIImageView* imageView;
@end
@implementation DocumentListViewCell
@synthesize doc;
@synthesize downloadIndicator;
@synthesize abstractData;
@synthesize imageView;
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
        [imageV release];
        
        //
        CALayer* layer =  self.imageView.layer;
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.9;
//        CGSize size = self.imageView.bounds.size;
//        CGFloat curlFactor = 10;
//        CGFloat shadowDepth = 3.0f;
//        UIBezierPath *path = [UIBezierPath bezierPath];
//        [path moveToPoint:CGPointMake(0.0f, 0.0f)];
//        [path addLineToPoint:CGPointMake(size.width, 0.0f)];
//        [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
//        [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
//                controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
//                controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
//        layer.shadowPath = path.CGPath;
        [WizNotificationCenter addObserverForUpdateCache:self selector:@selector(updateAbstract:)];
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
    NSLog(@"abstract is %@",self.abstractData);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //trans View
    CGAffineTransform textTransform = CGAffineTransformMake(1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f);
	CGContextSetTextMatrix(context, textTransform);
	CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    
    NSInteger imageWidth = 80;
    if (nil != self.abstractData && nil ==self.abstractData.image) {
        [self.imageView removeFromSuperview];
        imageWidth = 0;
    }
    else {
        [self.contentView addSubview:self.imageView];
    }
    //
    NSAttributedString* title = [[NSAttributedString alloc] initWithString:[WizDecorate nameToDisplay:self.doc.title width:self.contentView.frame.size.width-imageWidth-10] attributes:[WizDecorate getNameAttributes]];
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)title);
    CGContextSetTextPosition(context, 5, 15);
    
    CTLineDraw(line, context);
    CFRelease(line);
    [title release];
    //time
    NSAttributedString* time = [[NSAttributedString alloc] initWithString:[self.doc.dateCreated stringLocal] attributes:[WizDecorate getTimeAttributes]];
    CTLineRef timeLine = CTLineCreateWithAttributedString((CFAttributedStringRef)timeLine);
    CGContextSetTextPosition(context, 5, 30);
    CTLineDraw(timeLine, context);
    CFRelease(timeLine);
    [time release];
   //
    if (self.abstractData.text != nil) {
        NSAttributedString* detail = [[NSAttributedString alloc] initWithString:self.abstractData.text attributes:[WizDecorate getDetailAttributes]];
        CTLineRef detailLine = CTLineCreateWithAttributedString((CFAttributedStringRef)detail);
        CGContextSetTextPosition(context, 5, 50);
        CTLineDraw(detailLine, context);
        CFRelease(detailLine);
    }
   
    
    if (nil != self.abstractData && nil != self.abstractData.image) {
        self.imageView.image = abstractData.image;
    }
    else {
        self.imageView.image = [DocumentListViewCell documentNoDataImage];
    }
    CGContextRestoreGState(context);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
@end
