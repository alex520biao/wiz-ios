//
//  WizPadTreeTableHeaderView.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//
#import <QuartzCore/QuartzCore.h>
#import "WizPadTreeTableHeaderView.h"

@implementation WizPadTreeTableHeaderView
@synthesize titleLabel;
@synthesize delegate;
@synthesize treeNode;
- (void) dealloc
{
    self.treeNode = nil;
    delegate = nil;
    [titleLabel release];
    [super dealloc];
}

- (void) didSelected
{
    [self.delegate didSelectedHeader:self forTreeNode:self.treeNode];
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
        
        UITapGestureRecognizer* tap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelected)] autorelease];
        tap.numberOfTapsRequired =1;
        tap.numberOfTouchesRequired =1;
        [self addGestureRecognizer:tap];
        
        self.alpha = 0.8;
        
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
