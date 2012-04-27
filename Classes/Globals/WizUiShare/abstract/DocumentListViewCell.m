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

//#define CellWithImageFrame CGRectMake(8,8,225,74)
//#define CellWithoutImageFrame CGRectMake(8,8,300,74)
int CELLHEIGHTWITHABSTRACT = 90;
int CELLHEIGHTWITHOUTABSTRACT = 50;

@implementation DocumentListViewCell
@synthesize abstractLabel;
@synthesize interfaceOrientation;
@synthesize abstractImageView;
@synthesize doc;
@synthesize hasAbstract;
@synthesize downloadIndicator;

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
        TTTAttributedLabel* abstractLabel_ = [[TTTAttributedLabel alloc] initWithFrame:[self getRectWithImage]];
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
        [self.abstractImageView addSubview:self.downloadIndicator];
    }
    return self;
}

- (void) prepareForAppear
{
    WizAbstractData* abstract = [[WizAbstractCache shareCache] documentAbstractForIphone:self.doc.guid];
    self.abstractImageView.frame = CGRectMake(self.contentView.frame.size.width - 75, 10, 70, 70);
    if (abstract.image != nil) {
        self.abstractLabel.frame = [self getRectWithImage];
        self.abstractImageView.hidden = NO;
    }
    else {
        self.abstractLabel.frame = [self getRectWithoutImage];
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
