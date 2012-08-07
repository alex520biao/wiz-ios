//
//  WizTreeRemindView.m
//  Wiz
//
//  Created by wiz on 12-8-7.
//
//

#import "WizTreeRemindView.h"

@implementation WizTreeRemindView
@synthesize imageView;
@synthesize textLabel;
- (void) dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:imageView];
        textLabel = [[UILabel alloc] init];
        textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:textLabel];
        self.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor grayColor];
        textLabel.font = [UIFont systemFontOfSize:13];
        textLabel.frame = CGRectMake(90, 0, 200, 100);
        textLabel.numberOfLines = 0;
        [imageView release];
        [textLabel release];
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
