//
//  WizPadTreeTableHeaderView.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//
#import <QuartzCore/QuartzCore.h>
#import "WizPadTreeTableHeaderView.h"

@interface WizPadTreeTableHeaderView ()
{
    UIImageView*  expandedImageView;
}
@end

@implementation WizPadTreeTableHeaderView
@synthesize titleLabel;
@synthesize delegate;
@synthesize treeNode;
- (void) dealloc
{
    self.treeNode = nil;
    delegate = nil;
    [titleLabel release];
    [expandedImageView release];
    [super dealloc];
}

- (void) showExpandedIndicatory
{
    if (self.treeNode.isExpanded) {
        expandedImageView.image =[UIImage imageNamed:@"treeCut"];
    }
    else
    {
        expandedImageView.image = [UIImage imageNamed:@"treePlus"];
    }
}

- (void) didSelected
{
    [self.delegate didSelectedHeader:self forTreeNode:self.treeNode];
    [self showExpandedIndicatory];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableSectionHeader"]];
        imageView.frame = CGRectMake(0.0, 0.0, frame.size.width, frame.size.height);
        [self addSubview:imageView];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [self addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        expandedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 40, 0.0, 40, 40)];
        [self addSubview:expandedImageView];
        expandedImageView.image = [UIImage imageNamed:@"treeCut"];
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected)] autorelease];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [self addGestureRecognizer:tap];
        self.alpha = 0.8;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


@end
