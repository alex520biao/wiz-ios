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
#import "WizGlobals.h"
#import "CommonString.h"
#import "WizAbstractCache.h"
#import "WizDecorate.h"
#import "WizNotification.h"
#import "WizDbManager.h"
#import "WizSyncManager.h"

//#define CellWithImageFrame CGRectMake(8,8,225,74)
//#define CellWithoutImageFrame CGRectMake(8,8,300,74)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;

#define AbstractImageWidth  75
@interface DocumentListViewCell()
{
    UIImageView* abstractImageView;
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
    UIImageView* downloadIndicator;
}
@end
@implementation DocumentListViewCell
@synthesize doc;
@synthesize abstractData;
@synthesize showDownloadIndicator;
+ (UIImage*) documentNoDataImage
{
    static UIImage* placeHoderImage;
    @synchronized (placeHoderImage)
    {
        if (nil == placeHoderImage) {
            placeHoderImage = [[UIImage imageNamed:@"documentWithoutData"] retain];
        }
    }
    return placeHoderImage;
}
- (void) dealloc
{
    [timeLabel release];
    timeLabel = nil;
    
    [abstractImageView release];
    abstractImageView = nil;
    //
    [detailLabel release];
    detailLabel = nil;
    //
    [nameLabel release];
    nameLabel = nil;
    //
    [downloadIndicator release];
    downloadIndicator = nil;
    //
    [abstractData release];
    abstractData = nil;
    //
    [doc release];
    //
    doc = nil;
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
        
        abstractImageView = [[UIImageView alloc] init];
        CGRect imageRect = CGRectMake(self.contentView.frame.size.width-80, 7, 75, 75);
        abstractImageView.frame = imageRect;
        [self.contentView addSubview:abstractImageView];
        
        CALayer* layer =  abstractImageView.layer;
        layer.borderColor = [UIColor whiteColor].CGColor;
        layer.borderWidth = 0.5f;
        layer.shadowColor = [UIColor grayColor].CGColor;
        layer.shadowOffset = CGSizeMake(1, 1);
        layer.shadowOpacity = 0.5;
        layer.shadowRadius = 0.9;
        
        //
        timeLabel = [[UILabel alloc] init];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.backgroundColor = [UIColor clearColor];
        //
        nameLabel = [[UILabel alloc] init];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        //
        detailLabel = [[UILabel alloc] init];
        detailLabel.font = [UIFont systemFontOfSize:13];
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.numberOfLines = 0;
        //
        [self.contentView addSubview:timeLabel];
        [self.contentView addSubview:nameLabel];
        [self.contentView addSubview:detailLabel];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:0.5];
        
        //
        downloadIndicator = [[UIImageView alloc] init ];
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:4];
        for (int i = 0; i < 5; i++) {
            UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"downloadIndicator%d",i]];
            if (nil == image) {
                continue;
            }
            [images addObject:image];
        }
        downloadIndicator.animationImages = images;
        downloadIndicator.animationDuration = 0.8;
        [self.contentView addSubview:downloadIndicator];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    NSInteger leftBreakWidth = 10;
    NSInteger rightBreakWidth = 90;
    
    abstractImageView.frame = CGRectMake(self.frame.size.width-80, 10, 70, 70);
    abstractImageView.hidden = NO;
    detailLabel.text = [WizGlobals folderStringToLocal:self.doc.location];
    abstractImageView.image = [DocumentListViewCell documentNoDataImage];
    nameLabel.frame = CGRectMake(leftBreakWidth, 8, self.frame.size.width-rightBreakWidth, 20);
    timeLabel.frame = CGRectMake(leftBreakWidth, 30, self.frame.size.width-rightBreakWidth, 12);
    detailLabel.frame = CGRectMake(leftBreakWidth, 42, self.frame.size.width-rightBreakWidth, 40);
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        id<WizAbstractDbDelegate> abstractDataBase = [WizDbManager shareDbManager] getWizTempDataBase:<#(NSString *)#>
        
    });
    
    
    if (nil != self.abstractData && nil ==self.abstractData.image) {
        abstractImageView.hidden = YES;
        rightBreakWidth = 20;
    }
    else {
        
    }
    downloadIndicator.frame = CGRectMake(self.frame.size.width-30, 60, 20, 20);
    if ([[WizSyncManager shareManager] isDownloadingWizobject:self.doc]) {
        [downloadIndicator startAnimating];
    }
    else
    {
        [downloadIndicator stopAnimating];
    }

    nameLabel.text = self.doc.title;
    timeLabel.text = [self.doc.dateModified stringSql];
    detailLabel.text = self.abstractData.text;
    if (nil != self.abstractData)
    {
        if (nil != self.abstractData.image) {
            abstractImageView.image = abstractData.image;
        }
    }
    else {
        
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if ([[WizSyncManager shareManager] isDownloadingWizobject:self.doc]) {
        [downloadIndicator startAnimating];
    }
    else
    {
        [downloadIndicator stopAnimating];
    }
}
@end
