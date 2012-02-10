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
@implementation WizPadDocumentAbstractView
@synthesize nameLabel;
@synthesize abstractLabel;
@synthesize abstractImageView;
@synthesize accountUserId;
@synthesize doc;
@synthesize owner;
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

- (NSDictionary*) stringAttributes
{
    NSMutableDictionary* attributeDic = [NSMutableDictionary dictionary];
    [attributeDic setObject:(id)[UIColor lightGrayColor].CGColor forKey:(NSString*)kCTUnderlineColorAttributeName];
    [attributeDic setObject:(id)[[UIColor grayColor] CGColor]  forKey:(NSString *)kCTForegroundColorAttributeName];
    long characheterSpacing = 0.5f;
    char characheter = (char)characheterSpacing;
    CFNumberRef num = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt8Type, &characheter);
    [attributeDic setObject:(id)num forKey:(NSString *)kCTKernAttributeName];
    
    CGFloat lineSpace = 19;
    CTParagraphStyleSetting lineSpaceStyle;
    lineSpaceStyle.spec = kCTParagraphStyleSpecifierMinimumLineHeight;
    lineSpaceStyle.valueSize = sizeof(lineSpace);
    lineSpaceStyle.value = &lineSpace;
    CTParagraphStyleSetting settings[] = {lineSpaceStyle};
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, sizeof(settings));
    [attributeDic setObject:(id)style forKey:(id)kCTParagraphStyleAttributeName];
    UIFont* stringFont = [UIFont systemFontOfSize:13];
    CTFontRef font = CTFontCreateWithName((CFStringRef)stringFont.fontName, stringFont.pointSize, NULL);
    [attributeDic setObject:(id)font forKey:(NSString*)kCTFontAttributeName];
    return attributeDic;
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
        [abstractText addAttributes:[self stringAttributes] range:textRange];
        [abstractString appendAttributedString:abstractText];
         if (nil != abstract.image) {
            self.abstractLabel.frame = AbstractLabelWithImageFrame;
            self.abstractImageView.frame = AbstractImageviewFrame;
            self.abstractImageView.image = abstract.image;
//             float imageWidth = abstract.image.size.width;
//             float imageHeigth = abstract.image.size.height;
//             float imageSizeRatio = 175/imageWidth < 85/imageHeigth ? 175/imageWidth: 85/imageHeigth;
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
        self.abstractLabel.text = @"";
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
