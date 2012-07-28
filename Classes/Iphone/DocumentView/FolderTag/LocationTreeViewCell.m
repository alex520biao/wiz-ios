//
//  LocationTreeViewCell.m
//  Wiz
//
//  Created by dong zhao on 11-10-20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "LocationTreeViewCell.h"

@implementation LocationTreeViewCell

@synthesize expandDelegate;
@synthesize closedImage;
@synthesize expandImage;
@synthesize treeNode;
- (void) dealloc
{
    expandDelegate = nil;
    [closedImage release];
    [expandImage release];
    [treeNode release];
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
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self addSelcetorToView:@selector(onExpandThis) :self.imageView];
    }
    return self;
}

-(void)onExpandThis{
	if ([treeNode hasChildren]) {//如果有子节点
        if ([treeNode expanded]) {
            self.imageView.image = self.closedImage;
        }
        else
        {
            self.imageView.image = self.expandImage;
        }
		treeNode.expanded=!treeNode.expanded;//切换“展开/收起”状态
        [self.expandDelegate onExpand:treeNode];
	}
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
