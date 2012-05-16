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
#define NameLabelFrame CGRectMake(15, 10, 175, 40)
#define AbstractLabelWithoutImageFrame CGRectMake(15, 50, 175, 190)
#define AbstractLabelWithImageFrame CGRectMake(15, 50, 175, 85)
#define AbstractImageviewFrame CGRectMake(15, 145, 175, 85)

@interface WizPadDocumentAbstractView ()   
+ (NSMutableDictionary*) timeDecorator;
+ (NSMutableDictionary*) nameDecorator;
+ (NSMutableDictionary*) detailDecorator;
@end

@implementation WizPadDocumentAbstractView
@synthesize nameLabel;
@synthesize abstractImageView;
@synthesize timeLabel;
@synthesize detailLabel;
@synthesize doc;

static NSMutableDictionary* timeDecorator;
static NSMutableDictionary* nameDecorator;
static NSMutableDictionary* detailDecorator;

- (void) dealloc
{
    [doc release];
    [nameLabel release];
    [timeLabel release];
    [detailLabel release];
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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView* backgroudView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentAbstractBackgroud"]];
        backgroudView.frame = CGRectMake(-7.5, 0.0, frame.size.width+15, frame.size.height+15);
        [self addSubview:backgroudView];
        [backgroudView release];
        UILabel* nameLabel_ = [[UILabel alloc] initWithFrame:NameLabelFrame];
        [self addSubview:nameLabel_];
        [nameLabel_ release];
        self.nameLabel = nameLabel_;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        
        
        UIImageView* abstractImageView_ = [[UIImageView alloc] initWithFrame:AbstractImageviewFrame];
        [self addSubview:abstractImageView_];
        self.abstractImageView = abstractImageView_;
        self.abstractImageView.image = [UIImage imageNamed:@"documentBack"];
        [abstractImageView_ release];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
- (void) didSelectedDocument
{
    self.backgroundColor = [UIColor blueColor];
}

- (void) setDocument:(WizDocument*) document
{
    self.doc = document;
    self.nameLabel.text = @"";
    self.abstractImageView.image = nil;
    self.nameLabel.text = document.title;
    NSMutableAttributedString* abstractString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",self.doc.dateModified]];
    [abstractString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, abstractString.length)];
    float startPointX = 10.0f;
    if (YES) {
        WizAbstract* abstract = [[WizDbManager shareDbManager] abstractOfDocument:document.guid];
        NSMutableAttributedString* abstractText = [[NSMutableAttributedString alloc] initWithString:abstract.text];
        NSRange textRange =NSMakeRange(0, abstractText.length);
        [abstractText addAttributes:[[WizGlobalData sharedData] attributesForAbstractViewParagraphPad]  range:textRange];
        [abstractString appendAttributedString:abstractText];
         if (nil != abstract.image) {
            self.abstractImageView.frame = AbstractImageviewFrame;
            self.abstractImageView.image = abstract.image;
            self.abstractImageView.frame= CGRectMake(0.0, 0.0, abstract.image.size.width , abstract.image.size.height);
            self.abstractImageView.center = CGPointMake(102.5, 187.5);
        }else
        {
            self.abstractImageView.frame = CGRectMake(startPointX, 0.0, 0.0, 0.0);
        }
        [abstractText release];
    }
    else
    {
        NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,self.doc.location == nil? @"":[WizGlobals folderStringToLocal:self.doc.location]];
        NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
        NSArray* tags = [self.doc tagDatas];
        for (WizTag* each in tags) {
            NSString* tagName = getTagDisplayName(each.title);
            tagstr = [tagstr stringByAppendingFormat:@"%@|",tagName];
        }
        if (![tagstr isEqualToString:[NSString stringWithFormat:@"%@:",WizStrTags]]) {
            if (tagstr != nil && tagstr.length > 1) {
                tagstr = [tagstr substringToIndex:tagstr.length-1];
                folder = [folder stringByAppendingString:tagstr];
            }
            
            
        }
        NSMutableAttributedString* detail = [[NSMutableAttributedString alloc] initWithString:folder attributes:[WizPadDocumentAbstractView detailDecorator]];
        [abstractString appendAttributedString:detail];
        [detail release];
        self.abstractImageView.image = nil;
    }
    [abstractString release];
    self.userInteractionEnabled = YES;
    [self addSelcetorToView:@selector(didSelectedDocument) :self];
}
- (void) drawRect:(CGRect)rect
{
    
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
