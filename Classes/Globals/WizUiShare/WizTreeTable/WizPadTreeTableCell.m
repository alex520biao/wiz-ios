//
//  WizPadTreeTableCell.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import "WizPadTreeTableCell.h"

@interface WizPadTreeTableCell ()

@end

@implementation WizPadTreeTableCell
@synthesize treeNode;
@synthesize titleLabel;
@synthesize expandedButton;
@synthesize detailLabel;
@synthesize delegate;
- (void) dealloc
{
    delegate = nil;
    [treeNode release];
    [expandedButton release];
    [titleLabel release];
    [detailLabel release];
    [super dealloc];
}
- (void) didExpanded
{
    [self.delegate onExpandedNode:self.treeNode];
    if ([self.treeNode.childrenNodes count]) {
        if (!self.treeNode.isExpanded) {
            expandedButton.backgroundColor = [UIColor greenColor];
        }
        else
        {
            expandedButton.backgroundColor = [UIColor blueColor];
        }
    }

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        expandedButton  = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self.contentView addSubview:expandedButton];
        expandedButton.backgroundColor = [UIColor whiteColor];
        [expandedButton addTarget:self action:@selector(didExpanded) forControlEvents:UIControlEventTouchUpInside];
        
        titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        detailLabel = [[UILabel alloc] init];
        [self.contentView addSubview:detailLabel];


    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    detailLabel.text = nil;
    CGFloat indentationLevel = 20* (self.treeNode.deep-1);
    expandedButton.frame = CGRectMake(indentationLevel, 0.0, 60, 40);
    titleLabel.frame = CGRectMake(60+indentationLevel, 0.0, 160, 20);
    detailLabel.frame = CGRectMake(60+indentationLevel, 20, 160, 20);
    titleLabel.text = self.treeNode.title;
    
    
    if ([self.treeNode.childrenNodes count]) {
        if (!self.treeNode.isExpanded) {
            expandedButton.backgroundColor = [UIColor greenColor];
        }
        else
        {
            expandedButton.backgroundColor = [UIColor blueColor];
        }
    }
    else
    {
        expandedButton.backgroundColor = [UIColor whiteColor];
    }
    if([self.treeNode.strType isEqualToString:WizTreeViewFolderKeyString])
    {
        NSInteger currentCount = [WizObject fileCountOfLocation:self.treeNode.keyString];
        NSInteger totalCount = [WizObject filecountWithChildOfLocation:self.treeNode.keyString];
        if (currentCount != totalCount) {
            detailLabel.text = [NSString stringWithFormat:@"%d/%d",currentCount,totalCount];
        }
        else {
            detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),currentCount];
        }
    }
    else if ([self.treeNode.strType isEqualToString:WizTreeViewTagKeyString])
    {
        NSInteger fileNumber = [WizTag fileCountOfTag:self.treeNode.keyString];
        NSString* count = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),fileNumber];
        detailLabel.text = count;
    }

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
