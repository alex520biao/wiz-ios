//
//  WizTagCatelogView.m
//  Wiz
//
//  Created by 朝 董 on 12-5-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "WizTagCatelogView.h"
#import "WizDbManager.h"
@implementation WizTagCatelogView

@synthesize wizTag;

- (void) dealloc
{
    [wizTag release];
    wizTag = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void) didSelectedCateLogView
{
    [self.selectedDelegate didSelectedCatelogForKey:self.wizTag];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (nil == self.wizTag) {
        return;
    }
    nameLabel.text =  getTagDisplayName(self.wizTag.title);
    backGroudImageView.image = [UIImage imageNamed:@"tagBackgroud"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         id<WizDbDelegate> dataBase = [[WizDbManager shareDbManager] shareDataBase];
        NSInteger count =  [dataBase fileCountOfTag:self.wizTag.guid];
        NSString* noteNumberStr = [NSString stringWithFormat:@"%d %@",count,WizStrNotes];
        NSString* abstractStr = [dataBase tagAbstractString:self.wizTag.guid];
        dispatch_async(dispatch_get_main_queue(), ^{
            documentsCountLabel.text = noteNumberStr;
             detailLabel.text = abstractStr;
        });
       
    });
   
}

@end
