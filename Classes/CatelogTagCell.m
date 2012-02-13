//
//  CatelogTagCell.m
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CatelogTagCell.h"
#import "CatelogBaseAbstractView.h"
#import "WizIndex.h"
#import "WizGlobalData.h"
#import "CatelogBaseController.h"
@implementation CatelogTagCell
- (void) setContent:(NSArray*) arr
{
    if ([arr count]) {
        for (UIView* each in [self.contentView subviews]) {
            [each removeFromSuperview];
        }
        
    }
    for (int i = 0; i < [arr count]; i++) {
        WizPadCatelogData* data = [arr objectAtIndex:i];
        CatelogBaseAbstractView* abstractView = [[CatelogBaseAbstractView alloc] initWithFrame:CGRectMake(55+55*i+180*i, 15, 180, PADABSTRACTVELLHEIGTH-30)];
        abstractView.owner = self.owner;
        abstractView.nameLabel.text = NSLocalizedString(data.name, nil);
        abstractView.keywords = data.keyWords;
        abstractView.documentsCountLabel.text = data.count;
        abstractView.abstractLabel.text = data.abstract;
        [self.contentView addSubview:abstractView];
        [abstractView release];
    }
}
@end
