//
//  WizPadTreeTableCell.m
//  Wiz
//
//  Created by wiz on 12-8-16.
//
//

#import "WizPadTreeTableCell.h"

#define WizTreeMaxDeep 7

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

- (void) showExpandedIndicatory
{
    [self bringSubviewToFront:expandedButton];
    if ([self.treeNode.childrenNodes count]) {
        if (!self.treeNode.isExpanded) {
            [expandedButton setImage:[UIImage imageNamed:@"treeClosed"] forState:UIControlStateNormal];
        }
        else
        {
            [expandedButton setImage:[UIImage imageNamed:@"treeOpened"] forState:UIControlStateNormal];
        }
    }
    else
    {
        [expandedButton setImage:nil forState:UIControlStateNormal];
    }
}

- (void) didExpanded
{
    [self.delegate onExpandedNode:self.treeNode];
    [self showExpandedIndicatory];

}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        expandedButton  = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [self.contentView addSubview:expandedButton];
        expandedButton.backgroundColor = [UIColor whiteColor];
        [expandedButton addTarget:self action:@selector(didExpanded) forControlEvents:UIControlEventTouchUpInside];
        expandedButton.backgroundColor = [UIColor clearColor];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont systemFontOfSize:16];
        
        [self.contentView addSubview:titleLabel];
        detailLabel = [[UILabel alloc] init];
        detailLabel.font = [UIFont systemFontOfSize:13];
        detailLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:detailLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        detailLabel.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    detailLabel.text = nil;
    
    
    CGFloat indentationLevel = 20* ((self.treeNode.deep-1) > WizTreeMaxDeep ? WizTreeMaxDeep : (self.treeNode.deep-1));
    static float  buttonWith = 44;
    expandedButton.frame = CGRectMake(indentationLevel, 0.0, buttonWith, buttonWith);
    
    
    titleLabel.frame = CGRectMake(buttonWith+indentationLevel, 0.0, self.frame.size.width - buttonWith - indentationLevel, 25);
    detailLabel.frame = CGRectMake(buttonWith+indentationLevel, 25, self.frame.size.width - buttonWith - indentationLevel, 15);

    
    [self showExpandedIndicatory];

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
        titleLabel.text = [WizGlobals folderStringToLocal:self.treeNode.title];
    }
    else if ([self.treeNode.strType isEqualToString:WizTreeViewTagKeyString])
    {
        NSInteger fileNumber = [WizTag fileCountOfTag:self.treeNode.keyString];
        NSString* count = [NSString stringWithFormat:NSLocalizedString(@"%d notes", nil),fileNumber];
        detailLabel.text = count;
        titleLabel.text = getTagDisplayName(self.treeNode.title);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        self.contentView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:0.5];
    }
    else
    {
        self.contentView.backgroundColor = [UIColor whiteColor];
    }
}

@end
