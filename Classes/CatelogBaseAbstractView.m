//
//  CatelogBaseAbstractView.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogBaseAbstractView.h"

@implementation CatelogBaseAbstractView
@synthesize nameLabel;
@synthesize documentsCountLabel;
@synthesize abstractLabel;
@synthesize owner;
@synthesize keywords;
- (void) dealloc
{
    self.keywords = nil;
    self.nameLabel = nil;
    self.documentsCountLabel = nil;
    self.abstractLabel = nil;
    self.owner = nil;
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
- (void) didSelectedDocument
{
    [self.owner performSelector:@selector(didSelectedCatelog:) withObject:self.keywords];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* backgroud = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0 , frame.size.width, frame.size.height - 66)];
        backgroud.image = [UIImage imageNamed:@"categoryBackgroud"];
        [self addSubview:backgroud];
        [backgroud release];
        UILabel* name = [[UILabel alloc] initWithFrame:CGRectMake(0.0,frame.size.height - 70 , frame.size.width, 40)];
        self.nameLabel = name;
        name.numberOfLines = 0;
        name.backgroundColor = [UIColor clearColor];
        name.textAlignment = UITextAlignmentCenter;
        name.textColor = [UIColor whiteColor];
        [self addSubview:name];
        [name release];
        UILabel* documentsCount = [[UILabel alloc] initWithFrame:CGRectMake(0.0,frame.size.height - 30 , frame.size.width, 20)];
        self.documentsCountLabel = documentsCount;
        documentsCount.backgroundColor = [UIColor clearColor];
        documentsCount.textAlignment = UITextAlignmentCenter;
        documentsCount.textColor = [UIColor lightGrayColor];
        [self addSubview:documentsCount];
        [documentsCount release];
        TTTAttributedLabel* abstract = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(30, 38, 140, 160)];
        abstract.verticalAlignment = TTTAttributedLabelVerticalAlignmentTop;
        self.abstractLabel = abstract;
        abstract.numberOfLines = 0;
        abstract.backgroundColor = [UIColor clearColor];
        [self addSubview:abstract];
        [abstract release];
        [self addSelcetorToView:@selector(didSelectedDocument) :self];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
