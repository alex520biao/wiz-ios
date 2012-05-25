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
#import "WizAbstractCache.h"
#import "WizNotification.h"
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

- (void) didUpdateCache:(NSNotification*)nc
{
    if (nil == doc) {
        return;
    }
    NSString* documentGuid = [WizNotificationCenter getDocumentGUIDFromNc:nc];
    if (documentGuid == nil) {
        return;
    }
    if (![documentGuid isEqualToString:self.doc.guid]) {
        return;
    }
    [self setNeedsDisplay];
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
        
        [WizNotificationCenter addObserverForUpdateCache:self selector:@selector(didUpdateCache:)];
    }
    return self;
}



- (void) didSelectedDocument
{
    self.backgroundColor = [UIColor blueColor];
    [self.selectedDelegate didSelectedDocument:self.doc];
}

//- (void) setDocument:(WizDocument*) document
//{
//    self.doc = document;
//    self.nameLabel.text = @"";
//    self.abstractImageView.image = nil;
//    self.nameLabel.text = document.title;
//    NSMutableAttributedString* abstractString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",self.doc.dateModified]];
//    [abstractString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, abstractString.length)];
//    float startPointX = 10.0f;
//    if (YES) {
//        WizAbstract* abstract = [[WizDbManager shareDbManager] abstractOfDocument:document.guid];
//        NSMutableAttributedString* abstractText = [[NSMutableAttributedString alloc] initWithString:abstract.text];
//        NSRange textRange =NSMakeRange(0, abstractText.length);
//        [abstractText addAttributes:[[WizGlobalData sharedData] attributesForAbstractViewParagraphPad]  range:textRange];
//        [abstractString appendAttributedString:abstractText];
//         if (nil != abstract.image) {
//            self.abstractImageView.frame = AbstractImageviewFrame;
//            self.abstractImageView.image = abstract.image;
//            self.abstractImageView.frame= CGRectMake(0.0, 0.0, abstract.image.size.width , abstract.image.size.height);
//            self.abstractImageView.center = CGPointMake(102.5, 187.5);
//        }else
//        {
//            self.abstractImageView.frame = CGRectMake(startPointX, 0.0, 0.0, 0.0);
//        }
//        [abstractText release];
//    }
//    else
//    {
//        NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,self.doc.location == nil? @"":[WizGlobals folderStringToLocal:self.doc.location]];
//        NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
//        NSArray* tags = [self.doc tagDatas];
//        for (WizTag* each in tags) {
//            NSString* tagName = getTagDisplayName(each.title);
//            tagstr = [tagstr stringByAppendingFormat:@"%@|",tagName];
//        }
//        if (![tagstr isEqualToString:[NSString stringWithFormat:@"%@:",WizStrTags]]) {
//            if (tagstr != nil && tagstr.length > 1) {
//                tagstr = [tagstr substringToIndex:tagstr.length-1];
//                folder = [folder stringByAppendingString:tagstr];
//            }
//            
//            
//        }
//        NSMutableAttributedString* detail = [[NSMutableAttributedString alloc] initWithString:folder attributes:[WizPadDocumentAbstractView detailDecorator]];
//        [abstractString appendAttributedString:detail];
//        [detail release];
//        self.abstractImageView.image = nil;
//    }
//    [abstractString release];
//    self.userInteractionEnabled = YES;
//}
- (void) drawRect:(CGRect)rect
{
    if(self.doc == nil)
    {
        return;
    }
    nameLabel.text = self.doc.title;
    timeLabel.text = [self.doc.dateCreated stringSql];
    WizAbstract* abstract = [[WizAbstractCache shareCache] documentAbstractForIphone:self.doc];
    if (abstract == nil) {
        detailLabel.text = self.doc.location;
        detailLabel.frame = AbstractLabelWithImageFrame;
        abstractImageView.image = [UIImage imageNamed:@"documentWithoutData"];
    }
    else {
        if (abstract.image == nil) {
            detailLabel.frame = AbstractLabelWithoutImageFrame;
            abstractImageView.hidden = YES;
        }
        else {
            detailLabel.frame = AbstractLabelWithImageFrame;
            abstractImageView.hidden = NO;
            abstractImageView.image = abstract.image;
        }
        detailLabel.text = abstract.text;
    }
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
