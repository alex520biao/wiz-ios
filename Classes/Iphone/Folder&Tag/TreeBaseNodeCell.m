//
//  TreeBaseNodeCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 11-11-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "TreeBaseNodeCell.h"
#import "TreeBaseNode.h"
@implementation TreeBaseNodeCell



static int indent=15;//默认缩进值15
static int icoHeight=32;//默认图标32高
static int icoWidth=32;//默认图标32宽
static int labelMarginLeft=2;//默认标签左边留空2

@synthesize owner;
@synthesize btnExpand;
@synthesize imgIcon;
@synthesize treeNode;
@synthesize label;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
    }
    return self;
}
+(int)indent{
	return indent;
}
+(void)setIndent:(int)value{
	indent=value;
}
+(int)icoWidth{
	return icoWidth;
}
+(void)setIcoWidth:(int)value{
	icoWidth=value;
}
+(int)icoHeight{
	return icoHeight;
}
+(void)setIcoHeight:(int)value{
	icoHeight=value;
}
+(int)labelMarginLeft{
	return labelMarginLeft;
}
+(void)setLabelMarginLeft:(int)value{
	labelMarginLeft=value;
}
-(int)getIndent{
	return indent;
}

-(void) onExpand:(id) sender
{
    if (self.treeNode.isHaseChild) {
		
		if (self.treeNode.isExpand) {
			[btnExpand setImage:[UIImage imageNamed:@"tree_open.png"]
                       forState:UIControlStateNormal];
		}else {
			UIImage *img=[UIImage imageNamed:@"tree_close.png"];
		
			[btnExpand setImage:img
                       forState:UIControlStateNormal];
		}
	}else {
		[btnExpand setImage:nil forState:UIControlStateNormal];
	}
    self.treeNode.isExpand = !self.treeNode.isExpand;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void)setTreeNode:(TreeBaseNode *)node{
	self.treeNode=node;
	if (label==nil) {
		btnExpand=[[UIButton alloc]initWithFrame:CGRectMake((indent*node.deep), 5, 32, 32)];
		[btnExpand addTarget:self action:@selector(onExpand:)
			forControlEvents:UIControlEventTouchUpInside];

		imgIcon=[[UIImageView alloc]initWithFrame:
                 CGRectMake(32+(indent*node.deep), 0, icoWidth, icoHeight)];
		label=[[UILabel alloc]initWithFrame:
			   CGRectMake(32+labelMarginLeft+icoWidth+(indent*node.deep), 0, 200,36)];
        [imgIcon setImage:[UIImage imageNamed:@"tree_view_icon_list_folder.png"]];
		[self addSubview:label];
		[self addSubview:imgIcon];
		[self addSubview:btnExpand];
	}else {
		[btnExpand setFrame:CGRectMake(indent*node.deep, 5, 32, 32)];
		[imgIcon setFrame:CGRectMake(32+(indent*node.deep), 0, icoWidth, icoHeight)];
		[label setFrame:CGRectMake(32+labelMarginLeft+icoWidth+(indent*node.deep), 0, 200, 36)];
    }
	if (node.isHaseChild) {
		
		if (node.isExpand) {
			[btnExpand setImage:[UIImage imageNamed:@"tree_open.png"]
                       forState:UIControlStateNormal];
		}else {
			UIImage *img=[UIImage imageNamed:@"tree_close.png"];
			
			[btnExpand setImage:img
                       forState:UIControlStateNormal];
		}
	}else {
		
		[btnExpand setImage:nil forState:UIControlStateNormal];
	}
}


@end
