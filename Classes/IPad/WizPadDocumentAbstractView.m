//
//  WizPadDocumentAbstractView.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizPadDocumentAbstractView.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "WizPadNotificationMessage.h"
#import "WizGlobals.h"
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
@synthesize abstractLabel;
@synthesize abstractImageView;
@synthesize accountUserId;
@synthesize doc;
@synthesize owner;

static NSMutableDictionary* timeDecorator;
static NSMutableDictionary* nameDecorator;
static NSMutableDictionary* detailDecorator;

+ (NSMutableDictionary*) timeDecorator
{
    if (timeDecorator == nil) {
        timeDecorator = [[NSMutableDictionary alloc] init];
        [timeDecorator setObject:(id)[[UIColor blueColor] CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    }
    return timeDecorator;
}
+ (NSMutableDictionary*) nameDecorator
{
    return nameDecorator;
}

+ (NSMutableDictionary*) detailDecorator
{
    if (detailDecorator == nil) {
        detailDecorator = [[[WizGlobalData sharedData] attributesForAbstractViewParagraphPad] mutableCopy];
    }
    return detailDecorator;
}
- (void) dealloc
{
    self.owner = nil;
    self.doc = nil;
    self.nameLabel = nil;
    self.abstractLabel = nil;
    self.abstractImageView = nil;
    self.accountUserId = nil;
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
        TTTAttributedLabel* abstractLabel_ = [[TTTAttributedLabel alloc] initWithFrame:AbstractLabelWithImageFrame];
        abstractLabel_.lineBreakMode = UILineBreakModeCharacterWrap;
        abstractLabel_.numberOfLines  =0;
        [abstractLabel_ setLineHeightMultiple:3];
        [abstractLabel_ setFirstLineIndent:2];
        abstractLabel_.textAlignment = UITextAlignmentLeft;
        abstractLabel_.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        [self addSubview:abstractLabel_];
        [abstractLabel_ release];
        self.abstractLabel = abstractLabel_;
        self.abstractLabel.backgroundColor = [UIColor clearColor];
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
    [self.owner performSelector:@selector(didSelectedDocument:) withObject:self.doc];
}

- (void) setDocument:(WizDocument*) document
{
    self.doc = document;
    self.nameLabel.text = @"";
    self.abstractImageView.image = nil;
    self.abstractLabel.text = @"";
    WizIndex* index = [[WizGlobalData sharedData] indexData:self.accountUserId];
    self.nameLabel.text = document.title;
    NSMutableAttributedString* abstractString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",self.doc.dateModified]];
    [abstractString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, abstractString.length)];
    float startPointX = 10.0f;
    if ([index abstractExist:document.guid]) {
        WizAbstract* abstract = [index abstractOfDocument:document.guid];
        NSMutableAttributedString* abstractText = [[NSMutableAttributedString alloc] initWithString:abstract.text];
        NSRange textRange =NSMakeRange(0, abstractText.length);
        [abstractText addAttributes:[[WizGlobalData sharedData] attributesForAbstractViewParagraphPad]  range:textRange];
        [abstractString appendAttributedString:abstractText];
         if (nil != abstract.image) {
            self.abstractLabel.frame = AbstractLabelWithImageFrame;
            self.abstractImageView.frame = AbstractImageviewFrame;
            self.abstractImageView.image = abstract.image;
            self.abstractImageView.frame= CGRectMake(0.0, 0.0, abstract.image.size.width , abstract.image.size.height);
            self.abstractImageView.center = CGPointMake(102.5, 187.5);
        }else
        {
            self.abstractLabel.frame = AbstractLabelWithoutImageFrame;
            self.abstractImageView.frame = CGRectMake(startPointX, 0.0, 0.0, 0.0);
        }
        [abstractText release];
    }
    else
    {
        NSString* folder = [NSString stringWithFormat:@"%@:%@\n",WizStrFolders,self.doc.location == nil? @"":[WizGlobals folderStringToLocal:self.doc.location]];
        NSString* tagstr = [NSString stringWithFormat:@"%@:",WizStrTags];
        NSArray* tags = [index tagsByDocumentGuid:self.doc.guid];
        for (WizTag* each in tags) {
            NSString* tagName = getTagDisplayName(each.name);
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
    [self.abstractLabel setText:abstractString];
    [abstractString release];
    self.userInteractionEnabled = YES;
    [self addSelcetorToView:@selector(didSelectedDocument) :self];
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
