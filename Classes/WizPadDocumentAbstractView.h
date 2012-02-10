//
//  WizPadDocumentAbstractView.h
//  Wiz
//
//  Created by dong yishuiliunian on 12-1-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"
@class WizDocument;
@interface WizPadDocumentAbstractView : UIView
{
    TTTAttributedLabel* abstractLabel;
    UILabel* nameLabel;
    UIImageView* abstractImageView;
    NSString* accountUserId;
    WizDocument* doc;
    id owner;
}
@property (nonatomic, retain) TTTAttributedLabel* abstractLabel;
@property (nonatomic, retain) UILabel* nameLabel;
@property (nonatomic, retain) UIImageView* abstractImageView;
@property (nonatomic, retain) NSString* accountUserId;
@property (nonatomic, retain) WizDocument* doc;
@property (nonatomic, retain) id owner;
- (void) setDocument:(WizDocument*) document;
@end
