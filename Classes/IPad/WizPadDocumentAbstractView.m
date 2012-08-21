//
//  WizPadDocumentAbstractView.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentAbstractView.h"
#import "WizGlobalData.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"
#import "WizDbManager.h"
#import "WizNotification.h"
#import "WizAbstractCache.h"


@interface WizPadDocumentAbstractView()
{
    UILabel* nameLabel;
    UILabel* timeLabel;
    UILabel* detailLabel;
    UIImageView* abstractImageView;
}
@end

@implementation WizPadDocumentAbstractView
@synthesize doc;
@synthesize selectedDelegate;
- (void) dealloc
{
    selectedDelegate = nil;
    [doc release];
    doc = nil;
    [nameLabel release];
    nameLabel = nil;
    [timeLabel release];
    timeLabel = nil;
    [detailLabel release];
    detailLabel = nil;
    [abstractImageView release];
    abstractImageView = nil;
    [WizNotificationCenter removeObserver:self];
    [super dealloc];
}
-(void) addSelcetorToView:(SEL)sel :(UIView*)view
{
    UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:sel] autorelease];
    tap.numberOfTapsRequired =1;
    tap.numberOfTouchesRequired =1;
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
}

- (void) updateView
{
    if(self.doc == nil)
    {
        return;
    }
    abstractImageView.image = nil;
    detailLabel.text = nil;
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    float contentStartX = 0.07*width;
    float contentWidth = width - contentStartX*2;
    float nameLabelStartY = 0.02*height;
    float nameLabelHeight = 0.08*height;
    float timerLabelHeight = 0.08*height;
    float abstractLabelWithImageHeight = 0.32*height;
    float abstractLabelWithoutImageHeight = 0.72*height;
    float abstractImageHeight = 0.34*height;
    
    nameLabel.frame = CGRectMake(contentStartX, nameLabelStartY, contentWidth, nameLabelHeight);
    timeLabel.frame = CGRectMake(contentStartX, nameLabelHeight + nameLabelStartY, contentWidth, timerLabelHeight);
    abstractImageView.frame = CGRectMake(contentStartX, height - abstractImageHeight, contentWidth, abstractImageHeight);
    //
    void (^drawAbstractNeedDisplays)(void) = ^()
    {
        WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstract:self.doc.guid];
            if (abstract)
            {
                if (abstract.image == nil) {
                    detailLabel.frame =  CGRectMake(contentStartX, nameLabelStartY + nameLabelHeight + timerLabelHeight, contentWidth, abstractLabelWithoutImageHeight);
                    abstractImageView.hidden = YES;
                }
                else
                {
                    detailLabel.frame = CGRectMake(contentStartX, nameLabelStartY + nameLabelHeight + timerLabelHeight, contentWidth, abstractLabelWithImageHeight);
                    abstractImageView.hidden = NO;
                    abstractImageView.image = abstract.image;
                }
                detailLabel.text = abstract.text;
            }
            else
            {
                detailLabel.text = self.doc.location;
                detailLabel.frame = CGRectMake(contentStartX, nameLabelStartY + nameLabelHeight + timerLabelHeight, contentWidth, abstractLabelWithImageHeight);
                abstractImageView.hidden = NO;

            }
    };
    
    //
    
    nameLabel.text = self.doc.title;
    timeLabel.text = [self.doc.dateCreated stringSql];
    
    //

    drawAbstractNeedDisplays();
    //
    WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstract:self.doc.guid];
    if (!abstract)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            id<WizTemporaryDataBaseDelegate> abstractDataBase = [[WizDbManager shareDbManager] shareAbstractDataBase];
            WizAbstract* abstract = [abstractDataBase abstractOfDocument:self.doc.guid];
            if (!abstract && self.doc.serverChanged==0) {
                [abstractDataBase extractSummary:self.doc.guid kbGuid:@""];
                abstract = [abstractDataBase abstractOfDocument:self.doc.guid];
            }
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [[WizAbstractCache shareCache] addDocumentAbstract:self.doc abstract:abstract];
                drawAbstractNeedDisplays();

            });
            [pool drain];
        });
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        UIImageView* backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentAbstractBackgroud"]];
        backgroudView.frame = CGRectMake(-7.5, 0.0, frame.size.width+15, frame.size.height+15);
        [self addSubview:backgroudView];
        [backgroudView release];
        nameLabel = [[UILabel alloc] init];
        nameLabel.numberOfLines = 0;
        [self addSubview:nameLabel];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel.backgroundColor = [UIColor clearColor];
        abstractImageView = [[UIImageView alloc] init];
        [self addSubview:abstractImageView];
        abstractImageView.image = [UIImage imageNamed:@"documentBack"];
        timeLabel = [[UILabel alloc] init];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:timeLabel];
        [self addSelcetorToView:@selector(didSelectedDocument) :self];
        detailLabel = [[UILabel alloc] init];
        [self addSubview:detailLabel];
        detailLabel.numberOfLines = 0;
        detailLabel.backgroundColor = [UIColor clearColor];
        detailLabel.font = [UIFont systemFontOfSize:13];
    }
    return self;
}



- (void) didSelectedDocument
{
    self.backgroundColor = [UIColor blueColor];
    [self.selectedDelegate didSelectedDocument:self.doc];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor blueColor];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [UIColor whiteColor];
}
@end
