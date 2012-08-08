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

#define NameLabelFrame CGRectMake(15, 5, 175, 45)
#define TimerLabelFrame CGRectMake(15,45,175,20)

#define AbstractLabelWithoutImageFrame CGRectMake(15, 65, 175, 180)
#define AbstractLabelWithImageFrame CGRectMake(15, 65, 175, 80)
#define AbstractImageviewFrame CGRectMake(15, 145, 175, 85)

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
    //
    void (^drawAbstractNeedDisplays)(WizAbstract*) = ^(WizAbstract* abstract)
    {
            if (abstract)
            {
                if (abstract.image == nil) {
                    detailLabel.frame = AbstractLabelWithoutImageFrame;
                    abstractImageView.hidden = YES;
                }
                else
                {
                    detailLabel.frame = AbstractLabelWithImageFrame;
                    abstractImageView.hidden = NO;
                    abstractImageView.image = abstract.image;
                }
                detailLabel.text = abstract.text;
            }
            else
            {
                detailLabel.text = self.doc.location;
                detailLabel.frame = AbstractLabelWithImageFrame;
                abstractImageView.hidden = NO;

            }
    };
    
    //
    
    nameLabel.text = self.doc.title;
    timeLabel.text = [self.doc.dateCreated stringSql];
    
    //
    WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstract:self.doc.guid];
    drawAbstractNeedDisplays(abstract);
    //
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
                if (nil != abstract) {
                    drawAbstractNeedDisplays(abstract);
                }

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
        nameLabel = [[UILabel alloc] initWithFrame:NameLabelFrame];
        nameLabel.numberOfLines = 0;
        [self addSubview:nameLabel];
        [nameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        nameLabel.backgroundColor = [UIColor clearColor];
        abstractImageView = [[UIImageView alloc] initWithFrame:AbstractImageviewFrame];
        [self addSubview:abstractImageView];
        abstractImageView.image = [UIImage imageNamed:@"documentBack"];
        timeLabel = [[UILabel alloc] initWithFrame:TimerLabelFrame];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:12];
        timeLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:timeLabel];
        [self addSelcetorToView:@selector(didSelectedDocument) :self];
        detailLabel = [[UILabel alloc] initWithFrame:AbstractLabelWithoutImageFrame];
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
