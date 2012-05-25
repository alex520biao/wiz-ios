//
//  WizFolderCatelogView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizFolderCatelogView.h"
#import "WizAbstractCache.h"

@implementation WizFolderCatelogView
@synthesize folderKey;
- (void) dealloc
{
    [folderKey release];
    folderKey = nil;
    [super dealloc];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backGroudImageView.image = [UIImage imageNamed:@"folderBackgroud"];
    }
    return self;
}

- (void) didSelectedCateLogView
{
    [self.selectedDelegate didSelectedCatelogForKey:self.folderKey];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (nil == self.folderKey) {
        return;
    }
    nameLabel.text = self.folderKey;
    NSInteger count =  [WizObject fileCountOfLocation:self.folderKey];
    documentsCountLabel.text = [NSString stringWithFormat:@"%d %@",count,WizStrNotes];
    detailLabel.text = [[WizAbstractCache shareCache] getFolderAbstract:self.folderKey];
}
@end
